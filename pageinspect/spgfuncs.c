#include "postgres.h"
#include "access/spgist_private.h"
#include "pageinspect.h"
// include special identification for relation
#include "catalog/pg_am_d.h"
// miscadmin.h needed to allow use only by superusers
#include "miscadmin.h"
// to check return type
#include "funcapi.h"
#include "utils/pg_lsn.h"
#include "utils/builtins.h"
#include "utils/array.h"
#include "utils/rel.h"
#include "utils/ruleutils.h"
#include "access/relation.h"
#include "utils/lsyscache.h"
#include "utils/datum.h"


PG_FUNCTION_INFO_V1(spgist_page_opaque_info);
PG_FUNCTION_INFO_V1(spgist_inner_tuples_nodes);
PG_FUNCTION_INFO_V1(spgist_inner_tuples);
PG_FUNCTION_INFO_V1(spgist_leaf_tuples);

#define IS_SPGIST(r) ((r)->rd_rel->relam == SPGIST_AM_OID)


static Page verify_spgist_page(bytea *raw_page);

/*
 * Verify that the given bytea contains a SP-GiST page or die in the attempt.
 * A pointer to the page is returned.
 */
static Page
verify_spgist_page(bytea *raw_page)
{
	Page		page = get_page_from_raw(raw_page);
	SpGistPageOpaque opaq;

	if (PageIsNew(page))
		return page;

	/* verify the special space has the expected size */
	if (PageGetSpecialSize(page) != MAXALIGN(sizeof(SpGistPageOpaqueData)))
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("input page is not a valid %s page", "SP-GiST"),
				 errdetail("Expected special size %d, got %d.",
						   (int) MAXALIGN(sizeof(SpGistPageOpaqueData)),
						   (int) PageGetSpecialSize(page))));

	opaq = SpGistPageGetOpaque(page);
	if (opaq->spgist_page_id != SPGIST_PAGE_ID)
		ereport(ERROR,
				(errcode(ERRCODE_INVALID_PARAMETER_VALUE),
				 errmsg("input page is not a valid %s page", "SP-GiST"),
				 errdetail("Expected %08x, got %08x.",
						   SPGIST_PAGE_ID,
						   opaq->spgist_page_id)));

	return page;
}


Datum
spgist_page_opaque_info(PG_FUNCTION_ARGS)
{
	bytea	   *raw_page = PG_GETARG_BYTEA_P(0);
	TupleDesc	tupdesc;
	Page		page;
	HeapTuple	resultTuple;
	Datum		values[4];
	bool		nulls[4];
	Datum		flags[16];
	int			nflags = 0;
	uint16		flagbits;

	if (!superuser())
		ereport(ERROR,
				(errcode(ERRCODE_INSUFFICIENT_PRIVILEGE),
				 errmsg("must be superuser to use raw page functions")));

	page = verify_spgist_page(raw_page);

	if (PageIsNew(page))
		PG_RETURN_NULL();

	/* Build a tuple descriptor for our result type */
	if (get_call_result_type(fcinfo, NULL, &tupdesc) != TYPEFUNC_COMPOSITE)
		elog(ERROR, "return type must be a row type");

	flagbits = SpGistPageGetOpaque(page)->flags;
	if (flagbits & SPGIST_META)
		flags[nflags++] = CStringGetTextDatum("meta");
	if (flagbits & SPGIST_DELETED)
		flags[nflags++] = CStringGetTextDatum("deleted");
	if (flagbits & SPGIST_LEAF)
		flags[nflags++] = CStringGetTextDatum("leaf");
	if (flagbits & SPGIST_NULLS)
		flags[nflags++] = CStringGetTextDatum("nulls");

	flagbits &= ~(SPGIST_META | SPGIST_DELETED | SPGIST_LEAF | SPGIST_NULLS);
	if (flagbits)
	{
		/* any flags we don't recognize are printed in hex */
		flags[nflags++] = DirectFunctionCall1(to_hex32, Int32GetDatum(flagbits));
	}

	values[0] = LSNGetDatum(PageGetLSN(page));
	values[1] = Int16GetDatum(SpGistPageGetOpaque(page)->nRedirection);
	values[2] = Int16GetDatum(SpGistPageGetOpaque(page)->nPlaceholder);
	values[3] = PointerGetDatum(construct_array_builtin(flags, nflags, TEXTOID));

	memset(nulls, 0, sizeof(nulls));

	/* Build and return the result tuple. */
	resultTuple = heap_form_tuple(tupdesc, values, nulls);

	return HeapTupleGetDatum(resultTuple);
}

