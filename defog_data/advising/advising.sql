CREATE TABLE public.area (
    course_id bigint,
    area text
);


CREATE TABLE public.comment_instructor (
    instructor_id bigint DEFAULT '0'::bigint NOT NULL,
    student_id bigint DEFAULT '0'::bigint NOT NULL,
    score bigint,
    comment_text text
);


CREATE TABLE public.course (
    course_id bigint DEFAULT '0'::bigint NOT NULL,
    name text,
    department text,
    number text,
    credits text,
    advisory_requirement text,
    enforced_requirement text,
    description text,
    num_semesters bigint,
    num_enrolled bigint,
    has_discussion boolean,
    has_lab boolean,
    has_projects boolean,
    has_exams boolean,
    num_reviews bigint,
    clarity_score bigint,
    easiness_score bigint,
    helpfulness_score bigint
);


CREATE TABLE public.course_offering (
    offering_id bigint DEFAULT '0'::bigint NOT NULL,
    course_id bigint,
    semester bigint,
    section_number bigint,
    start_time time,
    end_time time,
    monday text,
    tuesday text,
    wednesday text,
    thursday text,
    friday text,
    saturday text,
    sunday text,
    has_final_project boolean,
    has_final_exam boolean,
    textbook text,
    class_address text,
    allow_audit text DEFAULT 'false'::text
);


CREATE TABLE public.course_prerequisite (
    pre_course_id bigint NOT NULL,
    course_id bigint NOT NULL
);


CREATE TABLE public.course_tags_count (
    course_id bigint DEFAULT '0'::bigint NOT NULL,
    clear_grading bigint DEFAULT '0'::bigint,
    pop_quiz bigint DEFAULT '0'::bigint,
    group_projects bigint DEFAULT '0'::bigint,
    inspirational bigint DEFAULT '0'::bigint,
    long_lectures bigint DEFAULT '0'::bigint,
    extra_credit bigint DEFAULT '0'::bigint,
    few_tests bigint DEFAULT '0'::bigint,
    good_feedback bigint DEFAULT '0'::bigint,
    tough_tests bigint DEFAULT '0'::bigint,
    heavy_papers bigint DEFAULT '0'::bigint,
    cares_for_students bigint DEFAULT '0'::bigint,
    heavy_assignments bigint DEFAULT '0'::bigint,
    respected bigint DEFAULT '0'::bigint,
    participation bigint DEFAULT '0'::bigint,
    heavy_reading bigint DEFAULT '0'::bigint,
    tough_grader bigint DEFAULT '0'::bigint,
    hilarious bigint DEFAULT '0'::bigint,
    would_take_again bigint DEFAULT '0'::bigint,
    good_lecture bigint DEFAULT '0'::bigint,
    no_skip bigint DEFAULT '0'::bigint
);


CREATE TABLE public.instructor (
    instructor_id bigint DEFAULT '0'::bigint NOT NULL,
    name text,
    uniqname text
);


CREATE TABLE public.offering_instructor (
    offering_instructor_id bigint DEFAULT '0'::bigint NOT NULL,
    offering_id bigint,
    instructor_id bigint
);


CREATE TABLE public.program (
    program_id bigint NOT NULL,
    name text,
    college text,
    introduction text
);


CREATE TABLE public.program_course (
    program_id bigint DEFAULT '0'::bigint NOT NULL,
    course_id bigint DEFAULT '0'::bigint NOT NULL,
    workload bigint,
    category text DEFAULT ''::text NOT NULL
);


CREATE TABLE public.program_requirement (
    program_id bigint NOT NULL,
    category text NOT NULL,
    min_credit bigint,
    additional_req text
);


CREATE TABLE public.semester (
    semester_id bigint NOT NULL,
    semester text,
    year bigint
);


CREATE TABLE public.student (
    student_id bigint NOT NULL,
    lastname text,
    firstname text,
    program_id bigint,
    declare_major text,
    total_credit bigint,
    total_gpa numeric,
    entered_as text DEFAULT 'firstyear'::text,
    admit_term date,
    predicted_graduation_semester date,
    degree text,
    minor text,
    internship text
);


