--
--
--  ______            __        ____   __  __ ___    ___
-- /_  __/___   ___  / /_      / __ \ / / / // _ |  / _ \
--  / /  / -_) (_-< / __/     / /_/ // /_/ // __ | / // /
-- /_/   \__/ /___/ \__/      \___\_\\____//_/ |_|/____/
--
--

--
--
-- Create a test table for future quad index
--
CREATE TABLE test_spgist (
    pt point,
    t varchar(256)
);

--
--
-- Create quad index to test
--
CREATE INDEX test_spgist_idx ON test_spgist USING spgist (pt);

--
--
-- Add data to test table
--
INSERT INTO test_spgist
    SELECT point(i+500,i), i::text
    FROM generate_series(1,500) i;
--
INSERT INTO test_spgist
    SELECT point(i,i+500), (i+500)::text
    FROM generate_series(1,500) i;

--
--
-- cannot actually test lsn because the value can vary, so check everything else
-- Page 0 is the root, the rest are leaf pages:
--
SELECT 0 pageNum, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 0)) UNION
SELECT 1, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 1)) UNION
SELECT 2, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 2)) UNION
SELECT 3, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 3)) UNION
SELECT 4, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 4)) UNION
SELECT 5, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 5)) UNION
SELECT 6, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 6)) UNION
SELECT 7, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 7)) UNION
SELECT 8, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 8)) UNION
SELECT 9, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 9)) UNION
SELECT 10, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 10)) UNION
SELECT 11, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 11)) UNION
SELECT 12, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 12)) UNION
SELECT 13, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 13)) UNION
SELECT 14, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 14)) UNION
SELECT 15, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 15))
ORDER BY pageNum;

--
--
-- There is no more pages:
--
SELECT 16, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 16));


--
--
--
--
--
--
--
--
--
-- Let us check what data do we have:
--
--
-- Page 1
--
WITH nodes as (
    SELECT
        tuple_offset tuple_offset,
        STRING_AGG('(BlockNum=' || node_block_num || ', Offset=' || node_offset || ', Label=' || node_label || ')', ', ') edges
    FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx')
    GROUP BY tuple_offset
) SELECT
    tuples.tuple_offset AS offset,
    tuples.tuple_state AS state,
    tuples.all_the_same AS same,
    tuples.node_number,
    tuples.prefix_size,
    tuples.total_size,
    tuples.pref,
    nodes.edges
FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx') AS tuples
JOIN nodes
ON tuples.tuple_offset = nodes.tuple_offset;

--
--  Page 2
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 2), 'test_spgist_idx');

--
-- Page 3
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 3), 'test_spgist_idx');

--
-- Page 4
--
WITH nodes as (
    SELECT
        tuple_offset tuple_offset,
        STRING_AGG('(BlockNum=' || node_block_num || ', Offset=' || node_offset || ', Label=' || node_label || ')', ', ') edges
    FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx')
    GROUP BY tuple_offset
) SELECT
    tuples.tuple_offset AS offset,
    tuples.tuple_state AS state,
    tuples.all_the_same AS same,
    tuples.node_number,
    tuples.prefix_size,
    tuples.total_size,
    tuples.pref,
    nodes.edges
FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx') AS tuples
JOIN nodes
ON tuples.tuple_offset = nodes.tuple_offset;

--
-- Page 5
--
WITH nodes as (
    SELECT
        tuple_offset tuple_offset,
        STRING_AGG('(BlockNum=' || node_block_num || ', Offset=' || node_offset || ', Label=' || node_label || ')', ', ') edges
    FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx')
    GROUP BY tuple_offset
) SELECT
    tuples.tuple_offset AS offset,
    tuples.tuple_state AS state,
    tuples.all_the_same AS same,
    tuples.node_number,
    tuples.prefix_size,
    tuples.total_size,
    tuples.pref,
    nodes.edges
FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx') AS tuples
JOIN nodes
ON tuples.tuple_offset = nodes.tuple_offset;

--
-- Page 6
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 6), 'test_spgist_idx');

--
-- Page 7
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 7), 'test_spgist_idx');

--
-- Page 8
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 8), 'test_spgist_idx');

--
-- Page 9
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 9), 'test_spgist_idx');

--
-- Page 10
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 10), 'test_spgist_idx');

--
-- Page 11
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 11), 'test_spgist_idx');

--
-- Page 12
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 12), 'test_spgist_idx');

--
-- Page 13
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 13), 'test_spgist_idx');

--
-- Page 14
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 14), 'test_spgist_idx');

--
-- Page 15
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 15), 'test_spgist_idx');

--
-- Page 16
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 16), 'test_spgist_idx');

--
--
-- Drop a test table for quad tree
--
DROP TABLE test_spgist;