Datum
spgist_inner_tuples_nodes(PG_FUNCTION_ARGS) {
	bytea	   *raw_page = PG_GETARG_BYTEA_P(0);
	Oid			indexRelid = PG_GETARG_OID(1);
	ReturnSetInfo *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
	Relation	indexRel;
	Page		page;
	uint16		flagbits;
	bits16		printflags = 0;
	OffsetNumber offset;
	OffsetNumber maxoff = InvalidOffsetNumber;
	char	   *index_columns;

	// what it does
	InitMaterializedSRF(fcinfo, 0);

	/* Open the relation */
	indexRel = index_open(indexRelid, AccessShareLock);

	if (!IS_SPGIST(indexRel))
		ereport(ERROR,
				(errcode(ERRCODE_WRONG_OBJECT_TYPE),
				 errmsg("\"%s\" is not a %s index",
						RelationGetRelationName(indexRel), "SP-GiST")));

	page = verify_spgist_page(raw_page);

	if (PageIsNew(page))
	{
		index_close(indexRel, AccessShareLock);
		PG_RETURN_NULL();
	}

	flagbits = SpGistPageGetOpaque(page)->flags;

	if ( (flagbits & SPGIST_LEAF) | (flagbits & SPGIST_META) | (flagbits & SPGIST_NULLS))
		ereport(ERROR,
				(errcode(ERRCODE_WRONG_OBJECT_TYPE),
				 errmsg("This page is not an inner tuples' page of %s index",
						RelationGetRelationName(indexRel))));

	/*
	 * Included attributes are added when dealing with leaf pages, discarded
	 * for non-leaf pages as these include only data for key attributes.
	 */
	printflags |= RULE_INDEXDEF_PRETTY;
	printflags |= RULE_INDEXDEF_KEYS_ONLY;

	index_columns = pg_get_indexdef_columns_extended(indexRelid, printflags);

	/* Avoid bogus PageGetMaxOffsetNumber() call with deleted pages */
	if (SpGistPageIsDeleted(page))
		elog(NOTICE, "page is deleted");
	else
		maxoff = PageGetMaxOffsetNumber(page);

	for (offset = FirstOffsetNumber; offset <= maxoff; offset++)
	{
		ItemId		id;
		SpGistInnerTuple	itup;
		Datum		values[4];
		bool		nulls[4];
		SpGistNodeTuple node;
		SpGistTypeDesc attLabelType;
		Oid			foutoid;
		bool		typisvarlena;
		Oid			typoid;
		int			i;

		id = PageGetItemId(page, offset);
		if (!ItemIdIsValid(id))
			elog(ERROR, "invalid ItemId");

		itup = (SpGistInnerTuple) PageGetItem(page, id);

		memset(nulls, 0, sizeof(nulls));

		values[0] = Int16GetDatum(offset);

		attLabelType = spgGetCache(indexRel)->attLabelType;
		typoid = attLabelType.type;
		getTypeOutputInfo(typoid, &foutoid, &typisvarlena);

		SGITITERATE(itup, i, node)
		{
			if(ItemPointerIsValid(&node->t_tid)) {
				values[1] = UInt32GetDatum(BlockIdGetBlockNumber(&node->t_tid.ip_blkid));
				nulls[1] = false;
				values[2] = UInt16GetDatum(node->t_tid.ip_posid);
				nulls[2] = false;
			} else {
				nulls[1] = true;
				values[1] = (Datum) 0;
				nulls[2] = true;
				values[2] = (Datum) 0;
			}

			values[3] = CStringGetTextDatum(
				OidOutputFunctionCall(
					foutoid,
					attLabelType.attbyval ? *(Datum *) SGNTDATAPTR(node) :  PointerGetDatum(SGNTDATAPTR(node))));

			tuplestore_putvalues(rsinfo->setResult, rsinfo->setDesc, values, nulls);
		}
	}

	relation_close(indexRel, AccessShareLock);

	return (Datum) 0;
}

