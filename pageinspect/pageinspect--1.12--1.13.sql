/* contrib/pageinspect/pageinspect--1.12--1.13.sql */

-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION pageinspect UPDATE TO '1.13'" to load this file. \quit

--
-- spgist_page_opaque_info()
--
CREATE FUNCTION spgist_page_opaque_info(IN page bytea,
    OUT lsn pg_lsn,
    OUT nDirection smallint,
    OUT nPlaceholder smallint,
    OUT flags text[])
AS 'MODULE_PATHNAME', 'spgist_page_opaque_info'
LANGUAGE C STRICT PARALLEL SAFE;

--
-- spgist_inner_tuples()
--
CREATE FUNCTION spgist_inner_tuples(IN page bytea,
    IN index_oid regclass,
    OUT tuple_offset smallint,
    OUT tuple_state text,
    OUT all_the_same boolean,
    OUT node_number int,
    OUT prefix_size int,
    OUT total_size int,
    OUT pref text)
RETURNS SETOF record
AS 'MODULE_PATHNAME', 'spgist_inner_tuples'
LANGUAGE C STRICT PARALLEL SAFE;

--
-- spgist_inner_tuples_nodes()
--
CREATE FUNCTION spgist_inner_tuples_nodes(IN page bytea,
    IN index_oid regclass,
    OUT tuple_offset smallint,
    OUT node_block_num int,
    OUT node_offset smallint,
    OUT node_label text)
RETURNS SETOF record
AS 'MODULE_PATHNAME', 'spgist_inner_tuples_nodes'
LANGUAGE C STRICT PARALLEL SAFE;

--
-- spgist_page_items()
--
CREATE FUNCTION spgist_leaf_tuples(IN page bytea,
    IN index_oid regclass,
    OUT item_offset smallint,
    OUT item_state text,
    OUT item_size int,
    OUT item_info smallint,
    OUT leaf_key text,
    OUT pointer_block_num int,
    OUT pointer_offset smallint)
RETURNS SETOF record
AS 'MODULE_PATHNAME', 'spgist_leaf_tuples'
LANGUAGE C STRICT PARALLEL SAFE;