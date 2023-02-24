
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