CREATE TABLE public.student_record (
    student_id bigint NOT NULL,
    course_id bigint NOT NULL,
    semester bigint NOT NULL,
    grade text,
    how text,
    transfer_source text,
    earn_credit text DEFAULT 'y'::text NOT NULL,
    repeat_term text,
    test_id text,
    offering_id bigint
);


INSERT INTO public.area (course_id, area) VALUES
(1, 'Computer Science'),
(2, 'Mathematics'),
(3, 'Physics'),
(4, 'Computer Science')
;

INSERT INTO public.comment_instructor (instructor_id, student_id, score, comment_text) VALUES
(1, 1, 5, 'John Smith is a great instructor.'),
(2, 2, 4, 'Jane Doe explains concepts clearly.')
;

INSERT INTO public.course (course_id, name, department, number, credits, advisory_requirement, enforced_requirement, description, num_semesters, num_enrolled, has_discussion, has_lab, has_projects, has_exams, num_reviews, clarity_score, easiness_score, helpfulness_score) VALUES
(1, 'Introduction to Computer Science', 'Computer Science', 'CS101', '3', NULL, NULL, 'This course introduces the basics of computer science.', 2, 2, true, false, true, false, 10, 5, 3, 4),
(2, 'Advanced Calculus', 'Mathematics', 'MATH201', '4', 'CS101', NULL, 'This course covers advanced topics in calculus.', 1, 3, false, false, true, true, 5, 4, 2, 3),
(3, 'Introduction to Physics', 'Physics', 'PHYS101', '3', NULL, 'MATH201', 'This course provides an introduction to physics principles.', 2, 1, true, true, true, true, 8, 4, 3, 5),
(4, 'Distributed Databases', 'Computer Science', 'CS302', '3', NULL, 'CS101', 'This course provides an introduction to distributed databases.', 2, 2, true, true, false, true, 4, 2, 1, 5)
;

INSERT INTO public.course_offering (offering_id, course_id, semester, section_number, start_time, end_time, monday, tuesday, wednesday, thursday, friday, saturday, sunday, has_final_project, has_final_exam, textbook, class_address, allow_audit) VALUES
(1, 1, 1, 1, '08:00:00', '10:00:00', 'John Smith', NULL, NULL, 'Jane Doe', NULL, NULL, NULL, true, false, 'Introduction to Computer Science', '123 Main St', 'true'),
(2, 2, 1, 1, '10:00:00', '12:00:00', NULL, NULL, 'Gilbert Strang', NULL, NULL, NULL, NULL, true, true, 'Advanced Calculus', '456 Elm St', 'false'),
(3, 3, 2, 1, '08:00:00', '10:00:00', 'John Smith', NULL, NULL, 'Jane Doe', NULL, NULL, NULL, false, true, 'Introduction to Physics', '789 Oak St', 'true'),
(4, 4, 2, 1, '16:00:00', '18:00:00', NULL, NULL, 'John Smith', 'Brendan Burns', NULL, NULL, NULL, false, true, 'Distributed Systems', '789 Oak St', 'true'),
(5, 1, 3, 1, '08:00:00', '10:00:00', NULL, 'John Smith', 'Jane Doe', NULL, NULL, NULL, NULL, true, false, 'Introduction to Computer Science', '123 Main St', 'true'),
(6, 2, 3, 1, '10:00:00', '12:00:00', 'Gilbert Strang', NULL, NULL, NULL, NULL, NULL, NULL, true, true, 'Advanced Calculus', '456 Elm St', 'false'),
(7, 3, 4, 1, '14:00:00', '16:00:00', NULL, NULL, 'Jane Doe', NULL, 'John Smith', NULL, NULL, false, true, 'Introduction to Physics', '789 Oak St', 'true'),
(8, 4, 4, 1, '16:00:00', '18:00:00', NULL, NULL, 'John Smith', NULL, 'Brendan Burns', NULL, NULL, false, true, 'Distributed Systems', '789 Oak St', 'true')
;

INSERT INTO public.course_prerequisite (pre_course_id, course_id) VALUES
(1, 2),
(2, 3)
;

