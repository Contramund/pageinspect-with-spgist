# pageinspect-with-spgist

This is a temporary reposiotry. It contains an updated version of pageinspect module of [postgress](https://github.com/postgres/postgres) repository (located in folder /contrib). In this update I tried to add support for introspection of SP-GiST trees. All this functions are intended to be added to original repo (if they are OK).

## About

I implemented 4 functions. All of them are olny available as super-user and verify internally if they are working with SP-GiST page (otherwise panic):

* `spgist_page_opaque_info` -- this function takes a raw page as input and outupts a table with a single row filled with parameters from opaque section of this page.
``` sql
CREATE FUNCTION spgist_page_opaque_info(IN page bytea,
    OUT lsn pg_lsn,
    OUT nDirection smallint,
    OUT nPlaceholder smallint,
    OUT flags text[])
AS 'MODULE_PATHNAME', 'spgist_page_opaque_info'
LANGUAGE C STRICT PARALLEL SAFE;
```

* `spgist_inner_tuples` -- this fuction takes a raw page and index's name as input and returns a table that contains a single row for every node in the page. This function will panic if the input raw page is a leaf or meta page of SP-GiST index (should have no flags in the output of `spgist_page_opaque_info` function).
``` sql
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
```

* `spgist_inner_tuples_nodes` -- this function is analagous to previous, but returns a list of edges from each node on the page. Unlike existing fuction `gist_page_items` it was decided to normalize output table and avaoid gluing all the keys altogether. The main reason is that nodes of prefix-tree implementation can have 50+ edges with labels and the output in this case is completely unreadable.
``` sql
CREATE FUNCTION spgist_inner_tuples_nodes(IN page bytea,
    IN index_oid regclass,
    OUT tuple_offset smallint,
    OUT node_block_num int,
    OUT node_offset smallint,
    OUT node_label text)
RETURNS SETOF record
AS 'MODULE_PATHNAME', 'spgist_inner_tuples_nodes'
LANGUAGE C STRICT PARALLEL SAFE;
```

* `spgist_leaf_tuples` -- this function also takes a raw page and index's name as input and returns a table that contains a single row for every node in the page. Unlike `spgist_inner_tuples`, this function only works with leaf pages of SP-GiST (leaf flag in the output of `spgist_page_opaque_info` function).
``` sql
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
```

Note: when node has state "live" it's `pointer_block_num` and `pointer_offset` point to the table being indexed, but if state is "redirect" then theese parameters point to the very index's pages.

***For further information look into file `spgfuncs.c`, `pageinspect--1.12--1.13.sql` and tests located in `expect/spgist.out`***

## Patch
There is also patch `spgist_support_for_pageinspect.patch` that adds my update to postgres after commit number 902900b308fb38543b95526b1f384bf3cce2f514.