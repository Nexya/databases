CREATE TABLE Departments(
    name        TEXT PRIMARY KEY,
    abbr        TEXT UNIQUE NOT NULL
);

CREATE TABLE Programs(
    name        TEXT PRIMARY KEY,
    abbr        TEXT UNIQUE NOT NULL
);

CREATE TABLE Branches(
    name        TEXT,
    program     TEXT,
    PRIMARY KEY (name, program),
    FOREIGN KEY (program) REFERENCES Programs
);

CREATE TABLE Course(
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    credits     FLOAT NOT NULL,
    department  TEXT NOT NULL,
    CONSTRAINT positive_credit        CHECK(credits>0),
    CONSTRAINT valid_code_name_format CHECK(code LIKE '______'),
    FOREIGN KEY (department) REFERENCES Departments
);

CREATE TABLE Students(
    idnr        CHAR(10) NOT NULL PRIMARY KEY,
    CHECK (idnr LIKE '__________'),
    login       TEXT NOT NULL UNIQUE,
    name        TEXT NOT NULL,
    program     TEXT NOT NULL,
    FOREIGN KEY (program) REFERENCES Programs
);

CREATE TABLE Classifications(
    name        TEXT PRIMARY KEY
);

CREATE TABLE LimitedCourses(
    code        TEXT PRIMARY KEY,
    capacity    INT NOT NULL,
    CONSTRAINT positive_capacity CHECK(capacity>0),
    FOREIGN KEY (code) REFERENCES Courses
);

CREATE TABLE HostedBy(
    department  TEXT,
    program     TEXT,
    PRIMARY KEY (department, program),
    FOREIGN KEY (department) REFERENCES Departments,
    FOREIGN KEY (program) REFERENCES Programs
);

CREATE TABLE Classified(
    course       TEXT,
    classification TEXT,
    PRIMARY KEY (course, classification),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (classification) REFERENCES Classifications
);

CREATE TABLE BelongsTo(
    student     TEXT PRIMARY KEY,
    branch      TEXT NOT NULL,
    program     TEXT NOT NULL,
    FOREIGN KEY (student,program) REFERENCES Students,
    FOREIGN KEY (branch, program) REFERENCES Branches
);

CREATE TABLE Registered(
    student     TEXT,
    course      TEXT,
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course)  REFERENCES Courses
);

CREATE TABLE WaitingList(
    student             TEXT,
    limitedCourse       TEXT,
    position            SERIAL,
    PRIMARY KEY (student, limitedCourse),
    FOREIGN KEY (student)        REFERENCES Students,
    FOREIGN KEY (limitedCourse)  REFERENCES LimitedCourses,
    UNIQUE(limitedCourse, position)
);

CREATE TABLE GivenBy(
    course      TEXT,
    department  TEXT,
    PRIMARY KEY (course, department),
    FOREIGN KEY (course)  REFERENCES Courses,
    FOREIGN KEY (department) REFERENCES Departments
);

CREATE TABLE MandatoryProgram(
    course      TEXT,
    program     TEXT,
    PRIMARY KEY (course, program),
    FOREIGN KEY (course) REFERENCES Courses,
    FOREIGN KEY (program) REFERENCES Programs
);

CREATE TABLE MandatoryBranch(
    course      TEXT,
    branch      TEXT,
    program     TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches,
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE RecommendedBranch(
    course      TEXT,
    branch      TEXT,
    program     TEXT,
    PRIMARY KEY (course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches,
    FOREIGN KEY (course) REFERENCES Courses
);

CREATE TABLE Taken(
    student     TEXT,
    course      TEXT,
    grade       CHAR NOT NULL,
    CONSTRAINT valid_grade CHECK(grade IN ('U','3','4','5')),
    PRIMARY KEY (student, course),
    FOREIGN KEY (student) REFERENCES Students,
    FOREIGN KEY (course)  REFERENCES Courses
);


CREATE TABLE Prerequisite(
    needCourse  TEXT,
    forCourse   TEXT,
    PRIMARY KEY (needCourse, forCourse),
    FOREIGN KEY (needCourse) REFERENCES Courses,
    FOREIGN KEY (forCourse) REFERENCES Courses
);