--
--
--
--  ______            __         ___   ___    ____  ____
-- /_  __/___   ___  / /_       / _ \ / _ \  / __/ / __/
--  / /  / -_) (_-< / __/      / ___// , _/ / _/  / _/
-- /_/   \__/ /___/ \__/      /_/   /_/|_| /___/ /_/
--
--
--
--
-- Create a test table and SP-GiST index
--
CREATE TABLE test_spgist (name varchar(256), number float);

--
--
-- Create index to test
--
CREATE INDEX test_spgist_idx ON test_spgist USING spgist(name);

--
--
-- Add test data (1000 rows)
--
INSERT INTO test_spgist (name, number) VALUES
('Chauncey', 124.125), ('Anya', 124.125), ('Antonio', 124.125), ('Dell', 124.125), ('Arlen', 124.125), ('Charles', 124.125), ('Eun', 124.125), ('Dante', 124.125), ('Dwain', 124.125), ('Claud', 124.125), ('Amira', 124.125), ('Antoine', 124.125), ('Clarence', 124.125), ('Cris', 124.125), ('Dayna', 124.125), ('Edda', 124.125), ('Cherish', 124.125), ('Chang', 124.125), ('Alvina', 124.125), ('Cornelius', 124.125), ('Eloy', 124.125), ('Darius', 124.125), ('Alexandra', 124.125), ('Britany', 124.125), ('Danial', 124.125), ('Elissa', 124.125), ('Bryan', 124.125), ('Eloisa', 124.125), ('Allie', 124.125), ('Amalia', 124.125), ('Elvie', 124.125), ('Erika', 124.125), ('Corrine', 124.125), ('Deena', 124.125), ('Ellie', 124.125), ('Bobbie', 124.125), ('Debroah', 124.125), ('Bridget', 124.125), ('Emory', 124.125), ('Derick', 124.125), ('Ethelyn', 124.125), ('Darren', 124.125), ('Enriqueta', 124.125), ('Chasidy', 124.125), ('Estefana', 124.125), ('Ester', 124.125), ('Elaina', 124.125), ('Eufemia', 124.125), ('Chiquita', 124.125), ('Coralee', 124.125), ('Corine', 124.125), ('Angelia', 124.125), ('Christen', 124.125), ('Anja', 124.125), ('Delicia', 124.125), ('Barbra', 124.125), ('Chia', 124.125), ('Aron', 124.125), ('Chara', 124.125), ('Dora', 124.125), ('Agnus', 124.125), ('Billy', 124.125), ('Bobbye', 124.125), ('Amal', 124.125), ('Bart', 124.125), ('Claudia', 124.125), ('Berry', 124.125), ('Apolonia', 124.125), ('Elmo', 124.125), ('Coretta', 124.125), ('Candi', 124.125), ('Alverta', 124.125), ('Alphonse', 124.125), ('Bobbi', 124.125), ('Bee', 124.125), ('Charity', 124.125), ('Elijah', 124.125), ('Dianna', 124.125), ('Bao', 124.125), ('Darrick', 124.125), ('Domenica', 124.125), ('Arnetta', 124.125), ('Carlos', 124.125), ('Antione', 124.125), ('Darline', 124.125), ('Claribel', 124.125), ('Carmen', 124.125), ('Carmela', 124.125), ('Doris', 124.125), ('Bong', 124.125), ('Earlie', 124.125), ('Afton', 124.125), ('Adolfo', 124.125), ('Corrin', 124.125), ('Andrea', 124.125), ('Adrianne', 124.125), ('Dominica', 124.125), ('Emanuel', 124.125), ('Cassandra', 124.125), ('Amelia', 124.125), ('Charlyn', 124.125), ('Chante', 124.125), ('Chantell', 124.125), ('Armandina', 124.125), ('Daniela', 124.125), ('Deeanna', 124.125), ('Barrett', 124.125), ('Arnulfo', 124.125), ('Alonso', 124.125), ('Catherine', 124.125), ('Damian', 124.125), ('Allan', 124.125), ('Angelyn', 124.125), ('Dirk', 124.125), ('Calandra', 124.125), ('Clayton', 124.125), ('Denny', 124.125), ('Alane', 124.125), ('Denese', 124.125), ('Alecia', 124.125), ('Darcie', 124.125), ('Edmundo', 124.125), ('Cyril', 124.125), ('Amee', 124.125), ('Adelina', 124.125), ('Ailene', 124.125), ('Dorene', 124.125), ('Consuela', 124.125), ('Daniell', 124.125), ('Eddie', 124.125), ('Bertha', 124.125), ('Denise', 124.125), ('Evelina', 124.125), ('Douglass', 124.125), ('Bob', 124.125), ('Damon', 124.125), ('Audrie', 124.125), ('Akilah', 124.125), ('Carleen', 124.125), ('Elenore', 124.125), ('Dolores', 124.125), ('Domitila', 124.125), ('Angele', 124.125), ('Elvera', 124.125), ('Cher', 124.125), ('Ayanna', 124.125), ('Carola', 124.125), ('Dona', 124.125), ('Evalyn', 124.125), ('Alia', 124.125), ('Devona', 124.125), ('Agueda', 124.125), ('Branden', 124.125), ('Buddy', 124.125), ('Adria', 124.125), ('Colton', 124.125), ('Eugenio', 124.125), ('Carrie', 124.125), ('Alena', 124.125), ('Ettie', 124.125), ('Eileen', 124.125), ('Eve', 124.125), ('Andre', 124.125), ('Avelina', 124.125), ('Beckie', 124.125), ('Brunilda', 124.125), ('Corrie', 124.125), ('Elina', 124.125), ('Derek', 124.125), ('Cynthia', 124.125), ('Edwina', 124.125), ('Demetra', 124.125), ('Eliz', 124.125), ('Emely', 124.125), ('Bill', 124.125), ('Damien', 124.125), ('Eugene', 124.125), ('Amiee', 124.125), ('Britney', 124.125), ('Angla', 124.125), ('Cherelle', 124.125), ('Annabelle', 124.125), ('Earline', 124.125), ('Cyndi', 124.125), ('Angelique', 124.125), ('Dalia', 124.125), ('Eldora', 124.125), ('Amada', 124.125), ('Cole', 124.125), ('Alexia', 124.125), ('Aurelio', 124.125), ('Ayesha', 124.125), ('Alfredia', 124.125), ('Chanelle', 124.125), ('Alison', 124.125), ('Elfreda', 124.125), ('Annett', 124.125), ('Arron', 124.125), ('Basil', 124.125), ('Eliseo', 124.125), ('Belle', 124.125), ('Emily', 124.125), ('Abram', 124.125), ('Deloris', 124.125), ('Adelaida', 124.125), ('Dayle', 124.125), ('Eleanora', 124.125), ('Dennis', 124.125), ('Clarinda', 124.125), ('Carmina', 124.125), ('Bo', 124.125), ('Annelle', 124.125), ('Arla', 124.125), ('Ehtel', 124.125), ('Babara', 124.125), ('Belkis', 124.125), ('Alden', 124.125), ('Chi', 124.125), ('Deonna', 124.125), ('Derrick', 124.125), ('Emerita', 124.125), ('Dorcas', 124.125), ('Chandra', 124.125), ('Carlo', 124.125), ('Carletta', 124.125), ('Collen', 124.125), ('Blair', 124.125), ('Deirdre', 124.125), ('Concepcion', 124.125), ('Carmelina', 124.125), ('Alva', 124.125), ('Alissa', 124.125), ('Clementina', 124.125), ('Carolee', 124.125), ('Bert', 124.125), ('Chassidy', 124.125), ('Earlene', 124.125), ('Alysha', 124.125), ('Bev', 124.125), ('Alexis', 124.125), ('Donny', 124.125), ('Carl', 124.125), ('Carlota', 124.125), ('Aide', 124.125), ('Arthur', 124.125), ('Brett', 124.125), ('Clifford', 124.125), ('Arlinda', 124.125), ('Dario', 124.125), ('Elia', 124.125), ('Donald', 124.125), ('Anissa', 124.125), ('Brianne', 124.125), ('Enedina', 124.125), ('Ann', 124.125), ('Dusty', 124.125), ('Collette', 124.125), ('Chu', 124.125), ('Emilie', 124.125), ('Arnita', 124.125), ('Clarita', 124.125), ('Dannielle', 124.125), ('Amina', 124.125), ('Alan', 124.125), ('Altha', 124.125), ('Epifania', 124.125), ('Eleonora', 124.125), ('Diego', 124.125), ('Anibal', 124.125), ('Cherryl', 124.125), ('Beulah', 124.125), ('Douglas', 124.125), ('Cathy', 124.125), ('Cameron', 124.125), ('Benito', 124.125), ('Erlinda', 124.125), ('Anderson', 124.125), ('Edmund', 124.125), ('Elouise', 124.125), ('Allyson', 124.125), ('Altagracia', 124.125), ('Alejandra', 124.125), ('Cody', 124.125), ('Angie', 124.125), ('Donya', 124.125), ('Dani', 124.125), ('Andree', 124.125), ('Amanda', 124.125), ('Beula', 124.125), ('Darrin', 124.125), ('Cassondra', 124.125), ('Connie', 124.125), ('Dot', 124.125), ('Charis', 124.125), ('Delta', 124.125), ('Brenton', 124.125), ('Daron', 124.125), ('Curtis', 124.125), ('Abby', 124.125), ('Alfredo', 124.125), ('Adelia', 124.125), ('Brooke', 124.125), ('Brook', 124.125), ('Danae', 124.125), ('Carlie', 124.125), ('Emma', 124.125), ('Carry', 124.125), ('Dorathy', 124.125), ('Caleb', 124.125), ('Bernita', 124.125), ('Angelo', 124.125), ('Dorla', 124.125), ('Carli', 124.125), ('Clementine', 124.125), ('Eleonor', 124.125), ('Ed', 124.125), ('Annabell', 124.125), ('Christopher', 124.125), ('Debrah', 124.125), ('Emmie', 124.125), ('Candida', 124.125), ('Ernie', 124.125), ('Eleanor', 124.125), ('Deshawn', 124.125), ('Chas', 124.125), ('Conchita', 124.125), ('Evangelina', 124.125), ('Eulah', 124.125), ('Celinda', 124.125), ('Adela', 124.125), ('Elanor', 124.125), ('Brandy', 124.125), ('Corey', 124.125), ('Del', 124.125), ('Cathi', 124.125), ('Dawne', 124.125), ('Christena', 124.125), ('Bronwyn', 124.125), ('Dewayne', 124.125), ('Cathrine', 124.125), ('Ashlea', 124.125), ('Elna', 124.125), ('Andria', 124.125), ('Brady', 124.125), ('Beatriz', 124.125), ('Earl', 124.125), ('Elvira', 124.125), ('Elsy', 124.125), ('Cristopher', 124.125), ('Emile', 124.125), ('Asia', 124.125), ('Eloise', 124.125), ('Chantelle', 124.125), ('Enrique', 124.125), ('Anastacia', 124.125), ('Deloise', 124.125), ('Charissa', 124.125), ('Danille', 124.125), ('Delmer', 124.125), ('Camille', 124.125), ('Aubrey', 124.125), ('Alexandria', 124.125), ('Celesta', 124.125), ('Delora', 124.125), ('Emmanuel', 124.125), ('Dreama', 124.125), ('Brendan', 124.125), ('Coreen', 124.125), ('Argelia', 124.125), ('Brittney', 124.125), ('Etha', 124.125), ('Alysia', 124.125), ('Dorsey', 124.125), ('Dick', 124.125), ('Evelia', 124.125), ('Carmella', 124.125), ('Alita', 124.125), ('Eddy', 124.125), ('Demetrice', 124.125), ('Erma', 124.125), ('Bennie', 124.125), ('Cheyenne', 124.125), ('Abdul', 124.125), ('Dorris', 124.125), ('Brenna', 124.125), ('Dina', 124.125), ('Breanne', 124.125), ('Dino', 124.125), ('Ebonie', 124.125), ('Danuta', 124.125), ('Annika', 124.125), ('Barbara', 124.125), ('Echo', 124.125), ('Brendon', 124.125), ('Adrienne', 124.125), ('Angelica', 124.125), ('Brad', 124.125), ('Analisa', 124.125), ('Clifton', 124.125), ('Callie', 124.125);

DELETE FROM test_spgist WHERE name IN
('Andree', 'Eileen', 'Ettie', 'Alita', 'Ernie', 'Brady', 'Del', 'Carmella', 'Dorla', 'Dolores', 'Elanor', 'Charissa', 'Cole', 'Arlinda', 'Eddy', 'Agnus', 'Chang', 'Alissa', 'Cherryl', 'Altha', 'Doris', 'Agueda', 'Elvie', 'Dorathy', 'Anderson', 'Cornelius', 'Britney', 'Cyndi', 'Antoine', 'Dell', 'Bev', 'Argelia', 'Amada', 'Daniell', 'Carmina', 'Ester', 'Bennie', 'Akilah', 'Epifania', 'Benito', 'Dani', 'Callie', 'Eldora', 'Bart', 'Afton', 'Aubrey', 'Alejandra', 'Evangelina', 'Breanne', 'Bobbie', 'Dawne', 'Andrea', 'Cher', 'Dannielle', 'Brunilda', 'Chante', 'Celesta', 'Cherelle', 'Bo', 'Edmund', 'Claudia', 'Bertha', 'Dina', 'Chas', 'Annabelle', 'Chantelle', 'Demetrice', 'Chantell', 'Estefana', 'Enriqueta', 'Danial', 'Coreen', 'Eleanora', 'Dayle', 'Emory', 'Earl', 'Carl', 'Emmanuel', 'Apolonia', 'Carmelina');

INSERT INTO test_spgist (name, number) VALUES
('Dulcie', 124.125), ('Betsey', 124.125), ('Barbie', 124.125), ('Delilah', 124.125), ('Alleen', 124.125), ('Alvin', 124.125), ('Etsuko', 124.125), ('Christal', 124.125), ('Adaline', 124.125), ('Donte', 124.125), ('Cherise', 124.125), ('Annamae', 124.125), ('Casie', 124.125), ('Chery', 124.125), ('Bobby', 124.125), ('Carlee', 124.125), ('Crystle', 124.125), ('Deangelo', 124.125), ('Enda', 124.125), ('Cecil', 124.125), ('Bari', 124.125), ('Donn', 124.125), ('Asley', 124.125), ('Carina', 124.125), ('Elda', 124.125), ('Benjamin', 124.125), ('Byron', 124.125), ('Digna', 124.125), ('Christa', 124.125), ('Arnoldo', 124.125), ('Ahmed', 124.125), ('Dalila', 124.125), ('Cyrstal', 124.125), ('Diann', 124.125), ('Damaris', 124.125), ('Antone', 124.125), ('Barbar', 124.125), ('Bette', 124.125), ('Della', 124.125), ('Angella', 124.125), ('Demetrius', 124.125), ('Abe', 124.125), ('Annis', 124.125), ('Bernice', 124.125), ('Elena', 124.125), ('Bethel', 124.125), ('Ana', 124.125), ('Dia', 124.125), ('Alonzo', 124.125), ('Drema', 124.125), ('Cecilia', 124.125), ('Ardath', 124.125), ('Carline', 124.125), ('Anglea', 124.125), ('Alise', 124.125), ('Erasmo', 124.125), ('Cedrick', 124.125), ('Ardelle', 124.125), ('Buck', 124.125), ('Anette', 124.125), ('Caryl', 124.125), ('Dacia', 124.125), ('Ardell', 124.125), ('Edris', 124.125), ('Adena', 124.125), ('Ebony', 124.125), ('Asha', 124.125), ('Deb', 124.125), ('Ethelene', 124.125), ('Diedra', 124.125), ('Boris', 124.125), ('Cathern', 124.125), ('Alline', 124.125), ('Almeda', 124.125), ('Ashton', 124.125), ('Criselda', 124.125), ('Ella', 124.125), ('Astrid', 124.125), ('Burton', 124.125), ('Bettie', 124.125), ('Dorothy', 124.125), ('Elizabet', 124.125), ('Emiko', 124.125), ('Caren', 124.125), ('Cordia', 124.125), ('Carlton', 124.125), ('Colby', 124.125), ('Armando', 124.125), ('Bryon', 124.125), ('Claudette', 124.125), ('Candra', 124.125), ('Efren', 124.125), ('Cathleen', 124.125), ('Carolin', 124.125), ('Bella', 124.125), ('Beth', 124.125), ('Carylon', 124.125), ('Donnie', 124.125), ('Christian', 124.125), ('Beatrice', 124.125), ('Bea', 124.125), ('Akiko', 124.125), ('Clemmie', 124.125), ('Denita', 124.125), ('Cherlyn', 124.125), ('Antonietta', 124.125), ('Dodie', 124.125), ('Deann', 124.125), ('Elvina', 124.125), ('Easter', 124.125), ('Candyce', 124.125), ('Carmine', 124.125), ('Catalina', 124.125), ('Dottie', 124.125), ('Aura', 124.125), ('Cira', 124.125), ('Carolina', 124.125), ('Anisa', 124.125), ('Cindy', 124.125), ('Eartha', 124.125), ('Donita', 124.125), ('Ashely', 124.125), ('Adell', 124.125), ('Era', 124.125), ('Elida', 124.125), ('Crysta', 124.125), ('Amber', 124.125), ('Brittni', 124.125), ('Carolyne', 124.125), ('Brandie', 124.125), ('Dean', 124.125), ('Camie', 124.125), ('Adelaide', 124.125), ('Doreen', 124.125), ('Aundrea', 124.125), ('Don', 124.125), ('Etta', 124.125), ('Adina', 124.125), ('Anamaria', 124.125), ('August', 124.125), ('Erline', 124.125), ('Bradford', 124.125), ('Dotty', 124.125), ('Carissa', 124.125), ('Candie', 124.125), ('Catherin', 124.125), ('Colin', 124.125), ('Denice', 124.125), ('Brain', 124.125), ('Debera', 124.125), ('Britni', 124.125), ('Alayna', 124.125), ('Amberly', 124.125), ('Deandrea', 124.125), ('Belia', 124.125), ('Alla', 124.125), ('Dawna', 124.125), ('Arica', 124.125), ('Carlene', 124.125), ('Clarisa', 124.125), ('Emmitt', 124.125), ('Bennett', 124.125), ('Darwin', 124.125), ('Cleopatra', 124.125), ('Adam', 124.125), ('Elvis', 124.125), ('Alicia', 124.125), ('Elise', 124.125), ('Diane', 124.125), ('Calvin', 124.125), ('Cristine', 124.125), ('Chase', 124.125), ('Cathie', 124.125), ('Enid', 124.125), ('Bulah', 124.125), ('Chae', 124.125), ('Elisha', 124.125), ('Dara', 124.125), ('Briana', 124.125), ('Chasity', 124.125), ('Delfina', 124.125), ('Chet', 124.125), ('Avril', 124.125), ('Donnell', 124.125), ('Alyson', 124.125), ('Benton', 124.125), ('Chester', 124.125), ('Crystal', 124.125), ('Antonia', 124.125), ('Chastity', 124.125), ('Caroll', 124.125), ('Dorethea', 124.125), ('Emeline', 124.125), ('Dwana', 124.125), ('Audrey', 124.125), ('Andy', 124.125), ('Dominic', 124.125), ('Dianne', 124.125), ('Claudie', 124.125), ('Adolph', 124.125), ('Albert', 124.125), ('April', 124.125), ('Corinna', 124.125), ('Ellyn', 124.125), ('Cruz', 124.125), ('Clyde', 124.125), ('Cheree', 124.125), ('Dede', 124.125), ('Cassi', 124.125), ('Deidre', 124.125), ('Annmarie', 124.125), ('Delsie', 124.125), ('Cordell', 124.125), ('Elba', 124.125), ('Alona', 124.125), ('Ada', 124.125), ('Elma', 124.125), ('Daysi', 124.125), ('Cherie', 124.125), ('Arturo', 124.125), ('Daina', 124.125), ('Aimee', 124.125), ('Earle', 124.125), ('Adrian', 124.125), ('Alisia', 124.125), ('Cristin', 124.125), ('Danyell', 124.125), ('Benedict', 124.125), ('Anisha', 124.125), ('Charleen', 124.125), ('Annalee', 124.125), ('Candace', 124.125), ('Ervin', 124.125), ('Daisy', 124.125), ('Alfred', 124.125), ('Eura', 124.125), ('Dovie', 124.125), ('Darlena', 124.125), ('Charline', 124.125), ('Demarcus', 124.125), ('Bernetta', 124.125), ('Athena', 124.125), ('Cary', 124.125), ('Alysa', 124.125), ('Arline', 124.125), ('Augustina', 124.125), ('Desmond', 124.125), ('Delinda', 124.125), ('Burma', 124.125), ('Brandi', 124.125), ('Alethia', 124.125), ('Diana', 124.125), ('Dawn', 124.125), ('Elroy', 124.125), ('Erick', 124.125), ('Annetta', 124.125), ('Clotilde', 124.125), ('Alta', 124.125), ('Alycia', 124.125), ('Catharine', 124.125), ('Ellan', 124.125), ('Belinda', 124.125), ('Chelsey', 124.125), ('Eldon', 124.125), ('Candice', 124.125), ('Dian', 124.125), ('Corie', 124.125), ('Dagmar', 124.125), ('Dorotha', 124.125), ('Crista', 124.125), ('Dessie', 124.125), ('Dominique', 124.125), ('Abraham', 124.125), ('Bruce', 124.125), ('Cecila', 124.125), ('Cindi', 124.125), ('Erna', 124.125), ('Eneida', 124.125), ('Antionette', 124.125), ('Casandra', 124.125), ('Chere', 124.125), ('Cara', 124.125), ('Cedric', 124.125), ('Corinne', 124.125), ('Celeste', 124.125), ('Clinton', 124.125), ('Dinorah', 124.125), ('Cyrus', 124.125), ('Chaya', 124.125), ('Andera', 124.125), ('Clelia', 124.125), ('Dori', 124.125), ('Alfreda', 124.125), ('Eduardo', 124.125), ('Debby', 124.125), ('Claudio', 124.125), ('Aurore', 124.125), ('Drew', 124.125), ('Clement', 124.125), ('Concha', 124.125), ('Ardelia', 124.125), ('Bell', 124.125), ('Dinah', 124.125), ('Caryn', 124.125), ('Charise', 124.125), ('Angel', 124.125), ('Angeline', 124.125), ('Esmeralda', 124.125), ('Arlette', 124.125), ('Darron', 124.125), ('Eusebio', 124.125), ('Angelic', 124.125), ('Caroline', 124.125), ('Cayla', 124.125), ('Carla', 124.125), ('Allen', 124.125), ('Aretha', 124.125), ('Arvilla', 124.125), ('Despina', 124.125), ('Camellia', 124.125), ('Chantay', 124.125), ('Angelita', 124.125), ('Azalee', 124.125), ('Delaine', 124.125), ('Diamond', 124.125), ('Elias', 124.125), ('Asuncion', 124.125), ('Emmy', 124.125), ('Cami', 124.125), ('Cleora', 124.125), ('Darrel', 124.125), ('Danita', 124.125), ('Dusti', 124.125), ('Eusebia', 124.125), ('Effie', 124.125), ('Desiree', 124.125), ('Anthony', 124.125), ('Erica', 124.125), ('Clarissa', 124.125), ('Esteban', 124.125), ('Cathey', 124.125), ('Deja', 124.125), ('Chantal', 124.125), ('Dennise', 124.125), ('Contessa', 124.125), ('Edgar', 124.125), ('Dyan', 124.125), ('Cinthia', 124.125), ('Denna', 124.125), ('Eleonore', 124.125), ('Agripina', 124.125), ('Delbert', 124.125), ('Catheryn', 124.125), ('Cherilyn', 124.125), ('Assunta', 124.125), ('Cristina', 124.125), ('Carlena', 124.125), ('Azucena', 124.125), ('Earleen', 124.125), ('Annette', 124.125), ('Danyelle', 124.125), ('Celestine', 124.125), ('Chelsea', 124.125), ('Betty', 124.125), ('Deane', 124.125), ('Creola', 124.125), ('Elinore', 124.125), ('Althea', 124.125), ('Cuc', 124.125), ('Clare', 124.125), ('Charlesetta', 124.125), ('Carita', 124.125), ('Emmaline', 124.125), ('Delphia', 124.125), ('Danyel', 124.125), ('Daphne', 124.125), ('Angelika', 124.125), ('Cierra', 124.125), ('Antony', 124.125), ('Daine', 124.125), ('Anabel', 124.125), ('Bernardine', 124.125), ('Cecily', 124.125), ('Dewey', 124.125), ('Christina', 124.125), ('Catarina', 124.125), ('Emmett', 124.125), ('Annemarie', 124.125), ('Araceli', 124.125), ('Collin', 124.125), ('Bridgett', 124.125), ('Barb', 124.125), ('Deana', 124.125), ('Brigida', 124.125), ('Emilee', 124.125), ('Alec', 124.125), ('Daphine', 124.125), ('Adan', 124.125), ('Arden', 124.125), ('Buster', 124.125);

DELETE FROM test_spgist WHERE name IN
('Assunta', 'Deann', 'Dawna', 'Despina', 'Delilah', 'Carissa', 'Barbie', 'Dovie', 'Elda', 'Corinne', 'Bennett', 'Alycia', 'Eneida', 'Alethia', 'Asha', 'Emmy', 'Belinda', 'Bryon', 'Cruz', 'Elise', 'Carolyne', 'Aimee', 'Crystle', 'Bradford', 'Brandi', 'Audrey', 'Chester', 'Cleopatra', 'Efren', 'Dodie', 'Aura', 'Angelika', 'Charlesetta', 'Annalee', 'Elias', 'Eldon', 'Denita', 'Deana', 'Dinorah', 'Delfina', 'Christa', 'Elba', 'Elizabet', 'Arlette', 'Dominic', 'Dia', 'Adelaide', 'Dotty', 'Abraham', 'Eduardo', 'Cristine', 'Dori', 'Dede', 'Chaya', 'Bobby', 'Crysta', 'Angella', 'Charline', 'Aretha', 'Bettie', 'Diedra', 'Adan', 'Anisa', 'Etsuko', 'Elida', 'Doreen', 'Alysa', 'Buster', 'Annis', 'Donn', 'Cinthia', 'Debera', 'Caryn', 'Clemmie', 'Annemarie', 'Deane', 'Denice', 'Claudie', 'Donita', 'Brittni');

INSERT INTO test_spgist (name, number) VALUES
('Carolann', 124.125), ('Archie', 124.125), ('Brittaney', 124.125), ('Edelmira', 124.125), ('Ciera', 124.125), ('Duane', 124.125), ('Casey', 124.125), ('Dolly', 124.125), ('Dorthy', 124.125), ('Daniella', 124.125), ('Destiny', 124.125), ('Elenora', 124.125), ('Armanda', 124.125), ('Ardella', 124.125), ('Charlott', 124.125), ('Elnora', 124.125), ('Bruna', 124.125), ('Carey', 124.125), ('Aldo', 124.125), ('Alanna', 124.125), ('Caridad', 124.125), ('Darnell', 124.125), ('Anitra', 124.125), ('Delois', 124.125), ('Conception', 124.125), ('Belen', 124.125), ('Chad', 124.125), ('Darby', 124.125), ('Alisha', 124.125), ('Elidia', 124.125), ('Beau', 124.125), ('Elfriede', 124.125), ('Emilia', 124.125), ('Elliott', 124.125), ('Elke', 124.125), ('Daren', 124.125), ('Coleen', 124.125), ('Carolyn', 124.125), ('Danny', 124.125), ('Armand', 124.125), ('Delisa', 124.125), ('Donna', 124.125), ('Bibi', 124.125), ('Essie', 124.125), ('Carroll', 124.125), ('Cheryl', 124.125), ('Daria', 124.125), ('Christie', 124.125), ('Cletus', 124.125), ('Desire', 124.125), ('Cesar', 124.125), ('Bettye', 124.125), ('Eldridge', 124.125), ('Erlene', 124.125), ('Donella', 124.125), ('Brittany', 124.125), ('Charla', 124.125), ('Brittny', 124.125), ('Adalberto', 124.125), ('Delphine', 124.125), ('Ardith', 124.125), ('Doretha', 124.125), ('Colleen', 124.125), ('Carmelia', 124.125), ('Drusilla', 124.125), ('Corazon', 124.125), ('Elin', 124.125), ('Bonita', 124.125), ('Estrella', 124.125), ('Estella', 124.125), ('Dee', 124.125), ('Candelaria', 124.125), ('Divina', 124.125), ('Catrina', 124.125), ('Emery', 124.125), ('Billi', 124.125), ('Darcey', 124.125), ('Brock', 124.125), ('Cleta', 124.125), ('Aurelia', 124.125), ('Adelle', 124.125), ('Dulce', 124.125), ('Allene', 124.125), ('Andra', 124.125), ('Darleen', 124.125), ('Berna', 124.125), ('Carisa', 124.125), ('Codi', 124.125), ('Elwood', 124.125), ('Alex', 124.125), ('Amado', 124.125), ('Antoinette', 124.125), ('Demetria', 124.125), ('Clemencia', 124.125), ('Beata', 124.125), ('Audry', 124.125), ('Amparo', 124.125), ('Blake', 124.125), ('Euna', 124.125), ('Carri', 124.125), ('Apryl', 124.125), ('Cornelia', 124.125), ('Cecelia', 124.125), ('Brooks', 124.125), ('Dominque', 124.125), ('Ardis', 124.125), ('Coleman', 124.125), ('Dixie', 124.125), ('Arianna', 124.125), ('Danelle', 124.125), ('Christiane', 124.125), ('Augustine', 124.125), ('Anne', 124.125), ('Doreatha', 124.125), ('Broderick', 124.125), ('Agustin', 124.125), ('Ashly', 124.125), ('Elizbeth', 124.125), ('Amy', 124.125), ('Aleen', 124.125), ('Cristen', 124.125), ('Ariel', 124.125), ('Autumn', 124.125), ('Blythe', 124.125), ('Britteny', 124.125), ('Elsa', 124.125), ('Anna', 124.125), ('Cheryle', 124.125), ('Chong', 124.125), ('Elsie', 124.125), ('Barry', 124.125), ('Azzie', 124.125), ('Audie', 124.125), ('Alix', 124.125), ('Emelia', 124.125), ('Donette', 124.125), ('Cherry', 124.125), ('Danette', 124.125), ('Colette', 124.125), ('Abbey', 124.125), ('Adella', 124.125), ('Alethea', 124.125), ('Buffy', 124.125), ('Ernesto', 124.125), ('Ashlee', 124.125), ('Dung', 124.125), ('Deedee', 124.125), ('Chantel', 124.125), ('Brenda', 124.125), ('Chadwick', 124.125), ('Chung', 124.125), ('Ellsworth', 124.125), ('Ellena', 124.125), ('Dane', 124.125), ('Bianca', 124.125), ('Ellamae', 124.125), ('Beatris', 124.125), ('Christene', 124.125), ('Dimple', 124.125), ('Erik', 124.125), ('Estelle', 124.125), ('Candy', 124.125), ('Calista', 124.125), ('Ellen', 124.125), ('Caitlyn', 124.125), ('Barton', 124.125), ('Buena', 124.125), ('Brittani', 124.125), ('Ami', 124.125), ('Donnette', 124.125), ('Delma', 124.125), ('Annita', 124.125), ('Al', 124.125), ('Amos', 124.125), ('Abbie', 124.125), ('Ashli', 124.125), ('Earnestine', 124.125), ('Ashlie', 124.125), ('Devorah', 124.125), ('Cecile', 124.125), ('Claire', 124.125), ('Domonique', 124.125), ('Clay', 124.125), ('Daniel', 124.125), ('Dierdre', 124.125), ('Christia', 124.125), ('Arielle', 124.125), ('Cinderella', 124.125), ('Babette', 124.125), ('Albina', 124.125), ('Claude', 124.125), ('Bruno', 124.125), ('Bertram', 124.125), ('Ericka', 124.125), ('Corina', 124.125), ('Donnetta', 124.125), ('Evangeline', 124.125), ('Carmelo', 124.125), ('Aleida', 124.125), ('Emilio', 124.125), ('Eden', 124.125), ('Delena', 124.125), ('Elizebeth', 124.125), ('Adriane', 124.125), ('Beverlee', 124.125), ('Ema', 124.125), ('Dania', 124.125), ('Bernie', 124.125), ('Alda', 124.125), ('Eugena', 124.125), ('Emerald', 124.125), ('Buford', 124.125), ('Damion', 124.125), ('Ethan', 124.125), ('Devin', 124.125), ('Claris', 124.125), ('Britta', 124.125), ('Carlotta', 124.125), ('Cori', 124.125), ('Else', 124.125), ('Eunice', 124.125), ('Courtney', 124.125), ('Erin', 124.125), ('Dorine', 124.125), ('Cammy', 124.125), ('Birgit', 124.125), ('Eli', 124.125), ('Eilene', 124.125), ('Delmy', 124.125), ('Cleo', 124.125), ('Denisse', 124.125), ('Branda', 124.125), ('Brice', 124.125), ('Annice', 124.125), ('Burt', 124.125), ('Elois', 124.125), ('Daisey', 124.125), ('Dalton', 124.125), ('Claudine', 124.125), ('Alexander', 124.125), ('Clarice', 124.125), ('Camila', 124.125), ('Evelynn', 124.125), ('Alfonzo', 124.125), ('Bryanna', 124.125), ('Boyd', 124.125), ('Elease', 124.125), ('Edythe', 124.125), ('Darlene', 124.125), ('Charlsie', 124.125), ('Doretta', 124.125), ('Coy', 124.125), ('Debbi', 124.125), ('Ammie', 124.125), ('Chanel', 124.125), ('Erich', 124.125), ('Ai', 124.125), ('Erwin', 124.125), ('Cristobal', 124.125), ('Ali', 124.125), ('Beverly', 124.125), ('Andreas', 124.125), ('Amie', 124.125), ('Deanna', 124.125), ('Constance', 124.125), ('Curt', 124.125), ('Carol', 124.125), ('Delores', 124.125), ('Dana', 124.125), ('Domenic', 124.125), ('Chuck', 124.125), ('Darci', 124.125), ('Abigail', 124.125), ('Dann', 124.125), ('Brianna', 124.125), ('Estela', 124.125), ('Aline', 124.125), ('Ethel', 124.125), ('Deidra', 124.125), ('Everett', 124.125), ('Denis', 124.125), ('Chris', 124.125), ('Coralie', 124.125), ('Aracely', 124.125), ('Aida', 124.125), ('Coral', 124.125), ('Bertie', 124.125), ('Elisa', 124.125), ('Bula', 124.125), ('Ernest', 124.125), ('Blanche', 124.125), ('Diedre', 124.125), ('Ciara', 124.125), ('Edwin', 124.125), ('Belva', 124.125), ('Annabel', 124.125), ('Candis', 124.125), ('Ching', 124.125), ('Angela', 124.125), ('Bettyann', 124.125), ('Barabara', 124.125), ('Elayne', 124.125), ('Deon', 124.125), ('Elwanda', 124.125), ('Eliza', 124.125), ('Craig', 124.125), ('Chan', 124.125), ('Benny', 124.125), ('An', 124.125), ('Chanda', 124.125), ('Dion', 124.125), ('Beryl', 124.125), ('Ashleigh', 124.125), ('Ayako', 124.125), ('Artie', 124.125), ('Ethyl', 124.125), ('Cari', 124.125), ('Dorothea', 124.125), ('Darcel', 124.125), ('Audra', 124.125), ('Ayana', 124.125), ('Charlene', 124.125), ('Corliss', 124.125), ('Blanca', 124.125), ('Doug', 124.125), ('Alexa', 124.125), ('Brande', 124.125), ('Bradley', 124.125), ('Bess', 124.125), ('Aleisha', 124.125), ('Charmaine', 124.125), ('Charlena', 124.125), ('Eula', 124.125), ('Elene', 124.125), ('Delmar', 124.125), ('Cherri', 124.125), ('Elli', 124.125), ('Conrad', 124.125), ('Alesha', 124.125), ('Adele', 124.125), ('Dena', 124.125), ('Adriene', 124.125), ('Catina', 124.125), ('Anjanette', 124.125), ('Argentina', 124.125), ('Elza', 124.125), ('Chelsie', 124.125), ('Arnette', 124.125), ('Debi', 124.125), ('Daniele', 124.125), ('Caron', 124.125), ('Eboni', 124.125), ('America', 124.125), ('Audrea', 124.125), ('Alesia', 124.125), ('Elden', 124.125), ('Brittanie', 124.125), ('Bok', 124.125), ('Cathryn', 124.125), ('Agatha', 124.125), ('Debbra', 124.125), ('Angle', 124.125), ('Dominick', 124.125), ('Cheri', 124.125), ('Alejandrina', 124.125), ('David', 124.125), ('Elmer', 124.125), ('Corrinne', 124.125), ('Aurora', 124.125), ('Dexter', 124.125), ('Arianne', 124.125), ('Ben', 124.125), ('Cinda', 124.125), ('Antonina', 124.125), ('Candance', 124.125), ('Edra', 124.125), ('Anton', 124.125), ('Alberto', 124.125), ('Billye', 124.125), ('Chana', 124.125), ('Denyse', 124.125), ('Avery', 124.125), ('Edyth', 124.125), ('Antonetta', 124.125), ('Benita', 124.125), ('Cassey', 124.125), ('Eric', 124.125), ('Adriana', 124.125), ('Celsa', 124.125), ('Charlotte', 124.125), ('Deanne', 124.125), ('Ernestina', 124.125), ('Chun', 124.125), ('Christine', 124.125), ('Beaulah', 124.125), ('Charmain', 124.125), ('Breanna', 124.125), ('Christiana', 124.125), ('Brant', 124.125), ('Corrina', 124.125);

DELETE FROM test_spgist WHERE name IN
('Al', 'Dena', 'Daniele', 'Ema', 'Delphine', 'Devin', 'Caitlyn', 'Clarice', 'Catrina', 'Elsie', 'Amparo', 'Beverly', 'Brooks', 'Angle', 'Ardella', 'Charmain', 'Brittaney', 'Augustine', 'Agatha', 'Eula', 'Brittani', 'Adele', 'Doretta', 'Bettyann', 'Carri', 'Cheri', 'Anjanette', 'Debbi', 'Cletus', 'Brittanie', 'Argentina', 'Aleisha', 'Anna', 'Edelmira', 'Delmy', 'Elliott', 'Brittany', 'Essie', 'Elli', 'Alesia', 'Ashleigh', 'Darci', 'An', 'Cinderella', 'Ellamae', 'Desire', 'Divina', 'Christene', 'Annice', 'Ashlee', 'Constance', 'Alejandrina', 'Erlene', 'Aleen', 'Donella', 'Buena', 'Donette', 'Bruna', 'Daisey', 'Ashli', 'Benny', 'Audrea', 'Eldridge', 'Alexa', 'Elidia', 'Ellsworth', 'Aracely', 'Danette', 'Alex', 'Carroll', 'Cori', 'Chuck', 'Elayne', 'Delma', 'Corrina', 'Dann', 'Else', 'Ethyl', 'Cari', 'Erwin');

INSERT INTO test_spgist (name, number) VALUES
('Bernadette', 124.125), ('Eleni', 124.125), ('Annamaria', 124.125), ('Deloras', 124.125), ('Birdie', 124.125), ('Billie', 124.125), ('Cordie', 124.125), ('Corene', 124.125), ('Cristy', 124.125), ('Burl', 124.125), ('Bret', 124.125), ('Brigitte', 124.125), ('Celine', 124.125), ('Debra', 124.125), ('Basilia', 124.125), ('Aja', 124.125), ('Albertha', 124.125), ('Anika', 124.125), ('Adrien', 124.125), ('Alejandro', 124.125), ('Booker', 124.125), ('Cassy', 124.125), ('Ceola', 124.125), ('Eleanore', 124.125), ('Eustolia', 124.125), ('Chrissy', 124.125), ('Celestina', 124.125), ('Edie', 124.125), ('Collene', 124.125), ('Cora', 124.125), ('Ellis', 124.125), ('Ernestine', 124.125), ('Arminda', 124.125), ('Emogene', 124.125), ('Antwan', 124.125), ('Chance', 124.125), ('Celena', 124.125), ('Donovan', 124.125), ('Christinia', 124.125), ('Elodia', 124.125), ('Elisabeth', 124.125), ('Angelena', 124.125), ('Elvia', 124.125), ('Cassaundra', 124.125), ('Deedra', 124.125), ('Clorinda', 124.125), ('Eugenia', 124.125), ('Aletha', 124.125), ('Blanch', 124.125), ('Carman', 124.125), ('Britt', 124.125), ('Angila', 124.125), ('Cortney', 124.125), ('Dale', 124.125), ('Alica', 124.125), ('Brinda', 124.125), ('Christin', 124.125), ('Delcie', 124.125), ('Eda', 124.125), ('Bernard', 124.125), ('Ela', 124.125), ('Chanell', 124.125), ('Earlean', 124.125), ('Bethany', 124.125), ('Eliana', 124.125), ('Deandre', 124.125), ('Bebe', 124.125), ('Enoch', 124.125), ('Becki', 124.125), ('Dakota', 124.125), ('Ambrose', 124.125), ('Duncan', 124.125), ('Alene', 124.125), ('Dionna', 124.125), ('Berta', 124.125), ('Art', 124.125), ('Anh', 124.125), ('Alishia', 124.125), ('Elmira', 124.125), ('Coletta', 124.125), ('Devora', 124.125), ('Delila', 124.125), ('Asa', 124.125), ('Alphonso', 124.125), ('Bernardina', 124.125), ('Breann', 124.125), ('Charley', 124.125), ('Dannie', 124.125), ('Chrystal', 124.125), ('Erinn', 124.125), ('Devon', 124.125), ('Addie', 124.125), ('Cicely', 124.125), ('Agnes', 124.125), ('Aleshia', 124.125), ('Ava', 124.125), ('Camelia', 124.125), ('Alpha', 124.125), ('Arnold', 124.125), ('Aracelis', 124.125), ('Cecille', 124.125), ('Earnest', 124.125), ('Elaine', 124.125), ('Brent', 124.125), ('Darrell', 124.125), ('Dave', 124.125), ('Christeen', 124.125), ('Augustus', 124.125), ('Dudley', 124.125), ('Elizabeth', 124.125), ('Catherina', 124.125), ('Christel', 124.125), ('Aileen', 124.125), ('Cornell', 124.125), ('Ahmad', 124.125), ('Dong', 124.125), ('Clora', 124.125), ('Bernarda', 124.125), ('Elliot', 124.125), ('Barbera', 124.125), ('Avis', 124.125), ('Dannette', 124.125), ('Arlene', 124.125), ('Betsy', 124.125), ('Charita', 124.125), ('Albertina', 124.125), ('Adah', 124.125), ('Danilo', 124.125), ('Breana', 124.125), ('Barrie', 124.125), ('Carma', 124.125), ('Doyle', 124.125), ('Darryl', 124.125), ('Emerson', 124.125), ('Alice', 124.125), ('Arlena', 124.125), ('Bettina', 124.125), ('Bailey', 124.125), ('Alyssa', 124.125), ('Ashlyn', 124.125), ('Alaina', 124.125), ('Berneice', 124.125), ('Denae', 124.125), ('Elana', 124.125), ('Arie', 124.125), ('Augusta', 124.125), ('Armida', 124.125), ('Blondell', 124.125), ('Anneliese', 124.125), ('Dorthey', 124.125), ('Celina', 124.125), ('Crissy', 124.125), ('Celia', 124.125), ('Dillon', 124.125), ('Cythia', 124.125), ('Alaine', 124.125), ('Edison', 124.125), ('Bonny', 124.125), ('Cliff', 124.125), ('Eveline', 124.125), ('Alessandra', 124.125), ('Alyse', 124.125), ('Denver', 124.125), ('Eryn', 124.125), ('Concetta', 124.125), ('Casimira', 124.125), ('Brynn', 124.125), ('Ashanti', 124.125), ('Anastasia', 124.125), ('Austin', 124.125), ('Alberta', 124.125), ('Darell', 124.125), ('Angelina', 124.125), ('Debbie', 124.125), ('Deetta', 124.125), ('Edna', 124.125), ('Charlie', 124.125), ('Delana', 124.125), ('Carly', 124.125), ('Adrianna', 124.125), ('Dalene', 124.125), ('Arlie', 124.125), ('Esperanza', 124.125), ('Bobette', 124.125), ('Bessie', 124.125), ('Aaron', 124.125), ('Drucilla', 124.125), ('Carlita', 124.125), ('Charisse', 124.125), ('Brandon', 124.125), ('Aisha', 124.125), ('Carmel', 124.125), ('Clair', 124.125), ('Aiko', 124.125), ('Bernadine', 124.125), ('Bridgette', 124.125), ('Carole', 124.125), ('Delpha', 124.125), ('Bud', 124.125), ('Claretta', 124.125), ('Claretha', 124.125), ('Carie', 124.125), ('Elinor', 124.125), ('Audria', 124.125), ('Dorie', 124.125), ('Arlyne', 124.125), ('Dominga', 124.125), ('Catrice', 124.125), ('Alma', 124.125), ('Adeline', 124.125), ('Allena', 124.125), ('Annalisa', 124.125), ('China', 124.125), ('Edith', 124.125), ('Cherrie', 124.125), ('Errol', 124.125), ('Danica', 124.125), ('Columbus', 124.125), ('Elfrieda', 124.125), ('Evelyn', 124.125), ('Danna', 124.125), ('Cristie', 124.125), ('Cristi', 124.125), ('Cortez', 124.125), ('Carter', 124.125), ('Elbert', 124.125), ('Dallas', 124.125), ('Deneen', 124.125), ('Davis', 124.125), ('Ena', 124.125), ('Classie', 124.125), ('Carolynn', 124.125), ('Cleveland', 124.125), ('Deandra', 124.125), ('Anita', 124.125), ('Alfonso', 124.125), ('Evan', 124.125), ('Bryce', 124.125), ('Dan', 124.125), ('Cory', 124.125), ('Alease', 124.125), ('Arletha', 124.125), ('Elva', 124.125), ('Darcy', 124.125), ('Dedra', 124.125), ('Clark', 124.125), ('Consuelo', 124.125), ('Aleta', 124.125), ('Deadra', 124.125), ('Carin', 124.125), ('Danika', 124.125), ('Charlette', 124.125), ('Clarine', 124.125), ('Chin', 124.125), ('Andrew', 124.125), ('Dionne', 124.125), ('Dustin', 124.125), ('Cyndy', 124.125), ('Carson', 124.125), ('Antonette', 124.125), ('Agustina', 124.125), ('Donetta', 124.125), ('Dollie', 124.125), ('Elicia', 124.125), ('Dwight', 124.125), ('Alina', 124.125), ('Carmelita', 124.125), ('Angeles', 124.125), ('Bethanie', 124.125), ('Brigid', 124.125), ('Brigette', 124.125), ('Erminia', 124.125), ('Darin', 124.125), ('Arcelia', 124.125), ('Denisha', 124.125), ('Alana', 124.125), ('Ariane', 124.125), ('Charolette', 124.125), ('Becky', 124.125), ('Evelin', 124.125), ('Annamarie', 124.125), ('Allyn', 124.125), ('Dylan', 124.125), ('Cammie', 124.125), ('Awilda', 124.125), ('Debora', 124.125), ('Davina', 124.125), ('Edward', 124.125), ('Alyce', 124.125), ('Elly', 124.125), ('Clemente', 124.125), ('Carrol', 124.125), ('Anjelica', 124.125), ('Carlyn', 124.125), ('Bree', 124.125), ('Danielle', 124.125), ('Detra', 124.125), ('Esta', 124.125), ('Elyse', 124.125), ('Berenice', 124.125), ('Elenor', 124.125), ('Annie', 124.125), ('Bernardo', 124.125), ('Ashley', 124.125), ('Dahlia', 124.125), ('Dewitt', 124.125), ('Davida', 124.125), ('Doloris', 124.125), ('Cindie', 124.125), ('Bethann', 124.125), ('Caprice', 124.125), ('Allison', 124.125), ('Camilla', 124.125), ('Carley', 124.125), ('Bonnie', 124.125), ('Doria', 124.125), ('Edmond', 124.125), ('Emelina', 124.125), ('Abel', 124.125), ('Emil', 124.125), ('Delia', 124.125), ('Cleotilde', 124.125), ('Dwayne', 124.125), ('Alba', 124.125), ('Alisa', 124.125), ('Deborah', 124.125), ('Allegra', 124.125), ('Estell', 124.125), ('Desirae', 124.125), ('Caroyln', 124.125), ('Dagny', 124.125), ('Beverley', 124.125), ('Clara', 124.125), ('Cassie', 124.125), ('Efrain', 124.125), ('Ariana', 124.125), ('Dortha', 124.125), ('Caterina', 124.125), ('Cherly', 124.125), ('Almeta', 124.125), ('Evelyne', 124.125), ('Edgardo', 124.125), ('Darla', 124.125), ('Alvera', 124.125), ('Ermelinda', 124.125), ('Blaine', 124.125), ('Albertine', 124.125), ('Elvin', 124.125), ('Delorse', 124.125), ('Chloe', 124.125), ('Aliza', 124.125), ('Eladia', 124.125), ('Edwardo', 124.125), ('Domingo', 124.125), ('Ara', 124.125), ('Brian', 124.125), ('Caitlin', 124.125), ('Blossom', 124.125), ('Arlean', 124.125), ('Elane', 124.125), ('Dorian', 124.125), ('Cassidy', 124.125), ('Carmon', 124.125), ('Enola', 124.125), ('Deeann', 124.125), ('Bradly', 124.125), ('Dorinda', 124.125), ('Boyce', 124.125), ('Alton', 124.125), ('Christy', 124.125), ('Bambi', 124.125), ('Clint', 124.125), ('Eugenie', 124.125), ('Cheryll', 124.125), ('Chau', 124.125), ('Cristal', 124.125), ('Christi', 124.125), ('Eulalia', 124.125), ('Emelda', 124.125), ('Aurea', 124.125), ('Arleen', 124.125), ('Alida', 124.125), ('Dorthea', 124.125), ('Esther', 124.125), ('Dione', 124.125), ('Daryl', 124.125), ('Chieko', 124.125), ('Elton', 124.125), ('Christoper', 124.125), ('Eva', 124.125), ('Bunny', 124.125), ('Bryant', 124.125), ('Andres', 124.125), ('Berniece', 124.125), ('Colene', 124.125), ('Barney', 124.125), ('Arletta', 124.125), ('Cordelia', 124.125), ('Brandee', 124.125), ('Alvaro', 124.125);

DELETE FROM test_spgist WHERE name IN
('Andrew', 'Adrien', 'Bobette', 'Anastasia', 'Elaine', 'Christeen', 'Burl', 'Carly', 'Berniece', 'Britt', 'Deadra', 'Clemente', 'Bryant', 'Danna', 'Davis', 'Emelina', 'Cristi', 'Debra', 'Esperanza', 'Drucilla', 'Caroyln', 'Elisabeth', 'Dedra', 'Ellis', 'Bud', 'Aracelis', 'Booker', 'Blossom', 'Cristal', 'Bailey', 'Arminda', 'Aisha', 'Cassie', 'Betsy', 'Celia', 'Alene', 'Aletha', 'Aleta', 'Alaine', 'Alina', 'Deetta', 'Casimira', 'Chrissy', 'Bebe', 'Dominga', 'Delpha', 'Christoper', 'Clara', 'Elodia', 'Brent', 'Christi', 'Arie', 'Carmon', 'Clora', 'Bernarda', 'Cortez', 'Ambrose', 'Aiko', 'Edgardo', 'Cammie', 'Elvia', 'Agustina', 'Evelin', 'Adrianna', 'Augustus', 'Chieko', 'Bret', 'Carolynn', 'Adeline', 'Elmira', 'Edith', 'Chin', 'Aurea', 'Bernard', 'Dewitt', 'Collene', 'Camelia', 'Coletta', 'Alejandro', 'Charlie');
DELETE FROM test_spgist WHERE name LIKE 'A%';

VACUUM (INDEX_CLEANUP ON) test_spgist;

--
--
-- cannot actually test lsn because the value can vary, so check everything else
-- Page 0 is the root, the rest are leaf pages:
--
SELECT 0 pageNum, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 0)) UNION
SELECT 1, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 1)) UNION
SELECT 2, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 2)) UNION
SELECT 3, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 3)) UNION
SELECT 4, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 4)) UNION
SELECT 5, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 5)) UNION
SELECT 6, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 6)) UNION
SELECT 7, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 7)) UNION
SELECT 8, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 8)) UNION
SELECT 9, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 9)) UNION
SELECT 10, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 10)) UNION
SELECT 11, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 11))
ORDER BY pageNum;

