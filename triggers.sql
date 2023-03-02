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
BEGIN


    -- has the student passed the required prerequisite? 
    checkPrerequisite := 
        ((SELECT needCourse FROM Prerequisite WHERE forCourse = NEW.course) 
        EXCEPT
        (SELECT Taken.course FROM Taken WHERE Taken.student = NEW.student));
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
    checkCoursecapacity := 
        (SELECT capacity FROM LimitedCourses WHERE LimitedCourses.code = NEW.course);

    checkRegistered  := 
        (SELECT (SELECT COUNT(student) FROM registrations WHERE registrations.course = NEW.course AND status = 'registered'));
        IF checkRegistered >= checkCoursecapacity THEN
            INSERT INTO waitinglist VALUES (NEW.student, NEW.course);
        ELSE
            INSERT INTO registered VALUES (NEW.student, NEW.course);
        END IF;

    RETURN NEW;
END;
$register$ LANGUAGE 'plpgsql';

CREATE TRIGGER register INSTEAD OF INSERT ON registrations
    FOR EACH ROW EXECUTE FUNCTION register();

--- UNREGISTER TRIGGER

CREATE OR REPLACE FUNCTION unregister() RETURNS trigger AS $unregister$
    DECLARE
    updateCoursecapacity INT;

    BEGIN
        -- delete student from registered and waiting list
        DELETE FROM Registered  WHERE student = OLD.student AND course = OLD.course;
        DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;

        updateCoursecapacity := 
            (SELECT capacity FROM LimitedCourses WHERE code = OLD.course);
            

        RETURN NEW;
    END;
$unregister$ LANGUAGE 'plpgsql';

