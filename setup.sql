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

CREATE TABLE Courses(
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
    FOREIGN KEY (program) REFERENCES Programs,
    UNIQUE(idnr,program)
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
    FOREIGN KEY (student,program) REFERENCES Students(idnr,program),
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

INSERT INTO Programs VALUES ('Prog1', 'P1');
INSERT INTO Programs Values ('Prog2', 'P2');

INSERT INTO Departments VALUES ('Dep1', 'D1');

INSERT INTO Branches VALUES ('B1','Prog1');
INSERT INTO Branches VALUES ('B2','Prog1');
INSERT INTO Branches VALUES ('B1','Prog2');

INSERT INTO Students VALUES ('1111111111','N1','ls1','Prog1');
INSERT INTO Students VALUES ('2222222222','N2','ls2','Prog1');
INSERT INTO Students VALUES ('3333333333','N3','ls3','Prog2');
INSERT INTO Students VALUES ('4444444444','N4','ls4','Prog1');
INSERT INTO Students VALUES ('5555555555','N5','ls5','Prog2');
INSERT INTO Students VALUES ('6666666666','Nx','ls6','Prog2');

INSERT INTO Courses VALUES ('CCC111','C1',22.5,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1');
INSERT INTO Courses VALUES ('CCC444','C4',60,'Dep1');
INSERT INTO Courses VALUES ('CCC555','C5',50,'Dep1');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

INSERT INTO Classifications VALUES ('math');
INSERT INTO Classifications VALUES ('research');
INSERT INTO Classifications VALUES ('seminar');

INSERT INTO Classified VALUES ('CCC333','math');
INSERT INTO Classified VALUES ('CCC444','math');
INSERT INTO Classified VALUES ('CCC444','research');
INSERT INTO Classified VALUES ('CCC444','seminar');


INSERT INTO BelongsTo VALUES ('2222222222','B1','Prog1');
INSERT INTO BelongsTo VALUES ('3333333333','B1','Prog2');
INSERT INTO BelongsTo VALUES ('4444444444','B1','Prog1');
INSERT INTO BelongsTo VALUES ('5555555555','B1','Prog2');

INSERT INTO MandatoryProgram VALUES ('CCC111','Prog1');

INSERT INTO MandatoryBranch VALUES ('CCC333', 'B1', 'Prog1');
INSERT INTO MandatoryBranch VALUES ('CCC444', 'B1', 'Prog2');

INSERT INTO RecommendedBranch VALUES ('CCC222', 'B1', 'Prog1');
INSERT INTO RecommendedBranch VALUES ('CCC333', 'B1', 'Prog2');

INSERT INTO Registered VALUES ('1111111111','CCC111');
INSERT INTO Registered VALUES ('1111111111','CCC222');
INSERT INTO Registered VALUES ('1111111111','CCC333');
INSERT INTO Registered VALUES ('2222222222','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC222');
INSERT INTO Registered VALUES ('5555555555','CCC333');

INSERT INTO Taken VALUES('4444444444','CCC111','5');
INSERT INTO Taken VALUES('4444444444','CCC222','5');
INSERT INTO Taken VALUES('4444444444','CCC333','5');
INSERT INTO Taken VALUES('4444444444','CCC444','5');

INSERT INTO Taken VALUES('5555555555','CCC111','5');
INSERT INTO Taken VALUES('5555555555','CCC222','4');
INSERT INTO Taken VALUES('5555555555','CCC444','3');

INSERT INTO Taken VALUES('2222222222','CCC111','U');
INSERT INTO Taken VALUES('2222222222','CCC222','U');
INSERT INTO Taken VALUES('2222222222','CCC444','U');

INSERT INTO WaitingList VALUES('3333333333','CCC222',1);
INSERT INTO WaitingList VALUES('3333333333','CCC333',1);
INSERT INTO WaitingList VALUES('2222222222','CCC333',2);



-- BasicInformation(idnr, name, login, program, branch)
CREATE VIEW BasicInformation AS 
SELECT Students.idnr, Students.name, Students.login, Students.program, branch
FROM Students LEFT OUTER JOIN BelongsTo
ON BelongsTo.student = Students.idnr;

-- FinishedCourses(student, course, grade, credits)
CREATE VIEW FinishedCourses AS
SELECT Taken.student, Taken.course, Taken.grade, credits
FROM Taken LEFT OUTER JOIN Courses
ON Taken.course = Courses.code;

--PassedCourses(student, course, credits)
CREATE VIEW PassedCourses AS
SELECT FinishedCourses.student, FinishedCourses.course, FinishedCourses.credits
FROM FinishedCourses WHERE NOT grade = 'U';

--Registrations(student, course, status)
CREATE VIEW Registrations AS
SELECT WaitingList.student, WaitingList.limitedCourse AS course, 'waiting' AS status FROM WaitingList
UNION
SELECT Registered.student, Registered.course, 'registered' AS status FROM Registered;


--UnreadMandatory(student, course)
CREATE VIEW UnreadMandatory AS
-- table of all courses from mandatory program
SELECT  Students.idnr AS student, MandatoryProgram.course 
FROM Students, MandatoryProgram
WHERE Students.program = MandatoryProgram.program
UNION
-- table of all courses from mandatory branch
SELECT BelongsTo.student, MandatoryBranch.course
FROM BelongsTo, MandatoryBranch
WHERE BelongsTo.program = MandatoryBranch.program
AND BelongsTo.branch = MandatoryBranch.branch
EXCEPT
-- delete taken courses with grade 3 or higher
SELECT PassedCourses.student, PassedCourses.course FROM PassedCourses; 



-- helper for recommendedcredits
CREATE VIEW RecommendedCourses AS 
SELECT student, course, credits AS recommendedCredits FROM BelongsTo JOIN RecommendedBranch
ON (BelongsTo.branch, BelongsTo.program) = (RecommendedBranch.branch, RecommendedBranch.program) 
JOIN Courses ON course = code;


-- PathToGraduation(student, totalCredits, mandatoryLeft, mathCredits, researchCredits, seminarCourses, qualified)
CREATE VIEW PathToGraduation AS
SELECT 
    Students.idnr                   AS student,
    COALESCE(totalCredits,0)        AS totalCredits,
    COALESCE(mandatoryLeft,0)       AS mandatoryLeft,
    COALESCE(mathCredits,0)         AS mathCredits,
    COALESCE(researchCredits, 0)    AS researchCredits,
    COALESCE(seminarCourses,0)      AS seminarCourses,
    CASE WHEN MandatoryLeft IS NULL 
    AND MathCredits >= 20 
    AND ResearchCredits >= 10 
    AND SeminarCourses >= 1 
    AND recommendedCredits >= 10
        THEN TRUE
        ELSE FALSE END              AS qualified 
FROM Students

-- totalCredits
LEFT JOIN (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS totalCredits
    FROM PassedCourses
    GROUP BY PassedCourses.student
) totalCredits ON Students.idnr = totalCredits.student

-- mandatoryLefts
LEFT JOIN (
    SELECT UnreadMandatory.student, COUNT(UnreadMandatory.course) AS mandatoryLeft
    FROM UnreadMandatory
    GROUP BY UnreadMandatory.student
) mandatoryLeft ON Students.idnr = mandatoryLeft.student

-- mathCredits
LEFT JOIN (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS mathCredits
    FROM PassedCourses
    WHERE PassedCourses.course IN (SELECT Classified.course FROM Classified WHERE Classified.classification = 'math')
    GROUP BY PassedCourses.student
) mathCredits ON Students.idnr = mathCredits.student

-- researchCredits
LEFT JOIN (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS researchCredits
    FROM PassedCourses
    WHERE PassedCourses.course IN (SELECT Classified.course FROM Classified WHERE Classified.classification = 'research')
    GROUP BY PassedCourses.student
) researchCredits ON Students.idnr = researchCredits.student

-- seminarCourses
LEFT JOIN (
    SELECT PassedCourses.student, COUNT(PassedCourses.course) AS seminarCourses
    FROM PassedCourses
    WHERE PassedCourses.course IN (SELECT Classified.course FROM Classified WHERE Classified.classification = 'seminar')
    GROUP BY PassedCourses.student
) seminarCourses ON Students.idnr = seminarCourses.student

-- recommendedCredits
LEFT JOIN (
    SELECT PassedCourses.student, SUM(PassedCourses.credits) AS recommendedCredits
    FROM PassedCourses LEFT OUTER JOIN RecommendedCourses ON PassedCourses.student = RecommendedCourses.student
    WHERE PassedCourses.course = RecommendedCourses.course 
    GROUP BY PassedCourses.student
) recommendedCredits ON Students.idnr = recommendedCredits.student;