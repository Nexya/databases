/*
TODO:   implement views
*/


-- BasicInformation(idnr, name, login, program, branch)
CREATE VIEW BasicInformation AS 
SELECT Students.idnr, Students.name, Students.login, Students.program, 
(SELECT branch FROM StudentBranches WHERE StudentBranches.student = Students.idnr) 
FROM Students;

-- FinishedCourses(student, course, grade, credits)
CREATE VIEW FinishedCourses AS
SELECT Taken.student, Taken.course, Taken.grade,
(SELECT credits FROM Courses WHERE Taken.course = Courses.code)
FROM Taken;

--PassedCourses(student, course, credits)
CREATE VIEW PassedCourses AS
SELECT * FROM FinishedCourses WHERE NOT grade = 'U';

--Registrations(student, course, status)
CREATE VIEW Registrations AS
SELECT WaitingList.student, WaitingList.course, 'waiting' AS status FROM WaitingList
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
SELECT StudentBranches.student, MandatoryBranch.course
FROM StudentBranches, MandatoryBranch
WHERE StudentBranches.branch = MandatoryBranch.branch
EXCEPT
-- delete taken courses
SELECT Taken.student, Taken.course FROM Taken;