--
--
-- There is no more pages:
--
SELECT 12, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 12));


--
--
--
--
--
--
--
--
--
-- Let us check what data do we have:
--

--
-- Page 1
--
SELECT * FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx');
SELECT
    tuple_offset,
    node_block_num,
    node_offset,
    QUOTE_LITERAL(CHR(CAST(node_label AS INTEGER))) AS node_label
FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx');


--
--  Page 2
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 2), 'test_spgist_idx');

--
-- Page 3
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 3), 'test_spgist_idx');

--
-- Page 4
--
SELECT * FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx');
SELECT
    tuple_offset,
    node_block_num,
    node_offset,
    CASE WHEN CAST(node_label AS INTEGER) > 0 THEN QUOTE_LITERAL(CHR(CAST(node_label AS INTEGER))) ELSE node_label END AS node_label
FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx');
-- SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx');

--
-- Page 5
--
SELECT * FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx');
SELECT
    tuple_offset,
    node_block_num,
    node_offset,
    CASE WHEN CAST(node_label AS INTEGER) > 0 THEN QUOTE_LITERAL(CHR(CAST(node_label AS INTEGER))) ELSE node_label END AS node_label
FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx');
-- SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx');
--

--
-- Page 6
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 6), 'test_spgist_idx');

--
-- Page 7
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 7), 'test_spgist_idx');

--
-- Page 8
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 8), 'test_spgist_idx');

--
-- Page 9
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 9), 'test_spgist_idx');

--
-- Page 10
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 10), 'test_spgist_idx');

--
-- Page 11
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 11), 'test_spgist_idx');

--
-- Page 12
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 12), 'test_spgist_idx');

--
--
-- Drop a test table for radix tree
--
DROP TABLE test_spgist;

