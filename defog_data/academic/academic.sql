
CREATE TABLE public.author (
    aid bigint NOT NULL,
    homepage text,
    name text,
    oid bigint
);


CREATE TABLE public.cite (
    cited bigint,
    citing bigint
);


CREATE TABLE public.conference (
    cid bigint NOT NULL,
    homepage text,
    name text
);


CREATE TABLE public.domain (
    did bigint NOT NULL,
    name text
);



CREATE TABLE public.domain_author (
    aid bigint NOT NULL,
    did bigint NOT NULL
);


CREATE TABLE public.domain_conference (
    cid bigint NOT NULL,
    did bigint NOT NULL
);


CREATE TABLE public.domain_journal (
    did bigint NOT NULL,
    jid bigint NOT NULL
);


CREATE TABLE public.domain_keyword (
    did bigint NOT NULL,
    kid bigint NOT NULL
);


CREATE TABLE public.domain_publication (
    did bigint NOT NULL,
    pid bigint NOT NULL
);



CREATE TABLE public.journal (
    homepage text,
    jid bigint NOT NULL,
    name text
);


CREATE TABLE public.keyword (
    keyword text,
    kid bigint NOT NULL
);


CREATE TABLE public.organization (
    continent text,
    homepage text,
    name text,
    oid bigint NOT NULL
);


CREATE TABLE public.publication (
    abstract text,
    cid bigint,
    citation_num bigint,
    jid bigint,
    pid bigint NOT NULL,
    reference_num bigint,
    title text,
    year bigint
);


CREATE TABLE public.publication_keyword (
    pid bigint NOT NULL,
    kid bigint NOT NULL
);



CREATE TABLE public.writes (
    aid bigint NOT NULL,
    pid bigint NOT NULL
);


INSERT INTO public.author (aid, homepage, name, oid) VALUES
(1, 'www.larry.com', 'Larry Summers', 2),
(2, 'www.ashish.com', 'Ashish Vaswani', 3),
(3, 'www.noam.com', 'Noam Shazeer', 3),
(4, 'www.martin.com', 'Martin Odersky', 4),
(5, NULL, 'Kempinski', NULL)
;


INSERT INTO public.cite (cited, citing) VALUES
(1, 2),
(1, 3),
(1, 4),
(1, 5),
(2, 3),
(2, 5),
(3, 4),
(3, 5),
(4, 5)
;


INSERT INTO public.conference (cid, homepage, name) VALUES
(1, 'www.isa.com', 'ISA'),
(2, 'www.aaas.com', 'AAAS'),
(3, 'www.icml.com', 'ICML')
;


INSERT INTO public.domain (did, name) VALUES
(1, 'Data Science'),
(2, 'Natural Sciences'),
(3, 'Computer Science'),
(4, 'Sociology'),
(5, 'Machine Learning')
;


INSERT INTO public.domain_author (aid, did) VALUES
(1, 2),
(1, 4),
(2, 3),
(2, 1),
(2, 5),
(3, 5),
(3, 3),
(4, 3)
;


INSERT INTO public.domain_conference (cid, did) VALUES
(1, 2),
(2, 4),
(3, 5)
;


INSERT INTO public.domain_journal (did, jid) VALUES
(1, 2),
(2, 3),
(5, 4)
;


INSERT INTO public.domain_keyword (did, kid) VALUES
(1, 2),
(2, 3)
;


INSERT INTO public.domain_publication (did, pid) VALUES
(4, 1),
(2, 2),
(1, 3),
(3, 4),
(3, 5),
(5, 5)
;


INSERT INTO public.journal (homepage, jid, name) VALUES
('www.aijournal.com', 1, 'Journal of Artificial Intelligence Research'),
('www.nature.com', 2, 'Nature'),
('www.science.com', 3, 'Science'),
('www.ml.com', 4, 'Journal of Machine Learning Research')
;


INSERT INTO public.keyword (keyword, kid) VALUES
('AI', 1),
('Neuroscience', 2),
('Machine Learning', 3),
('Keyword 4', 4)
;


INSERT INTO public.organization (continent, homepage, name, oid) VALUES
('Asia', 'www.organization1.com', 'Organization 1', 1),
('North America', 'www.organization2.com', 'Organization 2', 2),
('North America', 'www.organization3.com', 'Organization 3', 3),
('Europe', 'www.epfl.com', 'École Polytechnique Fédérale de Lausanne 4', 4),
('Europe', 'www.organization5.com', 'Organization 5', 5)
;


INSERT INTO public.publication (abstract, cid, citation_num, jid, pid, reference_num, title, year) VALUES
('Abstract 1', 1, 4, 1, 1, 0, 'The Effects of Climate Change on Agriculture', 2020),
('Abstract 2', 2, 2, 2, 2, 1, 'A Study on the Effects of Social Media on Mental Health', 2020),
('Abstract 3', 3, 2, 2, 3, 2, 'Data Mining Techniques', 2021),
('Abstract 4', 3, 1, 2, 4, 2, 'Optimizing GPU Throughput', 2021),
('Abstract 5', 3, 0, 4, 5, 4, 'Attention is all you need', 2021)
;


INSERT INTO public.publication_keyword (pid, kid) VALUES
(1, 2),
(2, 3)
;


INSERT INTO public.writes (aid, pid) VALUES
(1, 1),
(1, 2),
(2, 3),
(2, 4),
(2, 5),
(3, 5)
;