INSERT INTO public.course_tags_count (course_id, clear_grading, pop_quiz, group_projects, inspirational, long_lectures, extra_credit, few_tests, good_feedback, tough_tests, heavy_papers, cares_for_students, heavy_assignments, respected, participation, heavy_reading, tough_grader, hilarious, would_take_again, good_lecture, no_skip) VALUES
(1, 5, 2, 3, 4, 2, 1, 3, 4, 2, 1, 5, 3, 4, 2, 1, 5, 3, 4, 2, NULL),
(2, 4, 1, 2, 3, 1, 2, 2, 3, 1, 2, 4, 2, 3, 1, 2, 4, 2, 3, 1, NULL),
(3, 3, 2, 1, 2, 3, 1, 1, 2, 3, 1, 3, 1, 2, 3, 1, 3, 1, 2, 3, NULL),
(4, 2, 3, 0, 2, 3, 1, 1, 2, 3, 0, 3, 4, 2, 3, 5, 3, 1, 2, 3, NULL)
;


INSERT INTO public.instructor (instructor_id, name, uniqname) VALUES
(1, 'John Smith', 'jsmith'),
(2, 'Jane Doe', 'jdoe'),
(3, 'Gilbert Strang', 'gstrang'),
(4, 'Brendan Burns', 'bburns')
;

INSERT INTO public.offering_instructor (offering_instructor_id, offering_id, instructor_id) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 2, 3),
(4, 3, 1),
(5, 3, 2),
(6, 4, 1),
(7, 4, 4),
(8, 5, 1),
(9, 5, 2),
(10, 6, 3),
(11, 7, 2),
(12, 7, 1),
(13, 8, 1),
(14, 8, 4)
;

INSERT INTO public.program (program_id, name, college, introduction) VALUES
(1, 'Computer Science', 'Engineering', 'This program focuses on computer science principles and applications.'),
(2, 'Mathematics', 'Arts and Sciences', 'This program provides a comprehensive study of mathematical concepts and theories.'),
(3, 'Physics', 'Arts and Sciences', 'This program explores the fundamental principles of physics and their applications.')
;

INSERT INTO public.program_course (program_id, course_id, workload, category) VALUES
(1, 1, 100, 'Core'),
(1, 4, 80, 'Elective'),
(2, 2, 90, 'Core'),
(3, 3, 70, 'Core')
;

INSERT INTO public.program_requirement (program_id, category, min_credit, additional_req) VALUES
(1, 'Core', 120, NULL),
(2, 'Core', 90, NULL),
(3, 'Core', 200, NULL)
;

INSERT INTO public.semester (semester_id, semester, year) VALUES
(1, 'Fall', 2020),
(2, 'Spring', 2021),
(3, 'Summer', 2021),
(4, 'Fall', 2021)
;

INSERT INTO public.student (student_id, lastname, firstname, program_id, declare_major, total_credit, total_gpa, entered_as, admit_term, predicted_graduation_semester, degree, minor, internship) VALUES
(1, 'Smith', 'John', 1, 'Computer Science', 13, 3.5, 'Freshman','2018-01-01', '2022-05-01', 'Bachelor of Science', NULL, NULL),
(2, 'Doe', 'Jane', 1, 'Computer Science', 7, 3.2, 'Freshman', '2018-01-01', '2022-05-01', 'Bachelor of Science', NULL, NULL),
(3, 'Johnson', 'David', 2, 'Mathematics', 7, 3.6, 'Freshman', '2019-01-01', '2022-05-01', 'Bachelor of Arts', 'Mathematics', NULL)
;

INSERT INTO public.student_record (student_id, course_id, semester, grade, how, transfer_source, earn_credit, repeat_term, test_id, offering_id) VALUES
(1, 1, 1, 'A', 'in-person', NULL, 'Yes', NULL, '1', 1),
(1, 2, 1, 'A', 'in-person', NULL, 'Yes', NULL, '1', 2),
(1, 3, 2, 'A', 'in-person', NULL, 'Yes', NULL, '1', 3),
(1, 4, 2, 'A', 'in-person', NULL, 'Yes', NULL, '1', 4),
(2, 2, 1, 'C', 'in-person', NULL, 'Yes', NULL, '1', 2),
(2, 1, 1, 'B', 'online', NULL, 'Yes', NULL, '1', 1),
(3, 2, 1, 'B+', 'in-person', NULL, 'Yes', NULL, '1', 2),
(3, 4, 2, 'B+', 'in-person', NULL, 'Yes', NULL, '1', 4)
;