--
--
--
--  ______           __         __ __  ___ 
-- /_  __/___   ___ / /_       / //_/ / _ \
--  / /  / -_) (_-</ __/      / ,<   / // /
-- /_/   \__/ /___/\__/      /_/|_| /____/ 
                                          
--
--
-- Create a test table for future kd-tree index
--
CREATE TABLE test_spgist (
    pt point,
    t varchar(256)
);

--
--
-- Create kd index to test
--
CREATE INDEX test_spgist_idx ON test_spgist USING spgist (pt kd_point_ops);

--
--
-- Add data to test table
--

INSERT INTO test_spgist(pt, t) VALUES 
(point(51.61707, 8.89665), 'Lichtenau'), (point(45.68179, 4.64079), 'Thurins'), (point(29.36937, 105.88323), 'Zhuhai'), (point(50.61955, 2.53946), 'Saint-Venant'), (point(48.97146, 1.98082), 'Vernouillet'), (point(47.58541, 8.14455), 'Schwaderloch'), (point(5.37348, -5.91773), 'Zégréboué'), (point(29.11684, 106.51006), 'Xiaba'), (point(60.24859, 24.06534), 'Lohja'), (point(-33.22285, 151.53125), 'Buff Point'), (point(7.46751, -3.96111), 'Koffi Amoukro'), (point(38.74595, -5.67233), 'Quintana de la Serena'), (point(50.50939, 3.71621), 'Stambruges'), (point(52.68529, 1.32027), 'Spixworth'), (point(26.50083, 110.04444), 'Zhaishi Miaozu Dongzuxiang'), (point(59.36111, 26.4375), 'Sõmeru'), (point(39.56667, -1.88333), 'Motilla del Palancar'), (point(40.44535, -6.07445), 'Herguijuela de la Sierra'), (point(7.82719, -7.02085), 'Sagoura-Dougoula'), (point(39.81614, 48.93792), 'Qaraçala'), (point(8.38658, -4.70271), 'Bounadougou'), (point(49.2, 3.51667), 'Fère-en-Tardenois'), (point(47.71695, 1.93904), 'La Ferté-Saint-Aubin'), (point(46.17323, 8.80219), 'Muralto'), (point(43.64455, -79.40712), 'Niagara'), (point(43.08333, -1.8), 'Eratsun'), (point(32.61957, 106.10118), 'Zengjia'), (point(6.17732, -6.22756), 'Ondjahio'), (point(52.49973, 13.40338), 'Kreuzberg'), (point(39.93881, -3.61383), 'Ciruelos'), (point(47.34713, 8.72091), 'Uster'), (point(41.19997, 1.5683), 'Calafell'), (point(39.70822, 20.72656), 'Rodotópi'), (point(44.43729, 2.03148), 'Villeneuve'), (point(40.83392, -1.1365), 'Cosa'), (point(49.46715, 5.93202), 'Villerupt'), (point(47.41159, 9.0402), 'Kirchberg'), (point(49.23132, -0.04454), 'Dozulé'), (point(43.28317, -0.26715), 'Ousse'), (point(40.3574, 0.40692), 'Peníscola'), (point(-1.57504, -79.45998), 'Catarama'), (point(9.01811, -76.26413), 'Puerto Escondido'), (point(56.27421, -3.1239), 'Ladybank'), (point(28.31214, 30.71007), 'Samālūţ'), (point(41.30983, 0.98866), 'Prades'), (point(46.47963, 6.45992), 'Saint-Prex'), (point(48.70343, 6.25765), 'Pulnoy'), (point(43.3581, -5.51064), 'Nava'), (point(62.38333, 26.43333), 'Hankasalmi'), (point(53.60141, 11.50487), 'Raben Steinfeld'), (point(45.40296, 5.66682), 'Saint-Aupre'), (point(46.05512, -0.93092), 'Ciré-d''Aunis'), (point(40.50139, 22.54), 'Aigínio'), (point(43.94208, 3.94935), 'Sauve'), (point(52.81262, -0.51817), 'Corby Glen'), (point(-31.38663, 116.09664), 'Bindoon'), (point(-26.83354, 153.10013), 'Pelican Waters'), (point(38.79037, -6.3767), 'Torremegía'), (point(7.04853, -7.16985), 'Zétrozon'), (point(38.06059, 23.85926), 'Néa Pentéli'), (point(5.24032, -5.79516), 'Gnago'), (point(56.03434, 9.93177), 'Skanderborg'), (point(-14.23834, 129.52177), 'Wadeye'), (point(44.05669, 5.2343), 'Villes-sur-Auzon'), (point(51.17901, 7.74355), 'Herscheid'), (point(46.28136, 6.03873), 'Chevry'), (point(42.51565, -4.23877), 'Rezmondo'), (point(41.86691, -2.32549), 'Cirujales del Río'), (point(47.22662, 0.91587), 'Reignac-sur-Indre'), (point(47.79731, -4.28462), 'Guilvinec'), (point(50.6587, 13.3425), 'Olbernhau'), (point(37.24345, -1.85905), 'Vera'), (point(49.31175, 2.50419), 'Angicourt'), (point(52.63333, -2.43333), 'Madeley'), (point(39.28333, -0.41667), 'Almussafes'), (point(51.47626, 12.13455), 'Queis'), (point(57.5663, -4.43678), 'Conon Bridge'), (point(50.64059, 5.47179), 'Hollogne-aux-Pierres'), (point(47.64793, 8.87472), 'Eschenz'), (point(47.18179, -1.10917), 'Gesté'), (point(50.66974, 12.26519), 'Mohlsdorf'), (point(44.45633, 2.42746), 'Valady'), (point(50.63333, 13.11667), 'Großrückerswalde'), (point(29.87194, 106.38467), 'Chengjiang'), (point(35.56389, 114.50583), 'Daokou'), (point(46.63473, 6.97336), 'Sâles'), (point(44.22951, 0.67679), 'Pont-du-Casse'), (point(0.96093, -77.73161), 'Guachucal'), (point(48.31231, 12.27343), 'Buchbach'), (point(8.70587, -4.5552), 'Landédougou'), (point(43.6257, 6.69531), 'Fayence'), (point(45.83731, 6.57259), 'Praz-sur-Arly'), (point(40.40532, -3.9985), 'Brunete'), (point(34.13744, 103.16894), 'Yiwa'), (point(-12.4485, 131.00556), 'Holtze'), (point(37.34744, -2.3608), 'Purchena'), (point(29.20936, 106.14428), 'Youxi'), (point(22.89018, -82.50099), 'San Antonio de los Baños'), (point(48.53333, -3.78333), 'Plourin-lès-Morlaix'), (point(46.67587, 7.63972), 'Wimmis'), (point(51.94349, 7.16809), 'Coesfeld'), (point(8.23894, -7.79945), 'Férantéra'), (point(48.49249, 12.92499), 'Dietersburg'), (point(-33.8185, 150.96344), 'South Wentworthville'), (point(6.92748, -4.04531), 'Yobouessou'), (point(47.44109, -70.49858), 'Baie-Saint-Paul'), (point(47.98727, 2.04432), 'Rebréchien'), (point(47.39721, 8.45734), 'Schlieren / Boden'), (point(54.9938, -3.06594), 'Gretna'), (point(52.4776, -0.92053), 'Market Harborough'), (point(-19.30553, 146.75286), 'Cranbrook'), (point(42.69736, 2.73007), 'Corneilla-la-Rivière'), (point(47.06319, 6.66699), 'Villers-le-Lac'), (point(14.68612, -90.64253), 'San Pedro Sacatepéquez'), (point(30.06387, 107.45359), 'Sanxi'), (point(43.78531, 5.63446), 'La Bastide-des-Jourdans'), (point(34.95105, 33.29777), 'Lythrodóntas'), (point(43.71947, 81.86398), 'Samuyuzi'), (point(54.45506, -0.66484), 'Sleights'), (point(48.95192, 1.92338), 'Ecquevilly'), (point(6.21854, -6.51867), 'Gouabouo II'), (point(1.79112, -78.79275), 'Tumaco'), (point(33.50883, 104.66915), 'Pingya'), (point(36.33981, 28.19942), 'Faliraki'), (point(30.56977, 32.1146), 'Abu Suweir-el-Mahatta'), (point(50.63693, 6.46896), 'Heimbach'), (point(53.87561, -1.71232), 'Guiseley'), (point(64.25, 23.95), 'Kalajoki'), (point(39.98555, -3.36898), 'Villarrubia de Santiago'), (point(49.64941, 8.09442), 'Albisheim'), (point(61.52728, 28.17495), 'Puumala'), (point(6.45195, -1.57866), 'Bekwai'), (point(6.99022, -72.907), 'Santa Bárbara'), (point(47.21418, -70.26969), 'St-Jean-Port-Joli'), (point(50.83202, 5.58432), 'Vlijtingen'), (point(46.23071, -1.13817), 'Marsilly'), (point(6.77402, -5.11411), 'Attiégouakro'), (point(46.40886, -0.53726), 'Villiers-en-Plaine'), (point(47.55433, 9.37229), 'Salmsach'), (point(5.15341, -4.79233), 'Toukouzou'), (point(33.42843, 105.43458), 'Changba'), (point(43.78238, -79.15084), 'Centennial Scarborough'), (point(38.80453, 21.17461), 'Stános'), (point(47.49927, 8.796), 'Elsau-Räterschen / Räterschen'), (point(42.02945, -3.50679), 'Retuerta'), (point(36.71068, -4.63297), 'Cártama'), (point(50.74699, 6.49069), 'Kreuzau'), (point(10.45912, -74.8797), 'Candelaria'), (point(50.57904, 4.07129), 'Soignies'), (point(38.01667, -6.51667), 'Cañaveral de León'), (point(48.54586, 10.85179), 'Meitingen'), (point(35.91653, -5.37293), 'Benzú'), (point(-37.65675, 144.9346), 'Coolaroo'), (point(41.80694, 126.90778), 'Linjiang'), (point(48.8499, 7.62934), 'Uberach'), (point(7.47962, -6.21069), 'Zanzra'), (point(39.98333, -0.5), 'Higueras'), (point(37.36937, -2.97016), 'Gor'), (point(6.80984, -5.74144), 'Bazi'), (point(31.3529, 27.23725), 'Marsá Maţrūḩ'), (point(47.38387, 8.71763), 'Gutenswil'), (point(48.55897, 3.29939), 'Provins'), (point(56.43911, -2.9367), 'Newport-on-Tay'), (point(53.08312, 9.99772), 'Bispingen'), (point(5.67927, -4.24801), 'Kassiguié'), (point(36.61274, -5.14979), 'Pujerra'), (point(13.5, -13.93333), 'Brifu'), (point(41.02557, 23.77574), 'Gázoros'), (point(39.33375, -2.36984), 'Casas de los Pinos'), (point(45.37891, 5.542), 'La Murette'), (point(48.5807, 7.62803), 'Achenheim'), (point(49.85861, 9.69556), 'Birkenfeld'), (point(48.57828, 2.22417), 'Égly'), (point(54.91567, -1.60945), 'Lamesley'), (point(36.11056, 115.77528), 'Yanggu'), (point(48.8, 8.58333), 'Höfen an der Enz'), (point(43.39236, 6.33966), 'Le Cannet-des-Maures'), (point(50.40738, 3.60348), 'Vicq'), (point(52.33049, -0.18651), 'Huntingdon'), (point(39.36132, -7.13766), 'San Vicente de Alcántara'), (point(49.87167, 8.65027), 'Darmstadt'), (point(5.13825, -5.02123), 'Grand-Lahou'), (point(-37.88413, 144.78367), 'Altona Meadows'), (point(-37.67083, 144.93542), 'Dallas'), (point(41.76303, 1.66867), 'Fonollosa'), (point(42.94299, 2.2555), 'Couiza'), (point(49.12886, 4.53446), 'Suippes'), (point(51.78333, -0.03333), 'Little Amwell'), (point(49.51008, 0.97422), 'Roumare'), (point(51.07617, 10.33175), 'Mihla'), (point(4.71577, -7.17566), 'Trahé'), (point(5.13429, -75.14001), 'Padua'), (point(49.26333, 8.135), 'Edesheim'), (point(41.341, -4.4839), 'Remondo'), (point(43.76574, -79.48888), 'York University Heights'), (point(46.53932, 6.62227), 'Blécherette'), (point(49.44377, 0.96271), 'Saint-Martin-de-Boscherville'), (point(44.55618, 16.73349), 'Velagići'), (point(47.53455, -2.28326), 'Nivillac'), (point(47.44867, 9.60495), 'Walzenhausen'), (point(40.44107, -0.72048), 'Gúdar'), (point(7.038, -8.09132), 'Lonneu'), (point(9.02243, -5.46561), 'Bémavogo'), (point(50.62649, 10.15915), 'Kaltennordheim'), (point(54.21652, 10.88326), 'Lensahn'), (point(40.39957, -5.95618), 'Colmenar de Montemayor'), (point(6.84729, -8.28465), 'Yaogotouo'), (point(47.19857, 6.15924), 'Mamirolle'), (point(45.60234, 4.81064), 'Ternay'), (point(45.34261, 5.38864), 'Sillans'), (point(8.51366, -3.42616), 'Longongara'), (point(28.73333, -17.73333), 'Puntallana'), (point(5.92107, -6.58957), 'Koréyo'), (point(47.29064, 8.61464), 'Herrliberg'), (point(52.35862, 13.30994), 'Großbeeren'), (point(40.1271, -5.7015), 'Aldeanueva de la Vera'), (point(48.82857, -67.52197), 'Matane'), (point(42.02828, 8.84241), 'Sarrola'), (point(60.95, 21.45), 'Pyhäranta'), (point(48.69527, 8.82915), 'Gechingen'), (point(47.52913, 3.074), 'Saint-Amand-en-Puisaye'), (point(6.88139, -3.45806), 'Zinzénou'), (point(51.36074, 12.71376), 'Bennewitz'), (point(48.53259, 2.44388), 'Chevannes'), (point(50.85568, 0.58009), 'Hastings'), (point(31.21739, 121.42105), 'Changning'), (point(5.47681, -74.04416), 'Coper'), (point(47.37055, 8.54177), 'Zürich (Kreis 1)'), (point(34.75778, 113.64861), 'Zhengzhou'), (point(5.99473, -6.3573), 'Liliyo'), (point(55.62298, 12.1387), 'Vindinge'), (point(41.76673, -6.07215), 'Ferreruela'), (point(52.11457, 8.67343), 'Herford'), (point(31.1933, 120.71758), 'Songling'), (point(45.81667, 6.01667), 'Alby-sur-Chéran'), (point(39.06901, 112.92913), 'Shangguan'), (point(51.58656, 10.66326), 'Ellrich'), (point(-35.2998, 149.10585), 'Yarralumla'), (point(45.77913, 0.40894), 'Taponnat'), (point(51.44162, 0.14866), 'Bexley'), (point(50.66057, 6.78722), 'Euskirchen'), (point(48.0785, 0.4179), 'Lombron'), (point(6.70786, -6.76684), 'Dédégbeu'), (point(51.46667, 13.61667), 'Plessa'), (point(38.80561, -0.1589), 'Vall de Ebo'), (point(-32.93089, 151.77835), 'The Hill'), (point(50.28333, 11.95), 'Döhlau'), (point(53.87823, 12.61619), 'Jördenstorf'), (point(7.8894, -75.67015), 'Puerto Libertador'), (point(54.75, -1.43333), 'Thornley'), (point(49.85528, 9.52583), 'Esselbach'), (point(5.66667, -7.38333), 'Siéblo Oula'), (point(50.286, 5.51153), 'Soy'), (point(51.9279, -0.50147), 'Chalton'), (point(53.41211, -4.4519), 'Cemaes Bay'), (point(8.78828, -3.17887), 'Mango'), (point(10.45056, -84.27406), 'Pital'), (point(26.93613, 114.22778), 'Hechuan'), (point(47.31637, 8.51888), 'Adliswil / Hündli-Zopf'), (point(49.50455, 1.0114), 'Saint-Jean-du-Cardonnay'), (point(40.43026, 50.03598), 'Yeni Suraxanı'), (point(52.23333, 8.16667), 'Bissendorf'), (point(31.23867, 31.65379), 'As Sarw'), (point(47.36106, -1.94206), 'Savenay'), (point(49.34668, 6.13346), 'Terville'), (point(55.80373, -4.29488), 'Giffnock'), (point(22.97533, 115.33179), 'Haicheng'), (point(51.54028, -3.37389), 'Llantrisant'), (point(50.5925, 9.54231), 'Großenlüder'), (point(46.57094, 6.82557), 'Oron-la-Ville'), (point(50.22063, 10.12296), 'Nüdlingen'), (point(51.62578, 13.56232), 'Doberlug-Kirchhain'), (point(49.41705, 2.80317), 'Venette'), (point(37.24536, -1.9176), 'Antas'), (point(38.03333, 116.7), 'Nanpi'), (point(52.23279, 11.52195), 'Groß Ammensleben'), (point(51.73203, -4.71983), 'Kilgetty'), (point(48.77298, 1.20253), 'La Madeleine-de-Nonancourt'), (point(60.07178, 20.08472), 'Lemland'), (point(9.04963, -76.0028), 'Buenavista'), (point(4.66639, -7.08061), 'Wèoulo'), (point(42.8471, 1.6056), 'Tarascon-sur-Ariège'), (point(38.63117, -0.76458), 'Biar'), (point(31.65811, 119.02772), 'Yongyang'), (point(45.84098, 6.21374), 'Talloires'), (point(43.40873, -7.14317), 'San Tirso de Abres'), (point(23.59985, 107.12255), 'Tiandong'), (point(64.46667, 24.23333), 'Pyhäjoki'), (point(10.0, -85.3), 'Zapotal'), (point(45.15165, 0.008), 'La Roche-Chalais'), (point(47.90748, 11.84266), 'Feldkirchen-Westerham'), (point(51.86264, -2.1206), 'Shurdington'), (point(50.96799, 4.3796), 'Humbeek'), (point(40.29953, -4.63589), 'La Adrada'), (point(51.45807, -0.58674), 'Old Windsor'), (point(51.42997, -2.66098), 'Long Ashton'), (point(36.95692, -2.56861), 'Alhama de Almería'), (point(7.75849, -76.65255), 'Carepa'), (point(50.85196, 13.77977), 'Glashütte'), (point(54.22785, -2.76939), 'Milnthorpe'), (point(41.14576, 0.81979), 'Falset'), (point(45.08338, -73.13245), 'Venise-en-Québec'), (point(47.84507, -2.72293), 'Saint-Jean-Brévelay'), (point(33.54453, -0.28117), 'Mecheria'), (point(-4.03333, 21.98333), 'Isamba'), (point(39.22573, -4.59133), 'Navalpino'), (point(48.78469, -3.23196), 'Tréguier'), (point(49.95, 6.7), 'Herforst'), (point(47.19763, 5.90079), 'Grandfontaine'), (point(33.16635, 105.31344), 'Pipa'), (point(29.39217, 108.68697), 'Jinxi'), (point(7.57127, -1.7087), 'Nkoranza'), (point(53.22846, -1.29204), 'Bolsover'), (point(51.05676, -2.40574), 'Wincanton'), (point(39.61667, -2.01667), 'Valverdejo'), (point(54.5161, 8.64512), 'Pellworm'), (point(5.47964, -3.32856), 'Kohourou'), (point(50.96667, 3.53333), 'Petegem-aan-de-Leie'), (point(22.63696, 90.27195), 'Nālchiti'), (point(48.50906, -4.06906), 'Landivisiau'), (point(36.73252, -4.92122), 'Yunquera'), (point(7.25219, -5.84987), 'Bouafla'), (point(54.04552, 11.8778), 'Retschow'), (point(2.9, 11.15), 'Ébolowa'), (point(50.72092, 5.12941), 'Montenaken'), (point(50.37153, -4.14305), 'Plymouth'), (point(53.67688, -1.35647), 'Featherstone'), (point(47.22143, -1.04214), 'Le Fief-Sauvin'), (point(39.1218, -0.44812), 'Carcaixent'), (point(-37.83018, 144.8709), 'South Kingsville'), (point(51.49225, -0.77239), 'White Waltham'), (point(60.4596, 24.80629), 'Nurmijärven kirkonkylä'), (point(48.28426, 8.17602), 'Hausach'), (point(43.33333, 5.71667), 'Plan-d''Aups-Sainte-Baume'), (point(-27.61089, 153.35996), 'Macleay Island'), (point(50.97401, 8.96946), 'Gemünden an der Wohra'), (point(45.33473, 5.42486), 'Izeaux'), (point(6.53333, -0.81667), 'Odumase Krobo'), (point(44.63278, -1.14513), 'La Teste-de-Buch'), (point(5.08004, -75.17556), 'Herveo'), (point(50.71667, 3.21667), 'Herseaux'), (point(48.71667, 10.93333), 'Niederschönenfeld'), (point(47.16463, 7.79858), 'Madiswil'), (point(43.72799, 7.36194), 'Èze'), (point(6.8669, -4.42076), 'Ettienkro'), (point(44.32597, 85.62009), 'Sandaohezi'), (point(48.84445, 2.06345), 'Noisy-le-Roi'), (point(35.06586, 32.49226), 'Argáka'), (point(44.9256, 4.90956), 'Valence'), (point(53.81667, -0.2), 'Burton Constable'), (point(50.56529, 12.79049), 'Beierfeld'), (point(37.7688, -1.50229), 'Totana'), (point(1.41828, -75.87753), 'Belén de los Andaquíes'), (point(22.27797, -80.56931), 'Abreus'), (point(18.57053, -71.72967), 'La Descubierta'), (point(49.3319, 1.26127), 'Romilly-sur-Andelle'), (point(10.30945, -6.53819), 'Fébiasso'), (point(7.63858, -5.14791), 'Pietipssi'), (point(52.12773, 11.62916), 'Magdeburg'), (point(48.35, -2.18333), 'Yvignac-la-Tour'), (point(54.5415, -1.919), 'Barnard Castle'), (point(49.20613, 7.97527), 'Annweiler am Trifels'), (point(50.48132, 4.14545), 'Houdeng-Aimeries'), (point(48.41797, -0.33742), 'Javron-les-Chapelles'), (point(43.28764, 5.37918), 'Marseille 06'), (point(48.61436, 7.69009), 'Mittelhausbergen'), (point(50.81192, 13.10197), 'Augustusburg'), (point(52.76268, -1.724), 'Barton under Needwood'), (point(39.93333, -0.2), 'Betxí'), (point(41.40408, 2.17332), 'Sagrada Família'), (point(41.98408, -3.59661), 'Cebrecos'), (point(44.9081, -0.47316), 'Sainte-Eulalie'), (point(51.0154, 2.29975), 'Grande-Synthe'), (point(33.65526, 105.65786), 'Jifeng'), (point(54.69229, -6.66956), 'Moneymore'), (point(43.15, -2.93333), 'Elexalde'), (point(30.41131, 103.81302), 'Wujin'), (point(8.78962, -75.11686), 'Caimito'), (point(29.99228, 106.26461), 'Hechuan'), (point(7.70964, -2.99308), 'Yango'), (point(8.32333, -73.14889), 'Hacarí'), (point(50.53968, 3.08222), 'Avelin'), (point(51.01678, -4.20832), 'Bideford'), (point(47.50154, 8.23122), 'Lauffohr (Brugg)'), (point(64.93456, 25.41121), 'Oulunsalo'), (point(31.71335, 108.59846), 'Jiming'), (point(51.11096, 4.33428), 'Niel'), (point(47.54858, -1.12274), 'Freigné'), (point(39.46667, -1.63333), 'Villalpardo'), (point(48.66949, 5.91005), 'Dommartin-lès-Toul'), (point(9.22683, -5.67947), 'Karakpo'), (point(36.145, 120.48778), 'Kutao'), (point(45.98747, 4.62475), 'Cogny'), (point(51.03333, 6.68333), 'Rommerskirchen'), (point(5.88737, 10.01176), 'Bali'), (point(52.06667, 9.75), 'Banteln'), (point(53.75399, -0.4549), 'Kirk Ella'), (point(41.4197, 2.08911), 'Vallvidrera, el Tibidabo i les Planes'), (point(49.53487, 5.68487), 'Gorcy'), (point(51.51312, 10.25951), 'Duderstadt');

DELETE FROM test_spgist WHERE pt ~= ANY
('{"(42.02945, -3.50679)", "(45.68179, 4.64079)", "(6.8669, -4.42076)", "(33.50883, 104.66915)", "(50.96799, 4.3796)", "(35.91653, -5.37293)", "(64.46667, 24.23333)", "(39.06901, 112.92913)", "(47.19763, 5.90079)", "(8.51366, -3.42616)", "(45.15165, 0.008)", "(51.86264, -2.1206)", "(44.32597, 85.62009)", "(50.71667, 3.21667)", "(39.98555, -3.36898)", "(59.36111, 26.4375)", "(5.66667, -7.38333)", "(48.55897, 3.29939)", "(49.31175, 2.50419)", "(6.70786, -6.76684)", "(39.22573, -4.59133)", "(62.38333, 26.43333)", "(43.71947, 81.86398)", "(50.74699, 6.49069)", "(55.80373, -4.29488)", "(48.71667, 10.93333)", "(41.4197, 2.08911)", "(36.95692, -2.56861)", "(47.54858, -1.12274)", "(47.64793, 8.87472)", "(51.17901, 7.74355)", "(34.95105, 33.29777)", "(54.45506, -0.66484)", "(5.08004, -75.17556)", "(50.37153, -4.14305)", "(6.21854, -6.51867)", "(45.77913, 0.40894)", "(49.64941, 8.09442)", "(50.286, 5.51153)", "(48.69527, 8.82915)", "(48.8, 8.58333)", "(50.66057, 6.78722)", "(50.72092, 5.12941)", "(49.26333, 8.135)", "(50.28333, 11.95)", "(4.66639, -7.08061)", "(41.30983, 0.98866)", "(50.40738, 3.60348)", "(37.24536, -1.9176)", "(7.25219, -5.84987)", "(40.1271, -5.7015)", "(-12.4485, 131.00556)", "(53.81667, -0.2)", "(50.96667, 3.53333)", "(51.61707, 8.89665)", "(5.99473, -6.3573)", "(38.74595, -5.67233)", "(33.42843, 105.43458)", "(51.36074, 12.71376)", "(48.53333, -3.78333)", "(56.43911, -2.9367)", "(47.39721, 8.45734)", "(44.22951, 0.67679)", "(35.06586, 32.49226)", "(30.56977, 32.1146)", "(43.33333, 5.71667)", "(53.75399, -0.4549)", "(34.75778, 113.64861)", "(51.58656, 10.66326)", "(47.31637, 8.51888)", "(46.28136, 6.03873)", "(40.39957, -5.95618)", "(38.63117, -0.76458)", "(37.34744, -2.3608)", "(36.61274, -5.14979)", "(46.17323, 8.80219)", "(-35.2998, 149.10585)", "(10.30945, -6.53819)", "(31.65811, 119.02772)", "(8.32333, -73.14889)"}');

INSERT INTO test_spgist(pt, t) VALUES 
(point(41.40721, -1.99989), 'Cihuela'), (point(51.39462, 8.57146), 'Brilon'), (point(51.40606, 0.01519), 'Bromley'), (point(5.98696, -5.73638), 'Grogouya'), (point(51.0, 2.41667), 'Coudekerque-Village'), (point(-33.02081, 151.66849), 'Belmont North'), (point(36.28176, 119.55185), 'Jinggou'), (point(48.6075, -2.15031), 'Lancieux'), (point(49.56333, 8.24472), 'Dirmstein'), (point(52.20871, 11.73795), 'Lostau'), (point(41.01925, -5.00873), 'Mamblas'), (point(45.64746, 0.36723), 'Chazelles'), (point(60.26013, 20.77892), 'Kumlinge'), (point(40.93328, 24.71088), 'Chrysochóri'), (point(54.14054, 10.60751), 'Eutin'), (point(39.97938, -2.86143), 'Uclés'), (point(4.68116, -74.71406), 'Pulí'), (point(42.54911, -2.90994), 'Casalarreina'), (point(36.6563, -4.83433), 'Guaro'), (point(32.35473, 116.2939), 'Huoqiu Chengguanzhen'), (point(5.79833, -5.29786), 'Brabodougou Douzarékro'), (point(55.86667, -3.68333), 'Whitburn'), (point(57.23721, -2.3454), 'Kintore'), (point(47.70121, 8.55236), 'Löhningen'), (point(7.42647, -5.09685), 'Assouakro'), (point(50.41488, 6.11207), 'Waimes'), (point(41.36477, -3.42964), 'Ribota'), (point(43.83242, 5.20597), 'Ménerbes'), (point(53.41667, -1.6), 'Bradfield'), (point(50.75158, 2.94635), 'Warneton'), (point(51.62202, -3.45544), 'Tonypandy'), (point(47.74194, 8.97098), 'Radolfzell'), (point(50.36879, 3.93602), 'Quévy-le-Petit'), (point(-31.82723, 115.80247), 'Greenwood'), (point(42.81084, -1.66409), 'Ermitagaña'), (point(48.49232, -2.02929), 'Saint-Samson-sur-Rance'), (point(49.86359, 18.09331), 'Velká Polom'), (point(40.66441, -5.07719), 'Manjabálago'), (point(28.96302, -13.54769), 'Arrecife'), (point(-33.77852, 151.19677), 'Roseville Chase'), (point(25.8505, 98.85567), 'Liuku'), (point(50.26038, 7.44461), 'Oberfell'), (point(36.79075, -4.16146), 'Benamocarra'), (point(46.89868, 7.5446), 'Rubigen'), (point(46.98423, 8.41003), 'Ennetbürgen'), (point(-18.4746, -70.29792), 'Arica'), (point(0.49113, 29.47306), 'Beni'), (point(40.60985, 22.68196), 'Néa Málgara'), (point(6.32204, -5.17464), 'Sahoua'), (point(34.37667, 117.25056), 'Maocun'), (point(49.56306, 8.29083), 'Heuchelheim bei Frankenthal'), (point(48.8251, 10.70331), 'Huisheim'), (point(49.34083, 8.80028), 'Mauer'), (point(6.25184, -75.56359), 'Medellín'), (point(37.60957, 21.60509), 'Makrísia'), (point(45.16938, 4.8716), 'Saint-Barthélemy-de-Vals'), (point(50.93926, 2.53914), 'Rexpoëde'), (point(46.07775, -0.78909), 'Saint-Germain-de-Marencennes'), (point(7.71307, -72.65759), 'Durania'), (point(49.56056, 8.31944), 'Beindersheim'), (point(50.83971, 5.02287), 'Neerlinter'), (point(32.89139, 108.50472), 'Hanyin Chengguanzhen'), (point(54.98704, 12.28461), 'Stege'), (point(42.14797, -0.36049), 'Quicena'), (point(51.31667, -2.42417), 'Peasedown Saint John'), (point(39.86319, -3.61275), 'Huerta de Valdecarábanos'), (point(48.90472, 2.2469), 'La Garenne-Colombes'), (point(48.5292, 5.89451), 'Colombey-les-Belles'), (point(47.88238, 10.62192), 'Kaufbeuren'), (point(40.33333, -3.38333), 'Campo Real'), (point(39.81178, -4.14885), 'Guadamur'), (point(18.37825, -68.609), 'Boca de Yuma'), (point(46.09014, 6.50004), 'Marignier'), (point(58.36389, 25.59), 'Viljandi'), (point(9.9816, -84.18592), 'San Antonio'), (point(42.40445, -4.24484), 'Melgar de Fernamental'), (point(11.72615, 40.9797), 'Logīya'), (point(-4.24639, 12.48889), 'Mvouti'), (point(38.89925, -3.05333), 'Alhambra'), (point(50.85485, 2.82024), 'Vlamertinge'), (point(42.64077, -6.68627), 'Arganza'), (point(32.14789, 108.45112), 'Zuolan'), (point(47.65595, 1.48847), 'Saint-Dyé-sur-Loire'), (point(19.04134, -69.83616), 'Majagual'), (point(8.15174, -4.38272), 'Diendana-Sokoura'), (point(10.77697, -74.85344), 'Polonuevo'), (point(-33.80154, 150.91358), 'Prospect'), (point(47.3196, 4.90594), 'Velars-sur-Ouche'), (point(29.50494, 107.89998), 'Tudi'), (point(52.28906, 11.40982), 'Haldensleben I'), (point(38.96265, -5.95785), 'Medellín'), (point(49.07787, 9.06601), 'Brackenheim'), (point(22.31184, -79.6544), 'Placetas'), (point(53.79173, -1.38067), 'Garforth'), (point(43.5936, 3.11439), 'Hérépian'), (point(5.79742, -4.13774), 'Yapo-Gare'), (point(-35.33321, -72.41156), 'Constitución'), (point(49.25, 11.4), 'Berngau'), (point(50.4192, 3.10374), 'Roost-Warendin'), (point(7.34933, -6.02013), 'Vaniébotifla'), (point(52.03866, -0.15398), 'Ashwell'), (point(50.2415, 15.49082), 'Nový Bydžov'), (point(41.86367, 1.97095), 'Avinyó'), (point(28.40417, 108.90442), 'Qingxichang'), (point(49.29702, 4.31657), 'Pontfaverger-Moronvilliers'), (point(39.1019, -1.55821), 'Casas de Juan Núñez'), (point(7.60747, -5.87601), 'Kouafla'), (point(43.38153, 0.83526), 'L''Isle-en-Dodon'), (point(34.84422, 111.19131), 'Shengrenjian'), (point(52.71695, 11.8606), 'Goldbeck'), (point(7.44039, -3.55062), 'Aouakamissi'), (point(5.31012, -6.27536), 'Zabré'), (point(25.99845, 32.81808), 'Qifţ'), (point(42.62297, -2.27966), 'Mirafuentes'), (point(45.55203, 4.71544), 'Échalas'), (point(48.5787, -3.18379), 'Plouisy'), (point(45.17075, 1.56393), 'Malemort-sur-Corrèze'), (point(-34.66792, 138.70149), 'Munno Para'), (point(49.15964, 5.3829), 'Verdun'), (point(8.0, -5.56667), 'Ndri-Kwakoukro'), (point(52.17179, 12.37506), 'Görzke'), (point(49.5482, 1.05515), 'Eslettes'), (point(33.22917, 119.30917), 'Baoying'), (point(40.3263, -6.17603), 'La Pesga'), (point(40.29303, 118.26908), 'Songling'), (point(31.66574, 104.43726), 'Yongchang'), (point(29.10644, 119.64855), 'Chengzhong'), (point(41.16424, -6.69137), 'Mieza'), (point(30.55258, 31.00904), 'Shibīn al Kawm'), (point(5.80465, -6.78437), 'Johin'), (point(35.06937, -1.13706), 'Sidi Abdelli'), (point(41.06305, -5.54794), 'Pedrosillo el Ralo'), (point(49.36528, 8.58306), 'Oftersheim'), (point(6.26239, -3.81457), 'Bouapé'), (point(6.36064, -3.86087), 'Ahéoua'), (point(50.11525, 14.50685), 'Prosek'), (point(52.26057, -0.22818), 'Great Paxton'), (point(49.89444, 7.4775), 'Gemünden'), (point(46.21524, 1.16642), 'Magnac-Laval'), (point(3.65332, 18.63566), 'Libenge'), (point(50.27671, 3.04045), 'Lécluse'), (point(37.49583, 121.25806), 'Qingyang'), (point(51.65446, -3.02281), 'Cwmbran'), (point(42.1859, 127.47895), 'Songjianghe'), (point(45.35126, 4.8107), 'Salaise-sur-Sanne'), (point(39.96138, -3.93164), 'Magán'), (point(41.55613, -1.67563), 'Jarque'), (point(43.97799, 81.51804), 'Yining'), (point(52.37092, -1.26417), 'Rugby'), (point(50.93436, 3.78663), 'Scheldewindeke'), (point(46.51217, 9.85794), 'Celerina'), (point(48.08106, 7.3938), 'Horbourg-Wihr'), (point(-31.85497, 115.83986), 'Balga'), (point(43.29755, 2.67825), 'Pépieux'), (point(52.6291, -2.0577), 'Essington'), (point(41.94606, -5.09693), 'Berrueces'), (point(47.16743, 9.47794), 'Buchs'), (point(38.01135, 23.66597), 'Chaïdári'), (point(38.62275, 77.27948), 'Kuoshi''airike'), (point(39.7692, 3.02394), 'sa Pobla'), (point(48.44002, 10.70532), 'Bonstetten'), (point(42.95008, -81.88309), 'Watford'), (point(8.79018, -3.0027), 'Kartoudouo'), (point(48.36051, 12.50723), 'Neumarkt-Sankt Veit'), (point(34.43278, 117.44194), 'Jiawang'), (point(9.92572, -6.90525), 'Fengolo'), (point(54.96344, 8.69853), 'Højer'), (point(52.92277, -1.47663), 'Derby'), (point(48.59113, 6.15106), 'Méréville'), (point(47.18083, 8.31802), 'Hohenrain'), (point(43.46686, -3.60083), 'Bareyo'), (point(48.3945, 7.62185), 'Matzenheim'), (point(26.5075, 119.545), 'Qibu'), (point(41.48846, -0.5312), 'Pina de Ebro'), (point(39.33667, 49.21414), 'Sovetabad'), (point(41.45247, -3.09123), 'Fresno de Caracena'), (point(38.72555, -0.19242), 'Castell de Castells'), (point(39.56916, -0.62453), 'Vilamarxant'), (point(54.11687, -112.46863), 'Smoky Lake'), (point(29.70472, 106.00383), 'Gulong'), (point(36.68482, 7.75111), 'Drean'), (point(40.87268, -4.86909), 'Narros de Saldueña'), (point(52.62066, 8.59251), 'Barver'), (point(-34.92654, 138.57033), 'Mile End'), (point(-27.79653, 153.2567), 'Ormeau Hills'), (point(-21.2075, -159.77546), 'Avarua'), (point(26.47681, 119.60517), 'Jitoucun'), (point(37.2025, 112.17806), 'Gutao'), (point(49.28178, 1.7801), 'Gisors'), (point(27.23818, 111.46214), 'Shaoyang'), (point(43.87899, 5.65919), 'Reillanne'), (point(10.43669, -5.63062), 'Pogo'), (point(37.41042, -3.17158), 'Fonelas'), (point(38.03922, -4.05077), 'Andújar'), (point(-30.60106, -71.19901), 'Ovalle'), (point(41.09439, -5.60168), 'Palencia de Negrilla'), (point(8.28333, 37.78333), 'Welk’īt’ē'), (point(42.66743, 2.99134), 'Saint-Nazaire'), (point(55.20444, -6.24298), 'Ballycastle'), (point(50.86643, 13.32285), 'Brand-Erbisdorf'), (point(40.78341, 114.87139), 'Zhangjiakou'), (point(27.71833, 110.67083), 'Liangyaping'), (point(38.35505, 22.90881), 'Agía Triáda'), (point(-32.91923, 151.75693), 'Wickham'), (point(49.21235, 2.39485), 'Villers-sous-Saint-Leu'), (point(54.37542, -1.63328), 'Catterick'), (point(5.68782, -6.08422), 'Tagbayo'), (point(43.77948, -1.2174), 'Magescq'), (point(8.32589, -4.4125), 'Kotolo'), (point(6.97326, -4.2328), 'Abéanou'), (point(43.70133, -79.48559), 'Brookhaven-Amesbury'), (point(1.57006, -75.32863), 'El Paujíl'), (point(45.66022, 2.97316), 'Aydat'), (point(41.68122, -0.50678), 'Farlete'), (point(45.88716, 4.62339), 'Chessy'), (point(43.77139, 17.02833), 'Vidoši'), (point(44.19796, 2.3417), 'Naucelle'), (point(40.4815, 23.04863), 'Agía Paraskeví'), (point(50.83988, -0.67123), 'Westergate'), (point(51.50372, 0.11982), 'Thamesmead'), (point(46.01677, -73.34915), 'Saint-Thomas'), (point(43.54035, -5.68233), 'Natahoyo'), (point(49.02459, 11.96126), 'Nittendorf'), (point(49.50592, 0.41332), 'La Cerlangue'), (point(39.31121, 26.22056), 'Stýpsi'), (point(25.29513, 117.41464), 'Zhangping'), (point(43.29614, 5.43617), 'Marseille 12'), (point(52.25, -2.75), 'Eyton'), (point(52.64244, 0.20857), 'Emneth'), (point(6.99442, -5.15835), 'Assanou'), (point(44.37389, 16.38083), 'Drvar'), (point(60.21746, 24.78151), 'Kilo'), (point(18.50228, -71.34271), 'Galván'), (point(42.86676, -4.49796), 'Cervera de Pisuerga'), (point(5.19608, -73.14504), 'Miraflores'), (point(-23.69601, 133.854), 'Araluen'), (point(18.76365, -70.33732), 'Juan Adrián'), (point(41.13494, -1.95964), 'Algar de Mesa'), (point(50.23743, -3.76874), 'Salcombe'), (point(56.24811, 10.26533), 'Hjortshøj'), (point(49.50301, 7.76995), 'Otterberg'), (point(41.82832, 0.14823), 'Alfántega'), (point(54.50344, -6.76723), 'Dungannon'), (point(8.46953, -4.74776), 'Sitiolo'), (point(51.74722, -2.32639), 'Eastington'), (point(25.47047, 119.10348), 'Hanjiang'), (point(60.56085, 21.61639), 'Taivassalo'), (point(49.60876, 18.48617), 'Pražmo'), (point(14.50998, -92.19298), 'Ocós'), (point(36.79505, -3.26769), 'Sorvilán'), (point(56.15022, 9.80683), 'Låsby'), (point(49.1705, 5.35266), 'Thierville-sur-Meuse'), (point(9.6465, -5.6198), 'Zémongokaha'), (point(46.83162, -0.86102), 'La Flocellière'), (point(38.58316, 21.44729), 'Panaitólion'), (point(51.23705, 0.71892), 'Lenham'), (point(42.03722, 119.28889), 'Pingzhuang'), (point(50.7832, 4.67503), 'Nethen'), (point(47.85, 9.2), 'Herdwangen-Schönach'), (point(7.19947, -8.12411), 'Bouagleu I'), (point(43.39364, -5.70662), 'Noreña'), (point(-33.61169, -70.57577), 'Puente Alto'), (point(35.16272, 33.88322), 'Égkomi'), (point(40.11917, -4.24158), 'Santa Cruz del Retamar'), (point(40.90723, -2.32325), 'Saelices de la Sal'), (point(48.26, 11.43402), 'Dachau'), (point(52.15, 14.65), 'Eisenhüttenstadt'), (point(40.89818, -2.22523), 'Ablanque'), (point(41.49001, -6.1367), 'Moralina'), (point(41.67269, 0.81768), 'Bellvís'), (point(63.96667, 25.76667), 'Kärsämäki'), (point(5.27372, -74.19614), 'Villagómez'), (point(47.40009, 8.40818), 'Dietikon / Guggenbühl'), (point(24.68413, 113.59839), 'Maba'), (point(37.61915, -0.87799), 'La Unión'), (point(49.41646, 5.70908), 'Pierrepont'), (point(44.83883, 4.8905), 'Étoile-sur-Rhône'), (point(48.01754, 6.5882), 'Remiremont'), (point(48.02093, 8.53056), 'Bad Dürrheim'), (point(41.21667, -3.1), 'Condemios de Abajo'), (point(52.09216, -1.02602), 'Silverstone'), (point(51.29427, 3.19331), 'Lissewege'), (point(38.50754, -0.23346), 'Villajoyosa'), (point(31.26861, 109.8021), 'Dachang'), (point(38.5212, -6.6226), 'La Parra'), (point(6.48505, -6.3844), 'Broma'), (point(51.10781, 3.89048), 'Zeveneken'), (point(49.04, 3.95922), 'Épernay'), (point(5.4188, -4.3519), 'Vieil-Aklodj'), (point(-31.91721, 115.93796), 'Ashfield'), (point(48.1729, 0.65781), 'Cherré'), (point(48.38333, 12.13333), 'Hohenpolding'), (point(29.27846, 106.23157), 'Degan'), (point(47.50213, 8.25554), 'Untersiggenthal'), (point(43.33189, 5.36111), 'La Cabucelle'), (point(22.21072, 113.29218), 'Jing’an'), (point(4.76279, -76.221), 'El Cairo'), (point(47.50596, 8.7515), 'Oberwinterthur (Kreis 2) / Talacker'), (point(51.17482, 0.48855), 'Marden'), (point(52.83983, -1.55061), 'Repton'), (point(47.4617, -1.2781), 'Teillé'), (point(41.55, 1.51667), 'Sant Martí de Tous'), (point(2.25462, -76.61086), 'Paispamba'), (point(43.44313, 6.63772), 'Roquebrune-sur-Argens'), (point(62.43333, 28.6), 'Heinävesi'), (point(43.73917, -79.24576), 'Eglinton East'), (point(43.26627, 5.37377), 'La Page'), (point(53.60341, 8.87876), 'Lintig'), (point(39.04194, 106.39583), 'Dawukou'), (point(50.841, 2.55118), 'Winnezeele'), (point(52.55593, 10.28291), 'Langlingen'), (point(40.89427, 23.75048), 'Mavrothálassa'), (point(41.18783, -4.94966), 'Cervillego de la Cruz'), (point(7.46067, -7.69453), 'Biakalé'), (point(9.02324, -5.88598), 'Sonzoriso'), (point(50.99366, -1.75129), 'Downton'), (point(53.23748, 8.45664), 'Elsfleth'), (point(41.08663, -5.70219), 'Calzada de Valdunciel'), (point(54.53333, 9.03333), 'Hattstedt'), (point(57.67012, -2.49686), 'Macduff'), (point(6.62265, -6.86803), 'Séliéguhé'), (point(54.05562, 10.02547), 'Gadeland'), (point(51.41259, -0.2974), 'Kingston upon Thames'), (point(40.77406, 22.35304), 'Melíssi'), (point(48.087, 11.02388), 'Eresing'), (point(50.7533, 3.12131), 'Roncq'), (point(46.38973, -0.41584), 'Échiré'), (point(14.63823, -91.22901), 'Santiago Atitlán'), (point(49.41667, 7.48333), 'Hütschenhausen'), (point(14.64724, -89.72463), 'San Luis Jilotepeque'), (point(7.37356, -3.87782), 'Zanzansso'), (point(7.30293, -4.09676), 'Prikro-Ouellé'), (point(51.87167, 10.02537), 'Bad Gandersheim'), (point(-19.22517, 146.61787), 'Black River'), (point(51.41513, -1.51556), 'Hungerford'), (point(49.3, 2.51667), 'Rieux'), (point(42.79019, -1.82822), 'Ciriza'), (point(53.91887, 10.69691), 'Bad Schwartau'), (point(50.77704, 7.95366), 'Herdorf'), (point(38.40602, -4.30492), 'Fuencaliente'), (point(53.38333, -1.36667), 'Orgreave'), (point(15.38796, -91.72564), 'San Gaspar Ixchil'), (point(8.91667, 38.61667), 'Sebeta'), (point(50.70535, 1.5897), 'Outreau'), (point(34.03511, 105.03286), 'Zhongba'), (point(29.45741, 106.12926), 'Zhengxing'), (point(8.54791, -4.34636), 'Kanguérasso'), (point(38.87933, -0.36115), 'Rugat'), (point(42.85027, -6.19164), 'Murias de Paredes'), (point(40.50208, -0.19133), 'Castellfort'), (point(5.45956, -3.25653), 'Assouba'), (point(23.36085, 103.15372), 'Gejiu'), (point(53.60126, -2.54975), 'Horwich'), (point(8.94334, -4.24796), 'Sokolo'), (point(5.13384, -3.29096), 'Assinie-Mafia'), (point(47.90392, -3.57764), 'Mellac'), (point(53.47931, -1.0619), 'Rossington'), (point(41.79128, -0.15804), 'Sariñena'), (point(50.48793, 9.86795), 'Poppenhausen'), (point(40.99302, 22.87433), 'Kilkís'), (point(45.53694, 5.67333), 'Le Pont-de-Beauvoisin'), (point(61.5, 23.01667), 'Mouhijärvi'), (point(6.50788, -5.11929), 'Mougnan'), (point(43.25576, 5.42963), 'La Panouse'), (point(51.33217, -0.3562), 'Oxshott'), (point(9.26021, -7.43569), 'Nafanasienso'), (point(47.12849, 8.74735), 'Einsiedeln'), (point(37.91116, -6.82045), 'Cortegana'), (point(41.81444, -2.63991), 'Cidones'), (point(38.33414, 85.57003), 'Aketikandun'), (point(45.64625, 5.01481), 'Saint-Pierre-de-Chandieu'), (point(40.71578, -4.07402), 'Los Molinos'), (point(54.2548, -0.47483), 'East Ayton'), (point(36.71182, 4.04591), 'Tizi Ouzou'), (point(7.13993, -4.50396), 'Ngata Kokokro'), (point(52.24794, 10.65506), 'Cremlingen'), (point(29.98521, 102.999), 'Ya''an'), (point(45.37107, 3.31981), 'Vergongheon'), (point(36.4575, 4.53494), 'Akbou'), (point(48.00876, 7.38556), 'Sainte-Croix-en-Plaine'), (point(6.83328, -5.49849), 'Baonfla'), (point(47.40819, 8.39719), 'Dietikon / Vorstadt'), (point(51.15, 2.75), 'Lombardsijde'), (point(44.98807, 3.88416), 'Cussac-sur-Loire'), (point(21.91524, -80.01929), 'Topes de Collantes'), (point(7.81227, -7.64852), 'Doué'), (point(32.88972, 108.90444), 'Hanbin'), (point(53.35, -2.33333), 'Ashley'), (point(51.02306, -2.86753), 'Curry Rivel'), (point(-27.57196, 152.84379), 'Barellan Point'), (point(37.02444, 111.9125), 'Jiexiu'), (point(6.11982, 1.19012), 'Aflao'), (point(51.82044, -4.0071), 'Llandybie'), (point(48.23333, 2.9), 'Lorrez-le-Bocage-Préaux'), (point(49.73973, 10.15072), 'Kitzingen'), (point(53.25779, -3.97423), 'Llanfairfechan'), (point(36.62442, -5.16971), 'Júzcar'), (point(9.15881, -2.95076), 'Sypaldouo'), (point(34.6838, 105.81), 'Guochuan'), (point(48.58288, 2.12504), 'Saint-Maurice-Montcouronne');

DELETE FROM test_spgist WHERE pt ~= ANY
('{"(45.64746, 0.36723)", "(52.6291, -2.0577)", "(38.40602, -4.30492)", "(40.66441, -5.07719)", "(48.1729, 0.65781)", "(41.94606, -5.09693)", "(41.36477, -3.42964)", "(54.11687, -112.46863)", "(0.49113, 29.47306)", "(6.25184, -75.56359)", "(37.2025, 112.17806)", "(25.47047, 119.10348)", "(44.98807, 3.88416)", "(34.37667, 117.25056)", "(35.06937, -1.13706)", "(7.42647, -5.09685)", "(39.97938, -2.86143)", "(48.01754, 6.5882)", "(41.09439, -5.60168)", "(51.31667, -2.42417)", "(29.70472, 106.00383)", "(53.38333, -1.36667)", "(6.83328, -5.49849)", "(-33.61169, -70.57577)", "(18.37825, -68.609)", "(36.71182, 4.04591)", "(42.40445, -4.24484)", "(42.14797, -0.36049)", "(49.36528, 8.58306)", "(6.50788, -5.11929)", "(7.81227, -7.64852)", "(36.79075, -4.16146)", "(8.94334, -4.24796)", "(14.50998, -92.19298)", "(43.5936, 3.11439)", "(53.60341, 8.87876)", "(43.73917, -79.24576)", "(39.31121, 26.22056)", "(41.49001, -6.1367)", "(50.7832, 4.67503)", "(49.04, 3.95922)", "(8.54791, -4.34636)", "(29.10644, 119.64855)", "(37.91116, -6.82045)", "(37.41042, -3.17158)", "(42.79019, -1.82822)", "(45.53694, 5.67333)", "(40.90723, -2.32325)", "(28.96302, -13.54769)", "(36.6563, -4.83433)", "(43.46686, -3.60083)", "(41.55, 1.51667)", "(34.84422, 111.19131)", "(49.89444, 7.4775)", "(50.86643, 13.32285)", "(-34.92654, 138.57033)", "(51.65446, -3.02281)", "(8.0, -5.56667)", "(48.90472, 2.2469)", "(52.09216, -1.02602)", "(4.68116, -74.71406)", "(41.08663, -5.70219)", "(54.50344, -6.76723)", "(30.55258, 31.00904)", "(53.60126, -2.54975)", "(44.83883, 4.8905)", "(43.97799, 81.51804)", "(46.38973, -0.41584)", "(41.01925, -5.00873)", "(5.98696, -5.73638)", "(38.87933, -0.36115)", "(46.83162, -0.86102)", "(26.47681, 119.60517)", "(32.89139, 108.50472)", "(46.51217, 9.85794)", "(40.33333, -3.38333)", "(60.26013, 20.77892)", "(50.70535, 1.5897)", "(5.79833, -5.29786)", "(-27.79653, 153.2567)"}');

INSERT INTO test_spgist(pt, t) VALUES 
(point(46.31807, 6.33148), 'Massongy'), (point(50.23019, 8.77155), 'Karben'), (point(47.24723, 132.02957), 'Fujin'), (point(49.73461, 4.78616), 'Lumes'), (point(40.06667, -0.6), 'Fuente la Reina'), (point(43.31453, 17.8029), 'Rodoč'), (point(41.1073, -1.35904), 'Nombrevilla'), (point(47.19916, 7.96964), 'Altishofen'), (point(51.10905, 0.56), 'Sissinghurst'), (point(47.73333, 8.16667), 'Höchenschwand'), (point(41.98375, -5.18117), 'Aguilar de Campos'), (point(47.66003, 8.84782), 'Wagenhausen'), (point(44.0288, 5.94032), 'Peyruis'), (point(52.00713, -0.26565), 'Arlesey'), (point(38.56144, -6.3381), 'Villafranca de los Barros'), (point(4.17864, -74.42311), 'San Bernardo'), (point(44.84723, 0.39103), 'Lamonzie'), (point(40.06667, -0.48333), 'Arañuel'), (point(54.35271, -2.76151), 'Burneside'), (point(52.91149, -0.64184), 'Grantham'), (point(47.72387, -1.73265), 'Grand-Fougeray'), (point(41.08037, 113.96047), 'Shangyi'), (point(38.62139, 21.40778), 'Agrínio'), (point(50.27574, 9.36705), 'Bad Soden-Salmünster'), (point(52.84291, -1.34188), 'Castle Donington'), (point(55.88886, -3.88664), 'Caldercruix'), (point(52.21358, -0.88582), 'Hardingstone'), (point(28.5825, 112.35028), 'Heshan'), (point(29.32074, 105.56942), 'Shuanghe'), (point(38.70679, -0.98723), 'Caudete'), (point(49.06444, 8.97639), 'Pfaffenhofen'), (point(-32.92771, 151.7884), 'Newcastle East'), (point(22.95052, -82.59435), 'Caimito'), (point(48.96128, 1.79245), 'Mézières-sur-Seine'), (point(13.97722, -90.20639), 'Pasaco'), (point(55.6666, 12.40377), 'Glostrup'), (point(6.01203, -3.19024), 'Bianouan'), (point(13.53333, -15.41667), 'Sara Kunda'), (point(-5.95609, 28.01649), 'Nyunzu'), (point(13.45944, -16.70528), 'Kotu'), (point(6.70516, -4.10607), 'Zanfouénou'), (point(49.91087, 10.83212), 'Bischberg'), (point(28.68264, -14.00637), 'El Cotillo'), (point(33.38639, 114.01583), 'Baicheng'), (point(47.40826, -0.76331), 'Saint-Georges-sur-Loire'), (point(47.1815, -1.17636), 'La Regrippière'), (point(50.53352, 2.84709), 'Salomé'), (point(50.70447, 3.3462), 'Warcoing'), (point(52.80837, 9.96374), 'Bergen'), (point(43.1831, -5.34476), 'Campo de Caso'), (point(41.5159, 2.12457), 'Barberà del Vallès'), (point(50.53333, -2.45), 'Easton'), (point(42.11109, -0.15298), 'Angüés'), (point(48.74069, 16.75499), 'Valtice'), (point(55.58548, -2.00415), 'Doddington'), (point(52.26642, 0.37439), 'Exning'), (point(36.11556, 119.53333), 'Baichihe'), (point(55.82885, -4.21376), 'Rutherglen'), (point(51.55, -0.1), 'Highbury'), (point(27.69375, 110.95333), 'Xixi'), (point(43.62841, 6.22477), 'Aups'), (point(42.12299, 1.77378), 'Castellar del Riu'), (point(8.13484, -3.0707), 'Amodi'), (point(9.75574, 13.9647), 'Figuil'), (point(7.37739, -3.0987), 'Atokouadiokro'), (point(38.25, 105.98333), 'Huangyangtan'), (point(46.74048, -1.60911), 'Aizenay'), (point(49.17309, 7.65111), 'Lemberg'), (point(52.87946, -118.08041), 'Jasper'), (point(53.69803, -2.46494), 'Darwen'), (point(42.51222, -8.8131), 'Cambados'), (point(-33.90748, 151.20857), 'Zetland'), (point(44.23831, 4.71286), 'Mondragon'), (point(53.85, 9.71667), 'Brande-Hörnerkirchen'), (point(50.10038, 8.6295), 'Gallus'), (point(30.08101, 106.42897), 'Guandu'), (point(6.99847, -5.51243), 'Kouakou'), (point(50.83608, 4.86282), 'Roosbeek'), (point(53.41667, 7.18333), 'Hinte'), (point(48.1995, 6.34929), 'Darnieulles'), (point(40.21041, -5.08694), 'Arenas de San Pedro'), (point(37.44466, 24.9429), 'Ermoúpolis'), (point(42.32729, -6.09573), 'Destriana'), (point(-31.85941, 115.94512), 'Bennett Springs'), (point(43.23339, 0.00123), 'Ibos'), (point(31.76667, 104.71667), 'Jiangyou'), (point(6.87735, -6.45022), 'Daloa'), (point(7.5025, -5.84694), 'Oueproye'), (point(44.89334, 82.06993), 'Bole'), (point(6.03333, 37.55), 'Arba Minch'), (point(59.10139, 27.30806), 'Iisaku'), (point(38.0218, -1.05749), 'Santa Cruz'), (point(55.8964, -3.30845), 'Currie'), (point(7.09986, -5.07589), 'Ziziessou'), (point(51.51232, 0.36753), 'Orsett'), (point(6.82898, -6.51516), 'Kibouo'), (point(55.45445, -4.26644), 'Cumnock'), (point(6.79928, -6.01422), 'Dianoufla'), (point(40.33622, -2.4625), 'Buciegas'), (point(49.18014, 6.64702), 'Ham-sous-Varsberg'), (point(40.87556, 113.88389), 'Xinghe Chengguanzhen'), (point(7.92084, -3.37655), 'Gondia'), (point(49.04833, 3.51047), 'Crézancy'), (point(8.33769, -6.88623), 'Kohimon'), (point(51.13643, 0.22931), 'Rusthall'), (point(-27.68273, 153.06082), 'Heritage Park'), (point(5.73127, -75.14257), 'Argelia'), (point(44.46559, 2.9736), 'Saint-Geniez-d''Olt'), (point(40.4578, -5.04833), 'Cepeda la Mora'), (point(47.05495, 6.8868), 'Fontainemelon'), (point(28.89984, 106.44023), 'Zhongfeng'), (point(16.83912, 112.34064), 'Sansha'), (point(50.62347, -4.7319), 'Delabole'), (point(45.56678, -71.99909), 'Windsor'), (point(36.9776, -3.53949), 'Nigüelas'), (point(48.62032, 6.16747), 'Ludres'), (point(51.94999, -103.80102), 'Wadena'), (point(52.11599, -0.50044), 'Kempston'), (point(50.28477, 5.79236), 'Lierneux'), (point(50.34856, -3.99877), 'Yealmpton'), (point(23.04053, 101.03683), 'Ning’er'), (point(51.03659, -0.02798), 'Horsted Keynes'), (point(8.3, 35.58333), 'Metu'), (point(43.55833, 128.02389), 'Huangnihe'), (point(-4.33111, 20.58638), 'Ilebo'), (point(37.63707, 22.80504), 'Ayía Triás'), (point(52.44254, 13.58228), 'Berlin Köpenick'), (point(43.30643, -2.38517), 'Mutriku'), (point(48.55656, 9.43211), 'Erkenbrechtsweiler'), (point(7.4189, -4.07484), 'Kongoti'), (point(22.19534, -78.9123), 'Chambas'), (point(50.59833, 4.32848), 'Nivelles'), (point(-19.32968, 146.71663), 'Condon'), (point(39.3181, 2.99197), 'Colònia de Sant Jordi'), (point(18.41139, -71.24558), 'El Palmar'), (point(52.68154, -1.82549), 'Lichfield'), (point(43.36859, -1.79622), 'Hondarribia'), (point(43.70469, -79.40359), 'Yonge-Eglinton'), (point(45.95749, 1.20472), 'Saint-Jouvent'), (point(-42.92073, 147.32069), 'Mount Nelson'), (point(40.13333, -0.61667), 'Olba'), (point(46.39652, 2.85717), 'Villefranche-d''Allier'), (point(48.96585, 8.60573), 'Königsbach-Stein'), (point(-4.38181, -79.9437), 'Macará'), (point(5.61538, -73.61701), 'Sutamarchán'), (point(14.74185, -91.15676), 'Panajachel'), (point(50.66317, 3.81929), 'Isières'), (point(50.78259, -2.99787), 'Axminster'), (point(41.10778, 121.14167), 'Jinzhou'), (point(56.13364, -3.83835), 'Tullibody'), (point(5.19889, -74.89295), 'San Sebastián de Mariquita'), (point(41.1047, -4.19411), 'Escarabajosa de Cabezas'), (point(48.57178, 9.26834), 'Bempflingen'), (point(-1.43795, -79.75647), 'Palenque'), (point(-5.9988, 23.25386), 'Kabeya-Kamwanga'), (point(48.71722, 0.43126), 'Sainte-Gauburge-Sainte-Colombe'), (point(48.4, 12.45), 'Egglkofen'), (point(26.79097, 113.53975), 'Chaling Chengguanzhen'), (point(50.92741, -1.33282), 'West End'), (point(51.26342, 14.25523), 'Horka'), (point(6.98533, 15.64062), 'Bocaranga'), (point(-33.75005, 150.93542), 'Kings Langley'), (point(41.41492, -4.16071), 'Olombrada'), (point(5.69753, -4.72254), 'Amani'), (point(54.30663, 9.66313), 'Rendsburg'), (point(54.98333, -6.66667), 'Garvagh'), (point(51.97204, 13.60115), 'Golßen'), (point(48.68333, 9.28333), 'Neuhausen auf den Fildern'), (point(9.81189, -7.20922), 'Zeguetiela'), (point(52.1549, 8.04216), 'Bad Iburg'), (point(-35.21752, 149.07704), 'McKellar'), (point(48.94956, 13.20102), 'Rinchnach'), (point(48.79787, 8.43617), 'Bad Herrenalb'), (point(41.00685, -2.7762), 'Baides'), (point(36.61954, 4.08282), 'Beni Douala'), (point(52.73494, 10.2354), 'Eschede'), (point(43.36313, -2.87294), 'Gatika'), (point(14.98436, -91.54912), 'San Carlos Sija'), (point(41.83248, -1.45979), 'Magallón'), (point(6.43832, -8.1561), 'Tinhou'), (point(47.39254, 8.04422), 'Aarau'), (point(47.80376, 12.28512), 'Frasdorf'), (point(47.50618, 8.71563), 'Veltheim (Kreis 5) / Blumenau'), (point(50.65322, 3.44468), 'Mourcourt'), (point(7.88644, -5.97115), 'Tiérouma'), (point(43.98028, 81.31417), 'Dadamtu'), (point(53.38333, 9.65), 'Regesbostel'), (point(47.91466, -3.33482), 'Plouay'), (point(6.33333, 10.23333), 'Mme-Bafumen'), (point(28.66667, 97.51667), 'Gyigang'), (point(52.63598, 13.20419), 'Hennigsdorf'), (point(51.49607, 9.385), 'Hofgeismar'), (point(39.54595, -0.57069), 'Ribarroja del Turia'), (point(40.78485, 48.15141), 'İsmayıllı'), (point(47.74717, 8.70724), 'Thayngen'), (point(51.48098, -1.61827), 'Aldbourne'), (point(50.79201, 3.74862), 'Opbrakel'), (point(47.0862, 7.52727), 'Fraubrunnen'), (point(34.73319, 106.35373), 'Qinting'), (point(44.26059, 4.19817), 'Saint-Ambroix'), (point(-27.5405, 153.08221), 'Mount Gravatt East'), (point(-3.62437, 18.84943), 'Dungu'), (point(50.81266, 5.01771), 'Wommersom'), (point(37.2515, 100.42133), 'Ha’ergai Dadui'), (point(39.46588, -0.42589), 'Xirivella'), (point(7.73673, -4.25837), 'Moussobadougou'), (point(-27.14447, 152.99968), 'Burpengary East'), (point(36.44667, 118.85972), 'Tangwu'), (point(47.0311, 8.28547), 'Kriens'), (point(37.19652, 79.70572), 'Jiahanbage'), (point(37.96939, -1.21714), 'Alcantarilla'), (point(51.18769, 4.64918), 'Viersel'), (point(31.21093, 109.32154), 'Dashu'), (point(53.07687, -2.11297), 'Endon'), (point(19.85723, 109.26271), 'Eman'), (point(28.97091, 102.77126), 'Xinshiba'), (point(50.13675, 10.52321), 'Hofheim in Unterfranken'), (point(51.54057, -0.14334), 'Camden Town'), (point(45.8371, 1.49025), 'Saint-Léonard-de-Noblat'), (point(5.38138, -3.5655), 'Ono Salci'), (point(48.88693, 2.06367), 'Fourqueux'), (point(13.4, -14.08333), 'Kulari'), (point(51.92664, 9.64282), 'Eschershausen'), (point(42.55201, 2.97129), 'Sant Andreu de Sureda'), (point(49.05917, 8.65833), 'Gondelsheim'), (point(36.07616, 115.19905), 'Nanle Chengguanzhen'), (point(50.59883, 3.09056), 'Ronchin'), (point(54.44983, -1.10687), 'Ingleby Greenhow'), (point(51.35851, 4.86513), 'Merksplas'), (point(47.89327, 1.9154), 'Saint-Jean-le-Blanc'), (point(32.94083, 117.36083), 'Bengbu'), (point(14.61075, -90.65681), 'San Lucas Sacatepéquez'), (point(40.3769, -0.1397), 'Benassal'), (point(55.63668, -3.88736), 'Lesmahagow'), (point(47.43633, 8.84629), 'Turbenthal'), (point(53.83292, 9.9581), 'Kaltenkirchen'), (point(41.5279, -2.27135), 'Bliecos'), (point(42.18665, 2.91706), 'Pontós'), (point(19.69841, -71.74513), 'Pepillo Salcedo'), (point(50.62613, -1.1785), 'Shanklin'), (point(48.9295, 1.84113), 'Aulnay-sur-Mauldre'), (point(39.91222, 116.35615), 'Jinrongjie'), (point(47.65127, -0.44423), 'Étriché'), (point(13.43333, -15.51667), 'Karantaba'), (point(-32.02058, 115.91181), 'Wilson'), (point(5.4519, -73.81436), 'Susa'), (point(6.74696, -4.25821), 'Assé-Assasso'), (point(41.29657, -1.89358), 'Alhama de Aragón'), (point(28.81667, -17.93333), 'Garafía'), (point(48.21667, 11.88333), 'Ottenhofen'), (point(50.47805, 4.61031), 'Velaine'), (point(40.95, 0.31667), 'Horta de Sant Joan'), (point(50.0, 6.5), 'Rittersdorf'), (point(35.05365, 33.24292), 'Ergátes'), (point(45.34725, 130.83693), 'Didao'), (point(42.08166, -6.18723), 'Molezuelas de la Carballeda'), (point(42.08826, -0.77587), 'Marracos'), (point(45.71884, 5.22586), 'Villemoirieu'), (point(60.24015, 23.71789), 'Karjalohja'), (point(53.60885, -1.28214), 'North Elmsall'), (point(52.50618, 6.80354), 'Itterbeck'), (point(-33.93848, 151.11385), 'Bexley North'), (point(37.37301, -5.74951), 'Mairena del Alcor'), (point(48.5883, 9.70393), 'Bad Ditzenbach'), (point(48.14636, 1.6838), 'Orgères-en-Beauce'), (point(42.32974, -2.86185), 'San Millán de la Cogolla'), (point(61.31667, 22.13333), 'Harjavalta'), (point(40.9809, -5.54922), 'Aldealengua'), (point(50.88939, 5.52647), 'Munsterbilzen'), (point(56.48072, 9.62537), 'Ørum'), (point(43.10759, 3.08651), 'Gruissan'), (point(49.67552, 6.67085), 'Pellingen'), (point(50.68428, 4.57186), 'Limelette'), (point(33.69928, 105.02014), 'Sanyu'), (point(29.15897, 105.74703), 'Ji’an'), (point(47.36334, 8.82418), 'Hittnau / Hittnau (Dorf)'), (point(47.36372, 8.50417), 'Zürich (Kreis 3) / Friesenberg'), (point(8.97252, -6.27608), 'Gbatosso'), (point(50.58702, -1.28489), 'Niton'), (point(23.25191, 90.85508), 'Hājīganj'), (point(53.05, -0.85), 'Farndon'), (point(49.40834, 3.51631), 'Vailly-sur-Aisne'), (point(38.38333, 22.63333), 'Antikyra'), (point(38.86651, -0.39991), 'Ráfol de Salem'), (point(46.7321, 6.46266), 'Les Clées'), (point(48.63944, -3.82308), 'Plouezoc''h'), (point(45.57345, 5.47741), 'Saint-Clair-de-la-Tour'), (point(46.01767, 3.35478), 'Randan'), (point(29.28222, 106.89806), 'Shilong'), (point(4.8543, -73.04003), 'Sabanalarga'), (point(47.55317, -2.48209), 'Muzillac'), (point(50.50622, 2.58904), 'Gosnay'), (point(53.13333, -1.2), 'Mansfield'), (point(52.43367, 9.32473), 'Hagenburg'), (point(53.43265, -2.19967), 'Burnage'), (point(39.59862, -3.11782), 'La Puebla de Almoradiel'), (point(41.45664, -3.91835), 'Fuentesoto'), (point(52.68554, -1.39965), 'Ibstock'), (point(19.56667, -70.26667), 'Joba Arriba'), (point(51.52162, -3.39145), 'Pontyclun'), (point(52.25266, -1.3884), 'Southam'), (point(49.55496, 0.1166), 'Octeville-sur-Mer'), (point(46.15944, 6.34237), 'Fillinges'), (point(27.36439, 118.85711), 'Xiongshan'), (point(50.66773, 13.83601), 'Proboštov'), (point(47.40187, 8.58633), 'Zürich (Kreis 12) / Hirzenbach'), (point(50.62185, -4.67963), 'Camelford'), (point(51.39805, -0.8759), 'Barkham'), (point(7.16903, -5.004), 'Assembo'), (point(39.83659, -5.52307), 'Valdehúncar'), (point(4.23333, 13.45), 'Doumé'), (point(50.76942, 9.10389), 'Kirtorf'), (point(43.71095, -0.83952), 'Montfort-en-Chalosse'), (point(-3.36, 15.47583), 'Abala'), (point(47.58685, -3.00032), 'Saint-Philibert'), (point(50.59449, -1.20672), 'Ventnor'), (point(-27.61251, 152.74577), 'Sadliers Crossing'), (point(48.72415, 7.75188), 'Geudertheim'), (point(42.51235, 0.49241), 'Castejón de Sos'), (point(22.15021, -79.97867), 'Manicaragua'), (point(46.82107, 8.40133), 'Engelberg'), (point(-27.46298, 153.01312), 'Petrie Terrace'), (point(51.77294, -0.99684), 'Long Crendon'), (point(41.06997, 1.05949), 'Cambrils'), (point(37.37628, -6.96895), 'Gibraleón'), (point(37.91522, 120.73247), 'Nanchangshan'), (point(54.88169, -2.82452), 'Great Corby'), (point(52.61024, 8.48093), 'Rehden'), (point(51.13929, -0.11742), 'Copthorne'), (point(38.02467, 114.83665), 'Gaocheng'), (point(44.18274, 2.78714), 'Salles-Curan'), (point(-38.71122, -73.16101), 'Carahue'), (point(-37.54087, 143.86648), 'Ballarat North'), (point(25.66667, 104.23333), 'Zhong’an'), (point(36.46298, 2.81464), 'Boû Arfa'), (point(47.49201, 8.25412), 'Turgi'), (point(49.39845, 10.51323), 'Flachslanden'), (point(50.35441, 2.80146), 'Thélus'), (point(50.87304, 14.77035), 'Olbersdorf'), (point(53.31667, 9.66667), 'Heidenau'), (point(3.88857, -51.80243), 'Saint-Georges'), (point(-53.15483, -70.91129), 'Punta Arenas'), (point(14.53611, -91.67778), 'Retalhuleu'), (point(47.76373, -3.23913), 'Kervignac'), (point(39.16667, -0.25), 'Cullera'), (point(41.7179, 45.1757), 'Sartich’ala'), (point(51.29068, 11.93269), 'Großkayna'), (point(43.4322, -1.55149), 'Arbonne'), (point(34.33778, 108.70261), 'Xianyang'), (point(42.45775, -3.46965), 'Monasterio de Rodilla'), (point(51.93649, 1.27831), 'Dovercourt'), (point(48.76227, 9.59991), 'Adelberg'), (point(-0.71933, 8.78151), 'Port-Gentil'), (point(54.8687, -3.38448), 'Silloth'), (point(49.92113, 2.96766), 'Doingt'), (point(-8.20591, 26.42036), 'Kipamba'), (point(50.8, 3.16667), 'Wevelgem'), (point(41.79117, 0.81094), 'Balaguer'), (point(34.44139, 107.61778), 'Fengming'), (point(40.38866, -3.70035), 'Usera'), (point(27.83906, 114.84591), 'Xinyu'), (point(49.63333, 0.53746), 'Yébleron'), (point(47.43093, 9.63448), 'Au'), (point(54.15, 9.28333), 'Albersdorf'), (point(54.33333, 9.66667), 'Rickert'), (point(50.7787, 5.13096), 'Velm'), (point(48.68872, 6.24353), 'Saulxures-lès-Nancy'), (point(48.52961, 12.16179), 'Landshut'), (point(-34.56229, 150.82193), 'Oak Flats'), (point(18.5, -69.9), 'Ensanche Luperón'), (point(-32.295, 115.78), 'Cooloongup'), (point(41.78333, 2.51667), 'Riells i Viabrea'), (point(48.43197, 0.03398), 'Condé-sur-Sarthe'), (point(52.04996, -0.88663), 'Deanshanger'), (point(43.88014, 18.07452), 'Polje'), (point(40.67978, 114.37705), 'Huai’an'), (point(22.76307, -81.4478), 'Bolondrón'), (point(43.43568, 1.66281), 'Villenouvelle'), (point(51.90224, -0.20256), 'Stevenage'), (point(9.9453, -84.0669), 'Calle Blancos'), (point(55.92437, -4.41545), 'Duntocher'), (point(35.50333, 119.17167), 'Sanzhuang'), (point(5.99533, -5.60615), 'Abatoulilié'), (point(37.26273, -5.5453), 'El Arahal'), (point(44.35166, 2.03702), 'Villefranche-de-Rouergue'), (point(31.18352, 30.52448), 'Al Maḩmūdīyah'), (point(38.7101, -5.79847), 'Valle de la Serena'), (point(41.20835, -3.73387), 'Castroserna de Abajo'), (point(50.33224, 3.41252), 'Wavrechain-sous-Denain'), (point(48.78063, 0.65739), 'Saint-Sulpice-sur-Risle'), (point(5.21132, -4.32612), 'Avagou'), (point(9.88147, -85.52809), 'Sámara'), (point(50.24413, 127.49016), 'Heihe'), (point(47.83124, 1.69582), 'Meung-sur-Loire'), (point(49.01367, 2.46595), 'Goussainville'), (point(50.949, 6.9479), 'Neustadt/Nord'), (point(51.51873, -0.97753), 'Sonning Common'), (point(42.17229, -2.61793), 'Gallinero de Cameros'), (point(47.04786, 3.09625), 'Garchizy'), (point(49.3025, -1.21995), 'Saint-Hilaire-Petitville');

DELETE FROM test_spgist WHERE pt ~= ANY
('{"(50.70447, 3.3462)", "(36.46298, 2.81464)", "(50.58702, -1.28489)", "(51.13643, 0.22931)", "(13.97722, -90.20639)", "(7.4189, -4.07484)", "(49.05917, 8.65833)", "(51.51873, -0.97753)", "(46.7321, 6.46266)", "(43.4322, -1.55149)", "(47.55317, -2.48209)", "(7.37739, -3.0987)", "(9.9453, -84.0669)", "(-19.32968, 146.71663)", "(4.23333, 13.45)", "(47.80376, 12.28512)", "(53.85, 9.71667)", "(48.4, 12.45)", "(33.69928, 105.02014)", "(47.36372, 8.50417)", "(47.36334, 8.82418)", "(42.18665, 2.91706)", "(40.38866, -3.70035)", "(13.53333, -15.41667)", "(43.43568, 1.66281)", "(48.78063, 0.65739)", "(48.55656, 9.43211)", "(52.1549, 8.04216)", "(36.11556, 119.53333)", "(50.47805, 4.61031)", "(42.08166, -6.18723)", "(37.2515, 100.42133)", "(50.66773, 13.83601)", "(49.55496, 0.1166)", "(48.96585, 8.60573)", "(33.38639, 114.01583)", "(48.79787, 8.43617)", "(49.67552, 6.67085)", "(47.05495, 6.8868)", "(-32.02058, 115.91181)", "(50.50622, 2.58904)", "(49.06444, 8.97639)", "(-33.75005, 150.93542)", "(6.79928, -6.01422)", "(51.35851, 4.86513)", "(5.61538, -73.61701)", "(54.33333, 9.66667)", "(51.03659, -0.02798)", "(48.76227, 9.59991)", "(40.06667, -0.48333)", "(52.26642, 0.37439)", "(41.98375, -5.18117)", "(47.40826, -0.76331)", "(50.34856, -3.99877)", "(13.45944, -16.70528)", "(41.00685, -2.7762)", "(44.0288, 5.94032)", "(38.62139, 21.40778)", "(50.33224, 3.41252)", "(60.24015, 23.71789)", "(50.88939, 5.52647)", "(-42.92073, 147.32069)", "(50.7787, 5.13096)", "(13.4, -14.08333)", "(16.83912, 112.34064)", "(46.15944, 6.34237)", "(41.7179, 45.1757)", "(43.36313, -2.87294)", "(27.69375, 110.95333)", "(55.92437, -4.41545)", "(23.04053, 101.03683)", "(37.37301, -5.74951)", "(14.74185, -91.15676)", "(47.0311, 8.28547)", "(42.55201, 2.97129)", "(29.32074, 105.56942)", "(55.45445, -4.26644)", "(51.52162, -3.39145)", "(52.61024, 8.48093)", "(54.15, 9.28333)"}');

INSERT INTO test_spgist(pt, t) VALUES 
(point(6.40004, -4.82095), 'Didakouadiokro'), (point(38.06667, 23.5), 'Mándra'), (point(38.7759, -0.39079), 'Benimarfull'), (point(51.75571, 8.04075), 'Beckum'), (point(41.60045, -1.28007), 'Épila'), (point(31.28284, 110.06983), 'Zhuxian'), (point(44.49713, 4.79068), 'Allan'), (point(52.774, -1.55744), 'Swadlincote'), (point(48.58333, 8.68333), 'Ebhausen'), (point(32.01417, 120.2625), 'Jingjiang'), (point(8.3372, -6.98278), 'Soko'), (point(42.65667, 44.64333), 'St’epants’minda'), (point(26.20113, 119.53492), 'Lianjiang'), (point(50.91125, 8.53016), 'Biedenkopf'), (point(47.9853, -0.7835), 'Nuillé-sur-Vicoin'), (point(45.68563, 5.04484), 'Saint-Laurent-de-Mure'), (point(50.45, 7.2), 'Oberzissen'), (point(-38.16623, 144.39429), 'Newcomb'), (point(41.9, 2.28333), 'Santa Eugènia de Berga'), (point(8.45746, -6.65074), 'Gbédéguéla'), (point(47.57039, 7.66425), 'Bettingen'), (point(49.40996, 1.23742), 'Montmain'), (point(50.42686, 6.02794), 'Malmédy'), (point(37.74425, -0.85041), 'Los Alcázares'), (point(5.54297, -3.63473), 'Abrotchi'), (point(42.20518, -4.56841), 'Manquillos'), (point(5.884, -6.84575), 'Koupéro'), (point(46.45962, 6.20813), 'Arzier'), (point(45.77255, 4.80326), 'Lyon 09'), (point(24.98773, 118.3858), 'Ximeicun'), (point(4.58056, 9.66472), 'Njombé'), (point(50.38333, 7.73333), 'Kadenbach'), (point(6.80004, -1.08193), 'Agogo'), (point(40.05582, -6.61568), 'Huélaga'), (point(22.991, 99.63453), 'Mujia'), (point(6.8166, -4.99457), 'Morokinkro'), (point(48.53333, -2.06667), 'Pleslin-Trigavou'), (point(49.2317, 8.46074), 'Philippsburg'), (point(53.4152, 10.37524), 'Marschacht'), (point(51.65035, 10.23681), 'Hattorf'), (point(37.41802, -6.15603), 'Olivares'), (point(7.17487, -2.09961), 'Duayaw-Nkwanta'), (point(51.76152, 10.17591), 'Eisdorf am Harz'), (point(53.61766, -2.1552), 'Rochdale'), (point(7.9177, -5.45856), 'Babroukro'), (point(53.22698, 8.79528), 'Osterholz-Scharmbeck'), (point(-33.02493, 137.52471), 'Whyalla Stuart'), (point(42.40394, 3.15153), 'Colera'), (point(3.53944, -76.30361), 'Palmira'), (point(8.27819, -2.53031), 'Zarala'), (point(47.61497, 7.66457), 'Lörrach'), (point(47.89295, 10.07837), 'Aichstetten'), (point(62.61667, 26.31667), 'Konnevesi'), (point(41.349, 26.49377), 'Didymóteicho'), (point(7.2, 37.66667), 'Hadero'), (point(51.39214, 4.59546), 'Wuustwezel'), (point(43.7864, 7.27598), 'Tourrette-Levens'), (point(5.35977, -4.18641), 'Ayéwahi'), (point(43.6894, -1.37328), 'Seignosse'), (point(48.11127, 9.27238), 'Bingen'), (point(49.16248, 2.84556), 'Péroy-les-Gombries'), (point(47.38946, 8.48533), 'Zürich (Kreis 9) / Altstetten'), (point(-26.68864, 153.00453), 'Forest Glen'), (point(35.4922, 112.40428), 'Yangcheng'), (point(40.85785, 48.9354), 'Altıağac'), (point(47.47318, 8.67569), 'Brütten'), (point(38.46354, 23.60284), 'Chalkída'), (point(53.30182, -1.12404), 'Worksop'), (point(40.95498, 0.27749), 'Lledó'), (point(5.82346, -5.59998), 'Djimon'), (point(43.3217, 5.41551), 'Malpassé'), (point(43.69506, 1.26892), 'Daux'), (point(53.85315, -2.87026), 'Great Eccleston'), (point(46.18333, 5.58333), 'Montréal-la-Cluse'), (point(-1.17454, 13.87562), 'Akiéni'), (point(48.38215, 7.70395), 'Gerstheim'), (point(54.04367, -2.89322), 'Heysham'), (point(7.51387, -3.04915), 'Bissassé'), (point(55.32419, -4.402), 'Dalmellington'), (point(37.50914, 122.11356), 'Weihai'), (point(43.21986, -3.4392), 'Lanestosa'), (point(43.62975, -0.82991), 'Pomarez'), (point(51.56917, 9.24113), 'Borgentreich'), (point(53.35707, 8.64341), 'Hagen im Bremischen'), (point(60.56667, 21.96667), 'Lemu'), (point(8.88479, -75.79052), 'Cereté'), (point(43.20814, 1.23008), 'Montesquieu-Volvestre'), (point(31.2837, 117.90193), 'Wucheng'), (point(50.81987, 12.54493), 'Glauchau'), (point(49.00139, 1.19305), 'Guichainville'), (point(43.25414, -2.47776), 'Etxebarria'), (point(45.94211, 6.43077), 'Le Grand-Bornand'), (point(41.27194, 123.17306), 'Liaoyang'), (point(49.93333, 11.96667), 'Neusorg'), (point(42.76667, -7.56667), 'Paradela'), (point(42.03761, 43.82382), 'Agara'), (point(49.58345, 12.52156), 'Eslarn'), (point(40.58254, -4.12846), 'El Escorial'), (point(42.96535, 1.60705), 'Foix'), (point(52.03333, 8.53333), 'Bielefeld'), (point(41.01053, -0.91882), 'Huesa del Común'), (point(31.07287, 31.49503), 'Maḩallat Damanah'), (point(50.20366, 16.23762), 'Solnice'), (point(53.21242, 13.31483), 'Lychen'), (point(7.13644, -7.94577), 'Féapleu'), (point(40.82143, 23.03008), 'Ássiros'), (point(49.91166, 8.20533), 'Nieder-Olm'), (point(48.47993, -4.33669), 'Saint-Thonan'), (point(54.06413, -0.38057), 'Kilham'), (point(-26.65682, 153.07955), 'Sunshine Coast'), (point(8.28424, -3.07011), 'Niangomani'), (point(8.12681, -3.22975), 'Dinaodi'), (point(53.51667, -1.31667), 'Bolton upon Dearne'), (point(49.22971, 9.15648), 'Bad Wimpfen'), (point(29.765, 105.66645), 'Zhong’ao'), (point(52.24893, -0.11827), 'Papworth Everard'), (point(34.03333, 117.95), 'Weiji'), (point(41.64327, -4.1011), 'Curiel de Duero'), (point(41.19194, 26.29944), 'Souflí'), (point(53.16981, 7.75012), 'Barßel'), (point(53.35, -1.55), 'Fulwood'), (point(6.84315, -72.69404), 'Cerrito'), (point(50.1887, -5.17807), 'Stithians'), (point(47.22683, 8.6687), 'Wädenswil'), (point(43.33618, 6.08346), 'Forcalqueiret'), (point(42.38333, -2.05709), 'Sartaguda'), (point(48.15053, 12.09335), 'Maitenbeth'), (point(37.48617, -3.83743), 'Frailes'), (point(52.14063, 8.55772), 'Enger'), (point(13.18361, -16.6975), 'Sifoe'), (point(56.95523, 8.69491), 'Thisted'), (point(53.94608, 13.2732), 'Bentzin'), (point(18.93687, -70.40923), 'Bonao'), (point(45.9554, 4.69251), 'Pommiers'), (point(42.60276, -3.07719), 'Altable'), (point(38.59751, -2.34421), 'Paterna del Madera'), (point(55.8151, -3.93733), 'Newarthill'), (point(48.06106, -0.57059), 'Soulgé-sur-Ouette'), (point(49.17598, -0.62605), 'Tilly-sur-Seulles'), (point(-35.32624, 149.11906), 'Red Hill'), (point(34.35521, 104.89759), 'Qiushan'), (point(42.67396, -3.19947), 'Miraveche'), (point(50.23333, 6.28333), 'Bleialf'), (point(23.74137, 106.91311), 'Tianzhou'), (point(49.59161, 8.20483), 'Obrigheim'), (point(48.62495, 6.20325), 'Fléville-devant-Nancy'), (point(6.92652, -6.45803), 'Tagoura'), (point(39.11667, -0.28333), 'Favara'), (point(47.76768, -3.5218), 'Guidel-Plage'), (point(50.43163, -4.94336), 'Saint Columb Major'), (point(30.76283, 108.43717), 'Bai’anba'), (point(41.99217, -6.44012), 'Manzanal de Arriba'), (point(29.23992, 102.37208), 'Xinmian'), (point(52.08226, 0.43891), 'Haverhill'), (point(51.31511, 3.3017), 'Westkapelle'), (point(47.29748, 8.55634), 'Thalwil / Nord'), (point(49.96509, 16.85894), 'Olšany'), (point(37.15637, 21.58532), 'Filiatrá'), (point(41.03569, -2.46645), 'Alcolea del Pinar'), (point(29.65, 91.1), 'Lhasa'), (point(46.36125, 4.9058), 'Manziat'), (point(43.91887, 1.36736), 'Labastide-Saint-Pierre'), (point(48.90881, 13.88657), 'Volary'), (point(54.44062, 9.12872), 'Rantrum'), (point(52.61863, 13.39057), 'Blankenfelde'), (point(51.44491, -0.02043), 'Catford'), (point(48.74861, 13.74699), 'Neureichenau'), (point(67.41667, 26.6), 'Sodankylä'), (point(50.74574, 3.6005), 'Ronse'), (point(43.65207, 3.55096), 'Gignac'), (point(45.876, 0.17838), 'Mansle'), (point(49.47965, 9.64006), 'Boxberg'), (point(40.61832, 47.15014), 'Yevlakh'), (point(-31.84103, 115.83978), 'Girrawheen'), (point(51.4975, -0.1357), 'City of Westminster'), (point(5.3359, -74.02659), 'San Cayetano'), (point(47.22655, 0.77306), 'Saint-Branchs'), (point(39.91726, -5.17371), 'Oropesa'), (point(53.67449, -1.94183), 'Ripponden'), (point(49.29507, 11.79906), 'Hohenburg'), (point(7.14984, -7.74593), 'Podiagouiné'), (point(19.80755, 109.34539), 'Mutang'), (point(51.02312, -0.45359), 'Billingshurst'), (point(38.91538, 111.86928), 'Yancheng'), (point(48.01731, -4.21049), 'Plonéis'), (point(45.74736, 4.69037), 'Grézieu-la-Varenne'), (point(6.26072, -4.71457), 'Kravassou'), (point(50.93449, 4.13504), 'Meldert'), (point(31.09023, 109.62397), 'Caotang'), (point(52.63723, 13.98783), 'Prötzel'), (point(49.96667, 7.6), 'Argenthal'), (point(-2.16671, -79.4654), 'Naranjito'), (point(34.44542, 2.52749), 'El Idrissia'), (point(45.32104, 4.77449), 'Sablons'), (point(38.55428, -6.06829), 'Hornachos'), (point(38.50062, 102.19379), 'Jinchang'), (point(46.09987, 3.19842), 'Gannat'), (point(6.48511, -75.0196), 'San Roque'), (point(29.81127, 107.92447), 'Lizi'), (point(39.07004, -3.61498), 'Daimiel'), (point(41.88333, 2.51667), 'Sant Hilari Sacalm'), (point(38.9, -0.5), 'Alfarrasí'), (point(47.42022, 8.43644), 'Weiningen'), (point(51.26171, 11.08999), 'Kindelbrück'), (point(42.25109, -8.07062), 'Cartelle'), (point(50.28939, 3.85672), 'La Longueville'), (point(7.50926, -4.58246), 'Allangouassou'), (point(54.33131, 9.02523), 'Lunden'), (point(-33.77784, 151.10574), 'Marsfield'), (point(48.078, -4.19488), 'Plogonnec'), (point(6.79419, -4.48514), 'Bingassou'), (point(37.35289, -6.19663), 'Benacazón'), (point(49.18327, -0.40426), 'Saint-Germain-la-Blanche-Herbe'), (point(34.56612, 103.58545), 'Mu’er'), (point(50.62578, 5.38819), 'Horion-Hozémont'), (point(56.77276, 9.33925), 'Farsø'), (point(55.83956, 12.06896), 'Frederikssund'), (point(9.50528, 42.61111), 'Ch’īna Hasen'), (point(48.85632, 9.79654), 'Durlangen'), (point(6.18859, -6.65891), 'Koréguhé'), (point(52.66625, 8.2375), 'Lohne'), (point(36.98788, -3.56601), 'Dúrcal'), (point(38.73402, 23.4906), 'Prokópi'), (point(43.03262, -2.40997), 'Oñati'), (point(51.10781, -0.15286), 'Maidenbower'), (point(50.84654, -1.06344), 'Cosham'), (point(40.16991, 49.46394), 'Sanqaçal'), (point(50.6582, 2.76872), 'Sailly-sur-la-Lys'), (point(41.03333, 0.25), 'Caseres'), (point(52.2228, 0.25878), 'Bottisham'), (point(47.87215, -3.54994), 'Quimperlé'), (point(51.45561, 11.0071), 'Berga'), (point(-4.77549, 17.89095), 'Masi-Manimba'), (point(51.93025, 12.59554), 'Nudersdorf'), (point(30.88251, 31.46275), 'As Sinbillāwayn'), (point(38.42892, 22.66728), 'Dístomo'), (point(6.02672, -5.6929), 'Bogoboua'), (point(-33.02205, 137.51269), 'Whyalla Jenkins'), (point(49.70038, 2.78959), 'Roye'), (point(47.86229, 9.37235), 'Illmensee'), (point(41.60093, 41.94008), 'Keda'), (point(43.41869, 3.23686), 'Lieuran-lès-Béziers'), (point(44.39982, 131.14775), 'Suifenhe'), (point(52.26667, 1.01667), 'Bacton'), (point(32.97944, 114.02944), 'Zhumadian'), (point(39.3895, 22.99948), 'Portariá'), (point(14.86899, -91.62137), 'Ostuncalco'), (point(-31.05757, 152.82794), 'West Kempsey'), (point(47.46867, 2.86981), 'Léré'), (point(19.66256, -71.19406), 'Hatillo Palma'), (point(5.68822, -73.91784), 'Briceño'), (point(-32.50857, 115.73599), 'Silver Sands'), (point(5.94737, -6.81144), 'Angagui'), (point(7.69832, -7.61275), 'Léma'), (point(47.41249, 0.98266), 'Amboise'), (point(51.36081, 8.40082), 'Bestwig'), (point(50.04003, 8.15545), 'Walluf'), (point(52.33757, -1.29136), 'Dunchurch'), (point(8.07806, -6.11889), 'Diénédian'), (point(29.2445, 105.88001), 'Weixinghu'), (point(37.14529, -3.56963), 'Huétor Vega'), (point(35.33893, 25.15972), 'Néa Alikarnassós'), (point(7.49375, -3.12271), 'Souleman'), (point(30.82972, 110.97778), 'Maoping'), (point(18.3353, -70.18113), 'Yaguate'), (point(54.7, 9.51667), 'Großsolt'), (point(40.98333, 24.8), 'Évlalo'), (point(50.2292, 9.11041), 'Mittel-Gründau'), (point(57.58094, -3.87973), 'Nairn'), (point(41.56683, -2.76288), 'Fuentepinilla'), (point(60.84614, 26.60755), 'Koria'), (point(-32.25784, 115.82208), 'Parmelia'), (point(-35.16701, 149.0947), 'Casey'), (point(36.76306, 112.68722), 'Dingchang'), (point(52.42958, 7.42653), 'Lünne'), (point(51.29158, 0.30478), 'Borough Green'), (point(55.92318, 12.07071), 'Ølsted'), (point(48.84226, 2.18232), 'Garches'), (point(-32.04913, 115.91838), 'Parkwood'), (point(40.3528, -5.30084), 'Navalperal de Tormes'), (point(49.37071, 3.89595), 'Cormicy'), (point(29.1135, 106.67237), 'Hengshan'), (point(6.63468, -4.30349), 'Nguessankro'), (point(8.38793, -4.298), 'Sobolo'), (point(12.31667, -9.11667), 'Nyagassola'), (point(45.55587, 0.27941), 'Dignac'), (point(43.5086, 3.8017), 'Mireval'), (point(47.517, 5.12979), 'Marcilly-sur-Tille'), (point(61.08333, 25.01667), 'Lammi'), (point(5.79473, 0.89728), 'Anloga'), (point(50.83509, -4.54499), 'Flexbury'), (point(41.68313, -3.52337), 'San Juan del Monte'), (point(54.59147, -1.01959), 'Marske-by-the-Sea'), (point(48.75782, 7.64494), 'Mommenheim'), (point(42.62655, 41.73808), 'Gali'), (point(50.91943, 4.56388), 'Nederokkerzeel'), (point(39.99417, 117.20861), 'Baijian'), (point(5.75692, -6.79092), 'Takoréagui'), (point(29.58398, 111.36796), 'Chujiang'), (point(48.16866, 11.91244), 'Forstinning'), (point(49.07158, 2.16978), 'Auvers-sur-Oise'), (point(4.94273, 15.87735), 'Carnot'), (point(48.40351, 11.74876), 'Freising'), (point(6.81532, -73.26768), 'Zapatoca'), (point(47.05901, 7.62786), 'Burgdorf'), (point(33.73847, 113.30119), 'Pingdingshan'), (point(51.8, -3.18333), 'Brynmawr'), (point(28.71471, 99.28633), 'Songmai'), (point(49.85384, 5.45009), 'Longlier'), (point(41.36117, -4.53348), 'Iscar'), (point(-20.7383, 116.83278), 'Pegs Creek'), (point(31.48319, 93.67741), 'Biru'), (point(52.0, -4.01667), 'Llansawel'), (point(53.78244, -2.87189), 'Kirkham'), (point(51.4647, 0.0079), 'Blackheath'), (point(45.81731, 1.09986), 'Saint-Priest-sous-Aixe'), (point(49.23302, 5.96553), 'Moutiers'), (point(53.15, -1.36667), 'Pilsley'), (point(36.99227, 22.70663), 'Geráki'), (point(55.10337, -3.58438), 'Locharbriggs'), (point(43.11333, 17.72), 'Tasovčići'), (point(-42.82895, 147.24735), 'Montrose'), (point(50.76387, 2.72227), 'Saint-Jans-Cappel'), (point(45.99539, 4.03463), 'Villerest'), (point(36.70396, -3.48971), 'Torrenueva'), (point(49.31535, 2.31954), 'Mouy'), (point(8.36321, -4.42863), 'Dabakala'), (point(5.37742, -3.74779), 'Akouré'), (point(55.95795, -3.46464), 'Winchburgh'), (point(9.80955, -3.34577), 'Doropo'), (point(8.92901, -75.02709), 'San Benito Abad'), (point(39.35461, 3.12907), 'Santanyí'), (point(6.89358, -5.29709), 'Séman'), (point(47.56494, -52.70931), 'St. John''s'), (point(24.36959, 114.48962), 'Yuanshan'), (point(45.31678, -73.51587), 'Saint-Mathieu'), (point(42.38734, 126.80969), 'Jingyu'), (point(48.55748, -2.53517), 'Saint-Alban'), (point(47.85, 10.9), 'Hohenfurch'), (point(45.53696, 1.7952), 'Treignac'), (point(47.43517, -0.10371), 'Jumelles'), (point(55.80966, -4.16096), 'Cambuslang'), (point(47.14738, -1.06286), 'Villedieu-la-Blouère'), (point(47.23431, 7.22239), 'Reconvilier'), (point(7.77135, -4.25267), 'Totodougou'), (point(42.44466, -6.24483), 'Santa Colomba de Somoza'), (point(5.8474, -4.06941), 'Mafa Mafou'), (point(38.82313, -0.2417), 'Vall de Gallinera'), (point(46.7891, 8.67325), 'Silenen'), (point(51.01753, 4.43891), 'Hombeek'), (point(28.46824, -16.25462), 'Santa Cruz de Tenerife'), (point(50.81667, 10.2), 'Leimbach'), (point(51.76263, 6.39778), 'Rees'), (point(23.48492, 111.27413), 'Changzhou'), (point(29.12789, 108.47043), 'Anzi'), (point(51.64528, -5.01694), 'Castlemartin'), (point(51.95453, 8.6622), 'Oerlinghausen'), (point(7.16639, -7.93973), 'Gouézépleu'), (point(49.72775, 18.1885), 'Stará Ves nad Ondřejnicí'), (point(42.66037, -4.31271), 'Alar del Rey'), (point(43.30213, 5.40141), 'Marseille 04'), (point(45.90984, 4.83265), 'Massieux'), (point(51.22172, 12.22349), 'Kitzen'), (point(36.21492, 28.11487), 'Archángelos'), (point(49.38694, 9.01056), 'Neunkirchen'), (point(54.52143, -3.5159), 'Cleator Moor'), (point(51.65623, -3.60371), 'Blaengwynfi'), (point(10.61306, -6.59528), 'Débélé'), (point(49.59737, 12.2584), 'Leuchtenberg'), (point(14.49452, -90.71036), 'Santa María de Jesús'), (point(51.12598, 1.31257), 'Dover'), (point(43.09725, -2.37998), 'Antzuola'), (point(50.52441, -4.21333), 'Gunnislake'), (point(51.37178, -0.45975), 'Weybridge'), (point(43.31283, -1.97499), 'Donostia / San Sebastián'), (point(52.23801, 10.71063), 'Destedt'), (point(53.09766, -1.38376), 'Alfreton'), (point(34.45528, 113.02806), 'Songyang'), (point(7.06528, -73.85472), 'Barrancabermeja'), (point(41.41758, 2.15914), 'El Carmel'), (point(51.35113, 3.28744), 'Knokke'), (point(36.36505, 4.32636), 'Chorfa'), (point(49.26667, 3.98333), 'Saint-Brice-Courcelles'), (point(37.40202, -6.03314), 'Camas'), (point(49.61237, 16.67947), 'Velké Opatovice'), (point(52.24951, 9.36147), 'Hülsede'), (point(45.16839, 1.38342), 'Mansac'), (point(49.19449, 2.54148), 'Avilly-Saint-Léonard'), (point(38.34075, 77.46915), 'Yigai''erqi'), (point(50.20069, 3.35232), 'Rieux-en-Cambrésis'), (point(45.66852, 0.00415), 'Hiersac'), (point(21.63333, 108.95), 'Xichang'), (point(41.61667, -3.81667), 'Haza'), (point(48.23782, 10.29951), 'Breitenthal'), (point(31.65439, 109.43082), 'Wulong'), (point(7.11219, -8.03611), 'Flandapleu'), (point(-36.72875, 144.30525), 'White Hills'), (point(48.77427, 8.72971), 'Bad Liebenzell'), (point(51.80167, -4.53139), 'Llanddowror'), (point(42.65058, 42.76959), 'Tsageri'), (point(51.37547, 7.70281), 'Iserlohn');


DELETE FROM test_spgist WHERE pt ~= ANY
('{"(47.22655, 0.77306)", "(43.65207, 3.55096)", "(40.95498, 0.27749)", "(47.61497, 7.66457)", "(32.01417, 120.2625)", "(51.65623, -3.60371)", "(49.85384, 5.45009)", "(41.61667, -3.81667)", "(45.77255, 4.80326)", "(43.09725, -2.37998)", "(40.16991, 49.46394)", "(50.23333, 6.28333)", "(48.58333, 8.68333)", "(50.38333, 7.73333)", "(55.10337, -3.58438)", "(43.03262, -2.40997)", "(7.13644, -7.94577)", "(50.93449, 4.13504)", "(19.66256, -71.19406)", "(53.78244, -2.87189)", "(47.14738, -1.06286)", "(49.31535, 2.31954)", "(42.76667, -7.56667)", "(50.74574, 3.6005)", "(47.86229, 9.37235)", "(48.38215, 7.70395)", "(-42.82895, 147.24735)", "(45.16839, 1.38342)", "(54.7, 9.51667)", "(28.46824, -16.25462)", "(4.94273, 15.87735)", "(43.31283, -1.97499)", "(49.47965, 9.64006)", "(-35.32624, 149.11906)", "(40.61832, 47.15014)", "(31.48319, 93.67741)", "(5.35977, -4.18641)", "(-1.17454, 13.87562)", "(40.98333, 24.8)", "(34.44542, 2.52749)", "(53.30182, -1.12404)", "(50.20366, 16.23762)", "(48.23782, 10.29951)", "(39.11667, -0.28333)", "(44.39982, 131.14775)", "(-33.02493, 137.52471)", "(41.41758, 2.15914)", "(29.12789, 108.47043)", "(33.73847, 113.30119)", "(41.9, 2.28333)", "(60.84614, 26.60755)", "(6.48511, -75.0196)", "(37.50914, 122.11356)", "(-26.68864, 153.00453)", "(49.91166, 8.20533)", "(47.87215, -3.54994)", "(6.80004, -1.08193)", "(45.66852, 0.00415)", "(34.56612, 103.58545)", "(52.03333, 8.53333)", "(52.66625, 8.2375)", "(48.47993, -4.33669)", "(47.57039, 7.66425)", "(52.08226, 0.43891)", "(47.41249, 0.98266)", "(-26.65682, 153.07955)", "(8.3372, -6.98278)", "(5.68822, -73.91784)", "(48.53333, -2.06667)", "(45.68563, 5.04484)", "(50.81987, 12.54493)", "(51.45561, 11.0071)", "(51.44491, -0.02043)", "(42.65058, 42.76959)", "(41.27194, 123.17306)", "(9.80955, -3.34577)", "(6.89358, -5.29709)", "(51.56917, 9.24113)", "(7.11219, -8.03611)", "(38.06667, 23.5)"}');

--
--
-- cannot actually test lsn because the value can vary, so check everything else
-- Page 0 is the root, the rest are leaf pages:
--
SELECT 0 pageNum, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 0)) UNION
SELECT 1, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 1)) UNION
SELECT 2, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 2)) UNION
SELECT 3, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 3)) UNION
SELECT 4, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 4)) UNION
SELECT 5, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 5)) UNION
SELECT 6, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 6)) UNION
SELECT 7, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 7)) UNION
SELECT 8, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 8)) UNION
SELECT 9, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 9)) UNION
SELECT 10, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 10)) UNION
SELECT 11, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 11)) UNION
SELECT 12, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 12)) UNION
SELECT 13, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 13)) UNION
SELECT 14, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 14)) UNION
SELECT 15, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 15)) UNION
SELECT 16, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 16)) UNION
SELECT 17, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 17)) UNION
SELECT 18, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 18))
ORDER BY pageNum;

