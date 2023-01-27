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


