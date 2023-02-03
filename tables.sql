/* 
TODO:   add constraints
*/

CREATE TABLE Students(
    idnr        CHAR(10) NOT NULL PRIMARY KEY,
    CHECK (idnr LIKE '__________'),
    name        TEXT NOT NULL,
    login       TEXT NOT NULL UNIQUE,
    program     TEXT NOT NULL
);

CREATE TABLE Branches(
    name        TEXT,
    program     TEXT,
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses(
    code        CHAR(6) PRIMARY KEY,
    name        CHAR(2),
    credits     FLOAT,
    department  TEXT NOT NULL,
    CONSTRAINT positive_credit        CHECK(credits>0),
    CONSTRAINT valid_code_name_format CHECK(code LIKE 'CCC%'),
    CONSTRAINT valid_name_format      CHECK(name LIKE 'C_')
);

CREATE TABLE LimitedCourses(
    code        TEXT PRIMARY KEY,
    capacity    INT,
    CONSTRAINT positive_capacity CHECK(capacity>0),
    FOREIGN KEY (code) REFERENCES Courses
);

CREATE TABLE StudentBranches(
    student     TEXT PRIMARY KEY,
    branch      TEXT,
    program     TEXT,
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (branch, program) REFERENCES Branches
);

CREATE TABLE Classifications(
    name        TEXT PRIMARY KEY
);

CREATE TABLE Classified(
    course       TEXT,
    classifications TEXT,
    PRIMARY KEY (course, classifications),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (classifications) REFERENCES Classifications
);

CREATE TABLE MandatoryProgram(
    course      TEXT,
    program     TEXT,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE MandatoryBranch(
    course      TEXT,
    branch      TEXT,
    program     TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches
);

CREATE TABLE RecommendedBranch(
    course      TEXT,
    branch      TEXT,
    program     TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches
);

CREATE TABLE Registered(
    student     TEXT,
    course      TEXT,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course)  REFERENCES Courses
);

CREATE TABLE Taken(
    student     TEXT,
    course      TEXT,
    grade       CHAR,
    CONSTRAINT valid_grade CHECK(grade IN ('U','3','4','5')),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course)  REFERENCES Courses
);

CREATE TABLE WaitingList(
    student     TEXT,
    course      TEXT,
    position    SERIAL,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course)  REFERENCES LimitedCourses
);