--
--
-- There is no more pages:
--
SELECT 19, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 19));


--
--
--
--
--
--
--
--
--
-- Let us check what data do we have:
--
--
-- Page 1
--
WITH nodes as (
    SELECT
        tuple_offset tuple_offset,
        STRING_AGG('(BlockNum=' || node_block_num || ', Offset=' || node_offset || ', Label=' || node_label || ')', ', ') par
    FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx')
    GROUP BY tuple_offset
) SELECT
    tuples.tuple_offset AS offset,
    tuples.tuple_state AS state,
    tuples.all_the_same AS same,
    tuples.node_number,
    tuples.prefix_size,
    tuples.total_size,
    tuples.pref,
    nodes.par
FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx') AS tuples
JOIN nodes
ON tuples.tuple_offset = nodes.tuple_offset;

--
--  Page 2
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 2), 'test_spgist_idx');

--
-- Page 3
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 3), 'test_spgist_idx');

--
-- Page 4
--
WITH nodes as (
    SELECT
        tuple_offset tuple_offset,
        STRING_AGG('(BlockNum=' || node_block_num || ', Offset=' || node_offset || ', Label=' || node_label || ')', ', ') par
    FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx')
    GROUP BY tuple_offset
) SELECT
    tuples.tuple_offset AS offset,
    tuples.tuple_state AS state,
    tuples.all_the_same AS same,
    tuples.node_number,
    tuples.prefix_size,
    tuples.total_size,
    tuples.pref,
    nodes.par
FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx') AS tuples
JOIN nodes
ON tuples.tuple_offset = nodes.tuple_offset;

--
-- Page 5
--
WITH nodes as (
    SELECT
        tuple_offset tuple_offset,
        STRING_AGG('(BlockNum=' || node_block_num || ', Offset=' || node_offset || ', Label=' || node_label || ')', ', ') par
    FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx')
    GROUP BY tuple_offset
) SELECT
    tuples.tuple_offset AS offset,
    tuples.tuple_state AS state,
    tuples.all_the_same AS same,
    tuples.node_number,
    tuples.prefix_size,
    tuples.total_size,
    tuples.pref,
    nodes.par
FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx') AS tuples
JOIN nodes
ON tuples.tuple_offset = nodes.tuple_offset;

--
-- Page 6
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 6), 'test_spgist_idx');

--
-- Page 7
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 7), 'test_spgist_idx');

--
-- Page 8
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 8), 'test_spgist_idx');

--
-- Page 9
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 9), 'test_spgist_idx');

--
-- Page 10
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 10), 'test_spgist_idx');

--
-- Page 11
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 11), 'test_spgist_idx');

--
-- Page 12
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 12), 'test_spgist_idx');

--
-- Page 13
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 13), 'test_spgist_idx');

--
-- Page 14
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 14), 'test_spgist_idx');

