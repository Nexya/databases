CREATE VIEW CourseQueuePositions As
SELECT student, limitedCourse AS course, position AS place
FROM WaitingList;


CREATE FUNCTION register() RETURNS TRIGGER AS $register$
DECLARE
    checkcoursestatus TEXT;
    checkcurrentCourseCapacity INT;
    checkstudentsRegistered INT;
    checkifpassed INT;
BEGIN

    -- is student already registered or in waiting list? 
    checkcoursestatus := 
        (SELECT status FROM registrations WHERE student=NEW.student AND course=NEW.course);
        IF checkcoursestatus='registered' THEN
            RAISE EXCEPTION 'Student is already registered for this course';
        END IF;
      
        IF checkcoursestatus='waiting' THEN
            RAISE EXCEPTION 'Student is already in the waiting list for this course';
        END IF;

    -- has the student already passed the course? 
    checkifpassed :=
        (SELECT credits FROM PassedCourses WHERE student=NEW.student AND course=NEW.course);
        IF checkifpassed >= 0 THEN 
            RAISE EXCEPTION 'Student has already passed the course';
        END IF;

    -- has the student passed prerequisite ? 
    --checkprerequisite := 
        

    -- is course full? if not register student
    checkcurrentCourseCapacity := 
        (SELECT capacity FROM LimitedCourses WHERE LimitedCourses.code = NEW.course);

    checkstudentsRegistered  := 
        (SELECT (SELECT COUNT(student) FROM registrations WHERE registrations.course = NEW.course AND status = 'registered'));
        IF checkstudentsRegistered >= checkcurrentCourseCapacity THEN
            INSERT INTO waitinglist VALUES (NEW.student, NEW.course);
        ELSE
            INSERT INTO registered VALUES (NEW.student, NEW.course);
        END IF;

    RETURN NEW;
END;
$register$ LANGUAGE 'plpgsql';


CREATE TRIGGER register INSTEAD OF INSERT OR UPDATE ON registrations
    FOR EACH ROW EXECUTE FUNCTION register();