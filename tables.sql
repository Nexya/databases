/* 
TODO:   add foreign keys for references and other tables
        add constraints
*/

CREATE TABLE Students(
    idnr        TEXT PRIMARY KEY,
    name        TEXT,
    login       TEXT UNIQUE,
    program     TEXT
);

CREATE TABLE Branches(
    name        TEXT,
    program     TEXT,
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses(
    code        TEXT PRIMARY KEY,
    name        TEXT,
    credits     INT,
    department  TEXT
);

CREATE TABLE LimitedCourses(
    code        TEXT PRIMARY KEY,
    capacity    INT
);

CREATE TABLE StudentBranches(
    student     TEXT PRIMARY KEY,
    branch      TEXT,
    program     TEXT
);

CREATE TABLE Classifications(
    name        TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course       TEXT,
    classifications TEXT
);

CREATE TABLE MandatoryProgram(
    course      TEXT,
    program     TEXT
);

CREATE TABLE MandatoryBranch(
    course      TEXT,
    branch      TEXT,
    program     TEXT
);

CREATE TABLE RecommendedBranch(
    course      TEXT,
    branch      TEXT,
    program     TEXT
);

CREATE TABLE Registered(
    student     TEXT,
    course      TEXT
);

CREATE TABLE Taken(
    student     TEXT,
    course      TEXT,
    grade       TEXT
);

CREATE TABLE WaitingList(
    student     TEXT,
    course      TEXT,
    position    TEXT
);