--
-- Page 15
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 15), 'test_spgist_idx');

--
-- Page 16
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 16), 'test_spgist_idx');

--
-- Page 17
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 17), 'test_spgist_idx');

--
-- Page 18
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 18), 'test_spgist_idx');

--
-- Page 19
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 19), 'test_spgist_idx');

--
--
-- Drop a test table for quad tree
--
DROP TABLE test_spgist;

--
--    ___   ____   _  __
--   / _ ) / __ \ | |/_/
--  / _  |/ /_/ / >  <
-- /____/ \____/ /_/|_|
--

--
--
-- Create a test table for future kd-tree index
--
CREATE TABLE test_spgist (
    rect box,
    object_name varchar(256)
);

--
--
-- Create kd index to test
--
CREATE INDEX test_spgist_idx ON test_spgist USING spgist (rect);

--
--
-- Add data to test table
--

INSERT INTO test_spgist(rect, object_name) VALUES
('((20.15, 34.92), (26.6, 41.83))', 'Greece'), ('((13.54, 7.42), (23.89, 23.41))', 'Chad'), ('((-80.97, -4.96), (-75.23, 1.38))', 'Ecuador'), ('((-87.67, 10.73), (-83.15, 15.02))', 'Nicaragua'), ('((120.11, 21.97), (121.95, 25.3))', 'Taiwan'), ('((60.87, 23.69), (77.84, 37.13))', 'Pakistan'), ('((166.51, -46.64), (178.52, -34.45))', 'New Zealand'), ('((2.51, 49.53), (6.16, 51.48))', 'Belgium'), ('((100.12, 13.88), (107.56, 22.46))', 'Laos'), ('((2.69, 4.24), (14.58, 13.87))', 'Nigeria'), ('((30.18, -26.74), (40.78, -10.32))', 'Mozambique'), ('((-17.63, 12.33), (-11.47, 16.6))', 'Senegal'), ('((80.09, 26.4), (88.17, 30.42))', 'Nepal'), ('((124.27, 37.67), (130.78, 42.99))', 'North Korea'), ('((36.32, 12.46), (43.08, 18.0))', 'Eritrea'), ('((95.29, -10.36), (141.03, 5.48))', 'Indonesia'), ('((-117.13, 14.54), (-86.81, 32.72))', 'Mexico'), ('((41.66, 10.93), (43.32, 12.7))', 'Djibouti'), ('((113.34, -43.63), (153.57, -10.67))', 'Australia'), ('((25.26, -22.27), (32.85, -15.51))', 'Zimbabwe'), ('((9.32, 19.58), (25.16, 33.14))', 'Libya'), ('((-5.0, 42.5), (9.56, 51.15))', 'France'), ('((16.88, 47.76), (22.56, 49.57))', 'Slovakia'), ('((-180.0, -18.29), (180.0, -16.02))', 'Fiji'), ('((156.49, -10.83), (162.4, -6.6))', 'Solomon Islands'), ('((88.08, 20.67), (92.67, 26.45))', 'Bangladesh'), ('((60.53, 29.32), (75.16, 38.49))', 'Afghanistan'), ('((0.77, 6.14), (3.8, 12.24))', 'Benin'), ('((164.03, -22.4), (167.12, -20.11))', 'New Caledonia'), ('((43.58, 38.74), (46.51, 41.25))', 'Armenia'), ('((68.72, -49.78), (70.56, -48.63))', 'French Southern Territories'), ('((7.52, 30.31), (11.49, 37.35))', 'Tunisia'), ('((-8.6, 4.34), (-2.56, 10.52))', 'Ivory Coast'), ('((46.47, 40.66), (87.36, 55.39))', 'Kazakhstan'), ('((43.25, -25.6), (50.48, -12.04))', 'Madagascar'), ('((-89.23, 15.89), (-88.11, 18.5))', 'Belize'), ('((9.31, 1.01), (11.29, 2.28))', 'Equatorial Guinea'), ('((-62.69, -27.55), (-54.29, -19.34))', 'Paraguay'), ('((68.18, 7.97), (97.4, 35.49))', 'India'), ('((5.67, 49.44), (6.24, 50.13))', 'Luxembourg'), ('((69.46, 39.28), (80.26, 43.3))', 'Kyrgyzstan'), ('((-73.3, 0.72), (-59.76, 12.16))', 'Venezuela'), ('((-180.0, -90.0), (180.0, -63.27))', 'Antarctica');
DELETE FROM test_spgist WHERE rect ~= ANY
('{"(36.32, 12.46), (43.08, 18.0)"; "(124.27, 37.67), (130.78, 42.99)"; "(46.47, 40.66), (87.36, 55.39)"; "(0.77, 6.14), (3.8, 12.24)"; "(13.54, 7.42), (23.89, 23.41)"; "(16.88, 47.76), (22.56, 49.57)"; "(30.18, -26.74), (40.78, -10.32)"; "(113.34, -43.63), (153.57, -10.67)"; "(9.32, 19.58), (25.16, 33.14)"}');
INSERT INTO test_spgist(rect, object_name) VALUES
('((-78.99, -4.3), (-66.88, 12.44))', 'Colombia'), ('((34.63, 16.35), (55.67, 32.16))', 'Saudi Arabia'), ('((12.24, 48.56), (18.85, 51.12))', 'Czech Republic'), ('((30.68, -27.29), (32.07, -25.66))', 'Swaziland'), ('((8.8, -3.98), (14.43, 2.33))', 'Gabon'), ('((-84.97, 19.86), (-74.18, 23.19))', 'Cuba'), ('((51.58, 22.5), (56.4, 26.06))', 'United Arab Emirates'), ('((50.74, 24.56), (51.61, 26.11))', 'Qatar'), ('((55.93, 37.14), (73.06, 45.59))', 'Uzbekistan'), ('((-75.64, -55.61), (-66.96, -17.58))', 'Chile'), ('((52.5, 35.27), (66.55, 42.75))', 'Turkmenistan'), ('((-17.06, 14.62), (-4.92, 27.4))', 'Mauritania'), ('((-61.2, -52.3), (-57.75, -51.1))', 'Falkland Islands'), ('((18.83, 42.25), (22.99, 46.17))', 'Serbia'), ('((39.96, 41.06), (46.64, 43.55))', 'Georgia'), ('((19.3, 39.62), (21.02, 42.69))', 'Albania'), ('((26.04, 35.82), (44.79, 42.14))', 'Turkey'), ('((21.06, 53.91), (26.59, 56.37))', 'Lithuania'), ('((88.81, 26.72), (92.1, 28.3))', 'Bhutan'), ('((3.31, 50.8), (7.09, 53.51))', 'Netherlands'), ('((6.02, 45.78), (10.44, 47.83))', 'Switzerland'), ('((-67.24, 17.95), (-65.59, 18.52))', 'Puerto Rico'), ('((141.0, -10.65), (156.02, -2.5))', 'Papua New Guinea'), ('((29.34, -11.72), (40.32, -0.95))', 'Tanzania'), ('((-89.35, 12.98), (-83.15, 16.01))', 'Honduras'), ('((-58.04, 1.82), (-53.96, 6.03))', 'Suriname'), ('((-141.0, 41.68), (-52.65, 73.23))', 'Canada'), ('((22.38, 41.23), (28.56, 44.23))', 'Bulgaria'), ('((16.34, -34.82), (32.83, -22.09))', 'South Africa'), ('((35.7, 32.31), (42.35, 37.23))', 'Syria'), ('((32.69, -16.8), (35.77, -9.23))', 'Malawi'), ('((38.79, 29.1), (48.57, 37.39))', 'Iraq'), ('((-78.98, 23.71), (-77.0, 27.04))', 'Bahamas'), ('((34.27, 29.5), (35.84, 33.28))', 'Israel'), ('((87.75, 41.6), (119.77, 52.05))', 'Mongolia'), ('((11.09, -5.04), (18.45, 3.73))', 'Congo (Brazzaville)'), ('((20.46, 40.84), (22.95, 42.32))', 'Macedonia'), ('((11.03, 55.36), (23.9, 69.11))', 'Sweden'), ('((-69.59, -22.87), (-57.5, -9.76))', 'Bolivia'), ('((-13.25, 6.79), (-10.23, 10.05))', 'Sierra Leone'), ('((-73.42, -55.25), (-53.63, -21.83))', 'Argentina'), ('((13.7, 45.45), (16.56, 46.85))', 'Slovenia'), ('((-92.23, 13.74), (-88.23, 17.82))', 'Guatemala');
DELETE FROM test_spgist WHERE rect ~= ANY
('{"(52.5, 35.27), (66.55, 42.75)"; "(-75.64, -55.61), (-66.96, -17.58)"; "(38.79, 29.1), (48.57, 37.39)"; "(21.06, 53.91), (26.59, 56.37)"; "(18.83, 42.25), (22.99, 46.17)"; "(19.3, 39.62), (21.02, 42.69)"; "(-73.42, -55.25), (-53.63, -21.83)"; "(88.81, 26.72), (92.1, 28.3)"; "(8.8, -3.98), (14.43, 2.33)"}');
INSERT INTO test_spgist(rect, object_name) VALUES
('((14.07, 49.03), (24.03, 54.85))', 'Poland'), ('((-16.84, 13.13), (-13.84, 13.88))', 'Gambia'), ('((100.09, 0.77), (119.18, 6.93))', 'Malaysia'), ('((32.95, 3.42), (47.79, 14.96))', 'Ethiopia'), ('((34.92, 29.2), (39.2, 33.38))', 'Jordan'), ('((-0.05, 5.93), (1.87, 11.02))', 'Togo'), ('((8.09, 54.8), (12.69, 57.73))', 'Denmark'), ('((-5.47, 9.61), (2.18, 15.12))', 'Burkina Faso'), ('((15.75, 42.65), (19.6, 45.23))', 'Bosnia and Herzegovina'), ('((14.46, 2.27), (27.37, 11.14))', 'Central African Republic'), ('((42.6, 12.59), (53.11, 19.0))', 'Yemen'), ('((29.58, -1.44), (35.04, 4.25))', 'Uganda'), ('((11.64, -17.93), (24.08, -4.44))', 'Angola'), ('((18.45, 41.88), (20.34, 43.52))', 'Montenegro'), ('((32.26, 34.57), (34.0, 35.17))', 'Cyprus'), ('((124.97, -9.39), (127.34, -8.27))', 'East Timor'), ('((-73.99, -33.77), (-34.73, 5.24))', 'Brazil'), ('((40.98, -1.68), (51.13, 12.02))', 'Somalia'), ('((126.12, 34.39), (129.47, 38.61))', 'South Korea'), ('((26.62, 45.49), (30.02, 48.47))', 'Moldova'), ('((-180.0, 41.15), (180.0, 81.25))', 'Russia'), ('((-61.95, 10.0), (-60.9, 10.89))', 'Trinidad and Tobago'), ('((-12.17, 10.1), (4.27, 24.97))', 'Mali'), ('((0.3, 11.66), (15.9, 23.47))', 'Niger'), ('((-74.46, 18.03), (-71.62, 19.92))', 'Haiti'), ('((-78.34, 17.7), (-76.2, 18.52))', 'Jamaica'), ('((-16.68, 11.04), (-13.7, 12.63))', 'Guinea Bissau'), ('((-11.44, 4.36), (-7.54, 8.54))', 'Liberia'), ('((-58.43, -34.95), (-53.21, -30.11))', 'Uruguay'), ('((97.38, 5.69), (105.59, 20.42))', 'Thailand'), ('((33.89, -4.68), (41.86, 5.51))', 'Kenya'), ('((20.65, 59.85), (31.52, 70.16))', 'Finland'), ('((-81.41, -18.35), (-68.67, -0.06))', 'Peru'), ('((4.99, 58.08), (31.29, 70.92))', 'Norway'), ('((20.22, 43.69), (29.63, 48.22))', 'Romania'), ('((-9.98, 51.67), (-6.03, 55.13))', 'Ireland'), ('((22.09, 44.36), (40.08, 52.34))', 'Ukraine'), ('((13.66, 42.48), (19.39, 46.5))', 'Croatia'), ('((21.89, -17.96), (33.49, -8.24))', 'Zambia'), ('((23.2, 51.32), (32.69, 56.17))', 'Belarus'), ('((-3.24, 4.71), (1.06, 11.1))', 'Ghana'), ('((67.44, 36.74), (74.98, 40.96))', 'Tajikistan'), ('((-90.1, 13.15), (-87.72, 14.42))', 'El Salvador');
DELETE FROM test_spgist WHERE rect ~= ANY
('{"(22.09, 44.36), (40.08, 52.34)"; "(97.38, 5.69), (105.59, 20.42)"; "(18.45, 41.88), (20.34, 43.52)"; "(20.65, 59.85), (31.52, 70.16)"; "(34.92, 29.2), (39.2, 33.38)"; "(14.07, 49.03), (24.03, 54.85)"; "(-0.05, 5.93), (1.87, 11.02)"; "(-11.44, 4.36), (-7.54, 8.54)"; "(-61.95, 10.0), (-60.9, 10.89)"}');
INSERT INTO test_spgist(rect, object_name) VALUES
('((-82.97, 7.22), (-77.24, 9.61))', 'Panama'), ('((8.49, 1.73), (16.01, 12.86))', 'Cameroon'), ('((102.17, 8.6), (109.34, 23.35))', 'Vietnam'), ('((117.17, 5.58), (126.54, 18.51))', 'Philippines'), ('((-8.68, 19.06), (12.0, 37.12))', 'Algeria'), ('((-24.33, 63.5), (-13.61, 66.53))', 'Iceland'), ('((24.7, 22.0), (36.87, 31.59))', 'Egypt'), ('((29.02, -2.92), (30.82, -1.13))', 'Rwanda'), ('((-73.3, 60.04), (-12.21, 83.65))', 'Greenland'), ('((5.99, 47.3), (15.02, 54.98))', 'Germany'), ('((34.93, 31.35), (35.55, 32.53))', 'West Bank'), ('((29.02, -4.5), (30.75, -2.35))', 'Burundi'), ('((9.48, 46.43), (16.98, 49.04))', 'Austria'), ('((-7.57, 49.96), (1.68, 58.64))', 'United Kingdom'), ('((129.41, 31.03), (145.54, 45.55))', 'Japan'), ('((-125.0, 25.0), (-66.96, 49.5))', 'United States'), ('((-9.53, 36.84), (-6.39, 42.28))', 'Portugal'), ('((73.68, 18.2), (135.03, 53.46))', 'China'), ('((11.73, -29.05), (25.08, -16.94))', 'Namibia'), ('((-17.02, 21.42), (-1.12, 35.76))', 'Morocco'), ('((35.13, 33.09), (36.61, 34.64))', 'Lebanon'), ('((102.35, 10.49), (107.61, 14.57))', 'Cambodia'), ('((44.79, 38.27), (50.39, 41.86))', 'Azerbaijan'), ('((-71.95, 17.6), (-68.32, 19.88))', 'Dominican Republic'), ('((-15.13, 7.31), (-7.83, 12.59))', 'Guinea'), ('((23.34, 57.47), (28.13, 59.61))', 'Estonia'), ('((21.94, 8.62), (38.41, 22.0))', 'Sudan'), ('((6.75, 36.62), (18.48, 47.12))', 'Italy'), ('((114.2, 4.01), (115.45, 5.45))', 'Brunei'), ('((-61.41, 1.27), (-56.54, 8.37))', 'Guyana'), ('((46.57, 28.53), (48.42, 30.06))', 'Kuwait'), ('((44.11, 25.08), (63.32, 39.71))', 'Iran'), ('((-85.94, 8.23), (-82.55, 11.22))', 'Costa Rica'), ('((79.7, 5.97), (81.79, 9.82))', 'Sri Lanka'), ('((12.18, -13.26), (31.17, 5.26))', 'Congo (Kinshasa)'), ('((92.3, 9.93), (101.18, 28.34))', 'Myanmar'), ('((52.0, 16.65), (59.81, 26.4))', 'Oman'), ('((16.2, 45.76), (22.71, 48.62))', 'Hungary'), ('((166.63, -16.6), (167.84, -14.63))', 'Vanuatu'), ('((23.89, 3.51), (35.3, 12.25))', 'South Sudan'), ('((-9.39, 35.95), (3.04, 43.75))', 'Spain'), ('((21.06, 55.62), (28.18, 57.97))', 'Latvia'), ('((27.0, -30.65), (29.33, -28.65))', 'Lesotho'), ('((19.9, -26.83), (29.43, -17.66))', 'Botswana');
DELETE FROM test_spgist WHERE rect ~= ANY
('{"(-17.02, 21.42), (-1.12, 35.76)"; "(92.3, 9.93), (101.18, 28.34)"; "(-9.53, 36.84), (-6.39, 42.28)"; "(-125.0, 25.0), (-66.96, 49.5)"; "(21.06, 55.62), (28.18, 57.97)"; "(8.49, 1.73), (16.01, 12.86)"; "(79.7, 5.97), (81.79, 9.82)"; "(44.79, 38.27), (50.39, 41.86)"; "(46.57, 28.53), (48.42, 30.06)"}');