Datum
spgist_inner_tuples(PG_FUNCTION_ARGS) {
	bytea	   *raw_page = PG_GETARG_BYTEA_P(0);
	Oid			indexRelid = PG_GETARG_OID(1);
	ReturnSetInfo *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
	Relation	indexRel;
	Page		page;
	uint16		flagbits;
	bits16		printflags = 0;
	OffsetNumber offset;
	OffsetNumber maxoff = InvalidOffsetNumber;
	char	   *index_columns;
	SpGistTypeDesc attPrefixType;
	Oid			foutoid;
	bool		typisvarlena;
	Oid			typoid;

	// what it does
	InitMaterializedSRF(fcinfo, 0);

	/* Open the relation */
	indexRel = index_open(indexRelid, AccessShareLock);

	if (!IS_SPGIST(indexRel))
		ereport(ERROR,
				(errcode(ERRCODE_WRONG_OBJECT_TYPE),
				 errmsg("\"%s\" is not a %s index",
						RelationGetRelationName(indexRel), "SP-GiST")));

	page = verify_spgist_page(raw_page);

	if (PageIsNew(page))
	{
		index_close(indexRel, AccessShareLock);
		PG_RETURN_NULL();
	}

	flagbits = SpGistPageGetOpaque(page)->flags;

	if ( (flagbits & SPGIST_LEAF) | (flagbits & SPGIST_META) | (flagbits & SPGIST_NULLS))
		ereport(ERROR,
				(errcode(ERRCODE_WRONG_OBJECT_TYPE),
				 errmsg("This page is not an inner tuples' page of %s index",
						RelationGetRelationName(indexRel))));

	/*
	 * Included attributes are added when dealing with leaf pages, discarded
	 * for non-leaf pages as these include only data for key attributes.
	 */
	printflags |= RULE_INDEXDEF_PRETTY;
	printflags |= RULE_INDEXDEF_KEYS_ONLY;

	index_columns = pg_get_indexdef_columns_extended(indexRelid, printflags);

	/* Avoid bogus PageGetMaxOffsetNumber() call with deleted pages */
	if (SpGistPageIsDeleted(page))
		elog(NOTICE, "page is deleted");
	else
		maxoff = PageGetMaxOffsetNumber(page);

	attPrefixType = spgGetCache(indexRel)->attPrefixType;
	typoid = attPrefixType.type;
	getTypeOutputInfo(typoid, &foutoid, &typisvarlena);

	for (offset = FirstOffsetNumber; offset <= maxoff; offset++)
	{
		ItemId		id;
		SpGistInnerTuple	itup;
		Datum		values[7];
		bool		nulls[7];

		id = PageGetItemId(page, offset);
		if (!ItemIdIsValid(id))
			elog(ERROR, "invalid ItemId");

		itup = (SpGistInnerTuple) PageGetItem(page, id);

		memset(nulls, 0, sizeof(nulls));

		values[0] = Int16GetDatum(offset);

		if (itup->tupstate == SPGIST_LIVE)
			values[1] = CStringGetTextDatum("live");
		if (itup->tupstate == SPGIST_REDIRECT)
			values[1] = CStringGetTextDatum("redirect");
		if (itup->tupstate == SPGIST_DEAD)
			values[1] = CStringGetTextDatum("dead");
		if (itup->tupstate == SPGIST_PLACEHOLDER)
			values[1] = CStringGetTextDatum("placeholder");

		values[2] = BoolGetDatum(itup->allTheSame);
		values[3] = Int16GetDatum(itup->nNodes);
		values[4] = Int32GetDatum(itup->prefixSize);
		values[5] = Int32GetDatum(itup->size);

		if( itup->prefixSize ) {
			char* value;
			if (typoid == TEXTOID) {
				StringInfoData buf;
				initStringInfo(&buf);
				appendStringInfoString(&buf, "\"");
				appendStringInfoString(&buf, OidOutputFunctionCall(foutoid, attPrefixType.attbyval ? *(Datum *) _SGITDATA(itup) :  PointerGetDatum(_SGITDATA(itup))));
				appendStringInfoString(&buf, "\"");
				value = buf.data;
			} else {
				value = OidOutputFunctionCall(foutoid, attPrefixType.attbyval ? *(Datum *) _SGITDATA(itup) :  PointerGetDatum(_SGITDATA(itup)));
			}
			values[6] = CStringGetTextDatum(value);
		} else {
			values[6] = (Datum) 0;
			nulls[6] = true;
		}

		tuplestore_putvalues(rsinfo->setResult, rsinfo->setDesc, values, nulls);
	}

	relation_close(indexRel, AccessShareLock);

	return (Datum) 0;
}


