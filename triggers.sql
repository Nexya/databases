CREATE VIEW CourseQueuePositions As
SELECT student, limitedCourse AS course, position AS place
FROM WaitingList;

-- REGISTER TRIGGER

CREATE FUNCTION register() RETURNS TRIGGER AS $register$
DECLARE
    checkCoursestatus TEXT;
    checkCoursecapacity INT;
    checkRegistered INT;
    checkPassed INT;
    checkPrerequisite TEXT;
    newPosition INT;
BEGIN

    -- has the student passed the required prerequisite? 
    checkPrerequisite := 
        ((SELECT needCourse FROM Prerequisite WHERE forCourse = NEW.course) 
        EXCEPT
        (SELECT PassedCourses.course FROM PassedCourses WHERE PassedCourses.student = NEW.student));
        IF checkPrerequisite IS NOT NULL THEN 
            RAISE EXCEPTION 'Student has not passed the required prerequisite for this course.';
        END IF;

    -- is student already registered or in waiting list? 
    checkCoursestatus := 
        (SELECT status FROM registrations WHERE student=NEW.student AND course=NEW.course);
        IF checkCoursestatus='registered' THEN
            RAISE EXCEPTION 'Student is already registered for this course';
        END IF;
        IF checkCoursestatus='waiting' THEN
            RAISE EXCEPTION 'Student is already in the waiting list for this course';
        END IF;

    -- has the student already passed the course? 
    checkPassed :=
        (SELECT credits FROM PassedCourses WHERE student=NEW.student AND course=NEW.course);
        IF checkPassed >= 0 THEN 
            RAISE EXCEPTION 'Student has already passed the course';
        END IF;

    -- is course full? if not register student
    checkCoursecapacity :=  -- 1
        (SELECT capacity FROM LimitedCourses WHERE LimitedCourses.code = NEW.course);

    checkRegistered  := 
        (SELECT (SELECT COUNT(student) FROM Registered WHERE Registered.course = NEW.course));
        IF checkRegistered >= checkCoursecapacity THEN
            newPosition := 
                (COALESCE((SELECT MAX(place) FROM CourseQueuePositions WHERE CourseQueuePositions.course = NEW.course),0) + 1);
            INSERT INTO WaitingList VALUES (NEW.student, NEW.course, newPosition);
        ELSE
            INSERT INTO Registered VALUES (NEW.student, NEW.course);
        END IF;

    
    RETURN NEW;
END;
$register$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS register ON Registrations;
CREATE TRIGGER register INSTEAD OF INSERT ON Registrations
    FOR EACH ROW EXECUTE FUNCTION register();

--- UNREGISTER TRIGGER

CREATE OR REPLACE FUNCTION unregister() RETURNS trigger AS $unregister$
    DECLARE
        checkUnregistered TEXT;
        courseCount INT;
        numStudents INT;
        currentPosition INT;
    BEGIN

        -- delete student from registered
        IF OLD.student IN(SELECT Registered.student FROM registered WHERE registered.course = OLD.course) THEN
            DELETE FROM Registered  WHERE student = OLD.student AND course = OLD.course;
        END IF;


        currentPosition := 
                (SELECT place FROM CourseQueuePositions WHERE course = OLD.course AND student = OLD.student);
        -- delete student from waiting list
        IF OLD.student IN(SELECT coursequeuepositions.student FROM coursequeuepositions WHERE  coursequeuepositions.course = OLD.course) THEN
            DELETE FROM WaitingList WHERE student = OLD.student AND limitedCourse = OLD.course;
            UPDATE WaitingList SET position = position-1 WHERE limitedCourse = OLD.course AND position > currentPosition;
        END IF;
          
        -- check course capacity if next student in waiting list can register, if yes do so
        courseCount := 
            (SELECT capacity FROM LimitedCourses WHERE LimitedCourses.code = OLD.course);
        numStudents := 
            (SELECT COUNT(student) FROM Registered WHERE Registered.course = OLD.course);
        IF numStudents < courseCount THEN 
            INSERT INTO Registered (SELECT student, limitedCourse FROM WaitingList WHERE limitedCourse = OLD.course AND position = 1);
            DELETE FROM WaitingList WHERE position = 1 AND limitedCourse = OLD.course;
             -- update waiting list
            UPDATE WaitingList SET position = position - 1 WHERE limitedCourse = OLD.course;
        END IF;

        RETURN OLD;
    END;
$unregister$ LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS unregister ON Registrations;
CREATE TRIGGER unregister INSTEAD OF DELETE OR UPDATE ON Registrations
    FOR EACH ROW EXECUTE FUNCTION unregister();