--
--
-- cannot actually test lsn because the value can vary, so check everything else
-- Page 0 is the root, the rest are leaf pages:
--
SELECT 0 pageNum, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 0)) UNION
SELECT 1, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 1)) UNION
SELECT 2, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 2)) UNION
SELECT 3, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 3)) UNION
SELECT 4, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 4))
ORDER BY pageNum;

--
--
-- There is no more pages:
--
SELECT 5, nDirection, nPlaceholder, flags FROM spgist_page_opaque_info(get_raw_page('test_spgist_idx', 5));

--
--
--
--
--
--
--
--
--
-- Let us check what data do we have:
--
--
-- Page 1
--
WITH nodes as (
    SELECT
        tuple_offset tuple_offset,
        STRING_AGG('(BlockNum=' || node_block_num || ', Offset=' || node_offset || ', Label=' || node_label || ')', ', ') par
    FROM spgist_inner_tuples_nodes(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx')
    GROUP BY tuple_offset
) SELECT
    tuples.tuple_offset AS offset,
    tuples.tuple_state AS state,
    tuples.all_the_same AS same,
    tuples.node_number,
    tuples.prefix_size,
    tuples.total_size,
    tuples.pref,
    nodes.par
FROM spgist_inner_tuples(get_raw_page('test_spgist_idx', 1), 'test_spgist_idx') AS tuples
JOIN nodes
ON tuples.tuple_offset = nodes.tuple_offset;

--
--  Page 2
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 2), 'test_spgist_idx');

--
-- Page 3
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 3), 'test_spgist_idx');

--
-- Page 4
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 4), 'test_spgist_idx');

--
-- Page 5
--
SELECT * FROM spgist_leaf_tuples(get_raw_page('test_spgist_idx', 5), 'test_spgist_idx');

--
--
-- Drop a test table for quad tree
--
DROP TABLE test_spgist;