Datum
spgist_leaf_tuples(PG_FUNCTION_ARGS)
{
	bytea	   *raw_page = PG_GETARG_BYTEA_P(0);
	Oid			indexRelid = PG_GETARG_OID(1);
	ReturnSetInfo *rsinfo = (ReturnSetInfo *) fcinfo->resultinfo;
	Relation	indexRel;
	TupleDesc	tupdesc;
	Page		page;
	uint16		flagbits;
	bits16		printflags = 0;
	OffsetNumber offset;
	OffsetNumber maxoff = InvalidOffsetNumber;
	char	   *index_columns;


	// what it does
	InitMaterializedSRF(fcinfo, 0);

	/* Open the relation */
	indexRel = index_open(indexRelid, AccessShareLock);

	if (!IS_SPGIST(indexRel))
		ereport(ERROR,
				(errcode(ERRCODE_WRONG_OBJECT_TYPE),
				 errmsg("\"%s\" is not a %s index",
						RelationGetRelationName(indexRel), "SP-GiST")));

	page = verify_spgist_page(raw_page);

	if (PageIsNew(page))
	{
		index_close(indexRel, AccessShareLock);
		PG_RETURN_NULL();
	}

	flagbits = SpGistPageGetOpaque(page)->flags;

	if ( ! (flagbits & SPGIST_LEAF) )
		ereport(ERROR,
				(errcode(ERRCODE_WRONG_OBJECT_TYPE),
				 errmsg("This page is not a leaf tuples' page of %s index",
						RelationGetRelationName(indexRel))));

	/*
	 * Included attributes are added when dealing with leaf pages, discarded
	 * for non-leaf pages as these include only data for key attributes.
	 */
	printflags |= RULE_INDEXDEF_PRETTY;
	tupdesc = RelationGetDescr(indexRel);

	index_columns = pg_get_indexdef_columns_extended(indexRelid, printflags);

	/* Avoid bogus PageGetMaxOffsetNumber() call with deleted pages */
	if (SpGistPageIsDeleted(page))
		elog(NOTICE, "page is deleted");
	else
		maxoff = PageGetMaxOffsetNumber(page);

	for (offset = FirstOffsetNumber;
		 offset <= maxoff;
		 offset++)
	{
		ItemId		id;
		Datum		values[7];
		bool		nulls[7];
		SpGistLeafTuple	itup;
		Datum		itup_values[INDEX_MAX_KEYS];
		bool		itup_isnull[INDEX_MAX_KEYS];
		StringInfoData buf;
		int			i;

		id = PageGetItemId(page, offset);
		if (!ItemIdIsValid(id))
			elog(ERROR, "invalid ItemId");

		itup = (SpGistLeafTuple) PageGetItem(page, id);

		// provide correct value for isNull parameter
		spgDeformLeafTuple(itup, tupdesc, itup_values, itup_isnull, false);

		memset(nulls, 0, sizeof(nulls));

		values[0] = DatumGetInt16(offset);

		if (itup->tupstate == SPGIST_LIVE)
			values[1] = CStringGetTextDatum("live");
		if (itup->tupstate == SPGIST_REDIRECT)
			values[1] = CStringGetTextDatum("redirect");
		if (itup->tupstate == SPGIST_DEAD)
			values[1] = CStringGetTextDatum("dead");
		if (itup->tupstate == SPGIST_PLACEHOLDER)
			values[1] = CStringGetTextDatum("placeholder");

		values[2] = Int32GetDatum(itup->size);
		values[3] = Int16GetDatum(itup->t_info);


		if (index_columns)
		{
			if (itup->tupstate == SPGIST_LIVE) {
				initStringInfo(&buf);
				appendStringInfo(&buf, "(%s)=(", index_columns);

				/* Most of this is copied from record_out(). */
				for (i = 0; i < tupdesc->natts; i++)
				{
					char	   *value;
					char	   *tmp;
					bool		nq = false;

					if (itup_isnull[i])
						value = "null";
					else
					{
						Oid			foutoid;
						bool		typisvarlena;
						Oid			typoid;

						typoid = tupdesc->attrs[i].atttypid;
						getTypeOutputInfo(typoid, &foutoid, &typisvarlena);
						value = OidOutputFunctionCall(foutoid, itup_values[i]);
					}

					if (i == IndexRelationGetNumberOfKeyAttributes(indexRel))
						appendStringInfoString(&buf, ") INCLUDE (");
					else if (i > 0)
						appendStringInfoString(&buf, ", ");

					/* Check whether we need double quotes for this value */
					nq = (value[0] == '\0');	/* force quotes for empty string */
					for (tmp = value; *tmp; tmp++)
					{
						char		ch = *tmp;

						if (ch == '"' || ch == '\\' ||
							ch == '(' || ch == ')' || ch == ',' ||
							isspace((unsigned char) ch))
						{
							nq = true;
							break;
						}
					}

					/* And emit the string */
					if (nq)
						appendStringInfoCharMacro(&buf, '"');
					for (tmp = value; *tmp; tmp++)
					{
						char		ch = *tmp;

						if (ch == '"' || ch == '\\')
							appendStringInfoCharMacro(&buf, ch);
						appendStringInfoCharMacro(&buf, ch);
					}
					if (nq)
						appendStringInfoCharMacro(&buf, '"');
				}

				appendStringInfoChar(&buf, ')');
				values[4] = CStringGetTextDatum(buf.data);

				if(ItemPointerIsValid(&itup->heapPtr)) {
					values[5] = UInt32GetDatum(BlockIdGetBlockNumber(&itup->heapPtr.ip_blkid));
					values[6] = UInt16GetDatum(itup->heapPtr.ip_posid);
				} else {
					values[5] = (Datum) 0;
					nulls[5] = true;
					values[6] = (Datum) 0;
					nulls[6] = true;
				}
			} else {
				SpGistDeadTuple ditup = (SpGistDeadTuple)itup;

				values[4] = (Datum) 0;
				nulls[4] = true;

				if(ItemPointerIsValid(&ditup->pointer)) {
					values[5] = UInt32GetDatum(BlockIdGetBlockNumber(&ditup->pointer.ip_blkid));
					values[6] = UInt16GetDatum(ditup->pointer.ip_posid);
				} else {
					values[5] = (Datum) 0;
					nulls[5] = true;
					values[6] = (Datum) 0;
					nulls[6] = true;
				}
			}
		}
		else
		{
			values[4] = (Datum) 0;
			nulls[4] = true;
			values[5] = (Datum) 0;
			nulls[5] = true;
			values[6] = (Datum) 0;
			nulls[6] = true;
		}

		tuplestore_putvalues(rsinfo->setResult, rsinfo->setDesc, values, nulls);
	}

	relation_close(indexRel, AccessShareLock);

	return (Datum) 0;
}