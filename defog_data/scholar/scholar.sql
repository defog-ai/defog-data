
CREATE TABLE public.author (
    authorid bigint NOT NULL,
    authorname text
);


CREATE TABLE public.cite (
    citingpaperid bigint NOT NULL,
    citedpaperid bigint NOT NULL
);


CREATE TABLE public.dataset (
    datasetid bigint NOT NULL,
    datasetname text
);


CREATE TABLE public.field (
    fieldid bigint
);


CREATE TABLE public.journal (
    journalid bigint NOT NULL,
    journalname text
);


CREATE TABLE public.keyphrase (
    keyphraseid bigint NOT NULL,
    keyphrasename text
);


CREATE TABLE public.paper (
    paperid bigint NOT NULL,
    title text,
    venueid bigint,
    year bigint,
    numciting bigint,
    numcitedby bigint,
    journalid bigint
);


CREATE TABLE public.paperdataset (
    paperid bigint,
    datasetid bigint
);


CREATE TABLE public.paperfield (
    fieldid bigint,
    paperid bigint
);


CREATE TABLE public.paperkeyphrase (
    paperid bigint,
    keyphraseid bigint
);


CREATE TABLE public.venue (
    venueid bigint NOT NULL,
    venuename text
);


CREATE TABLE public.writes (
    paperid bigint,
    authorid bigint
);


INSERT INTO public.author (authorid, authorname) VALUES
(1, 'John Smith'),
(2, 'Emily Johnson'),
(3, 'Michael Brown'),
(4, 'Sarah Davis'),
(5, 'David Wilson'),
(6, 'Jennifer Lee'),
(7, 'Robert Moore'),
(8, 'Linda Taylor'),
(9, 'William Anderson'),
(10, 'Karen Martinez')
;

INSERT INTO public.cite (citingpaperid, citedpaperid) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 5),
(5, 1),
(3, 5),
(4, 2),
(1, 4),
(3, 1)
;

INSERT INTO public.dataset (datasetid, datasetname) VALUES
(1, 'COVID-19 Research'),
(2, 'Machine Learning Datasets'),
(3, 'Climate Change Data'),
(4, 'Social Media Analysis')
;

INSERT INTO public.field (fieldid) VALUES
(1),
(2),
(3),
(4)
;

INSERT INTO public.journal (journalid, journalname) VALUES
(1, 'Nature'),
(2, 'Science'),
(3, 'IEEE Transactions on Pattern Analysis and Machine Intelligence'),
(4, 'International Journal of Mental Health')
;

INSERT INTO public.keyphrase (keyphraseid, keyphrasename) VALUES
(1, 'Machine Learning'),
(2, 'Climate Change'),
(3, 'Social Media'),
(4, 'COVID-19'),
(5, 'Mental Health')
;

INSERT INTO public.paper (paperid, title, venueid, year, numciting, numcitedby, journalid) VALUES
(1, 'A Study on Machine Learning Algorithms', 1, 2020, 2, 2, 3),
(2, 'The Effects of Climate Change on Agriculture', 1, 2020, 1, 2, 1),
(3, 'Social Media and Mental Health', 2, 2019, 3, 1, 4),
(4, 'COVID-19 Impact on Society', 1, 2020, 2, 2, 2),
(5, 'Machine Learning in Tackling Climate Change', 2, 2019, 1, 2, 3)
;

INSERT INTO public.paperdataset (paperid, datasetid) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1),
(5, 2),
(5, 3)
;

INSERT INTO public.paperfield (fieldid, paperid) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(1, 5)
;

INSERT INTO public.paperkeyphrase (paperid, keyphraseid) VALUES
(1, 1),
(2, 2),
(3, 3),
(3, 5),
(4, 4),
(5, 1),
(5, 2)
;

INSERT INTO public.venue (venueid, venuename) VALUES
(1, 'Conference on Machine Learning'),
(2, 'International Journal of Climate Change'),
(3, 'Social Media Analysis Workshop')
;

INSERT INTO public.writes (paperid, authorid) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(1, 3),
(1, 4),
(2, 3),
(4, 5),
(5, 1),
(2, 1),
(4, 3),
(4, 6),
(2, 7),
(2, 8),
(2, 9)
;



