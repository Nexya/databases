CREATE VIEW CourseQueuePositions As
SELECT student, limitedCourse AS course, position AS place
FROM WaitingList;

CREATE FUNCTION getCourseCapacity (course TEXT) RETURNS INT
LANGUAGE SQL
    RETURN (SELECT (SELECT capacity
                    FROM LimitedCourses
                    WHERE LimitedCourses.code = course));

CREATE FUNCTION getStudentRegistered (TEXT) RETURNS INT
LANGUAGE SQL
    RETURN (SELECT COUNT(student)
                    FROM registrations
                    WHERE course = $1
                    AND status = 'registered');

CREATE FUNCTION isCourseFull (course TEXT) RETURNS BOOLEAN
LANGUAGE SQL
    RETURN getStudentRegistered(course) > getCourseCapacity(course);

CREATE FUNCTION isLimitedCourse (course TEXT) RETURNS BOOLEAN
LANGUAGE SQL
    RETURN (SELECT (SELECT code
                   FROM LimitedCourses
                   WHERE code = course) IS NOT NULL);

CREATE FUNCTION nextPos(TEXT) RETURNS INT AS $$
    SELECT COUNT(*) + 1
    FROM WaitingList
    WHERE limitedCourse = $1
$$ LANGUAGE SQL;

CREATE FUNCTION register() RETURNS TRIGGER AS $register$
DECLARE
    checkcoursestatus TEXT;
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

    -- is course full? if not register student
        IF isCourseFull(New.Course) THEN
            INSERT INTO waitinglist VALUES (NEW.student, NEW.course, nextPos(NEW.course));
        ELSE
            INSERT INTO registered VALUES (NEW.student, NEW.course);
        END IF;

    RETURN NEW;
END;
$register$ LANGUAGE 'plpgsql';


CREATE TRIGGER register INSTEAD OF INSERT ON registrations
    FOR EACH ROW EXECUTE FUNCTION register();


CREATE PROCEDURE removeRegistration(stu TEXT, cou TEXT)
LANGUAGE SQL
AS $$
DELETE FROM Registered
WHERE student = stu
AND course = cou
$$;


CREATE OR REPLACE FUNCTION unregister() RETURNS trigger AS $unregister$
    BEGIN
        --- checks
        IF (isCourseFull(OLD.course)) THEN
            RAISE EXCEPTION 'too full';
        END IF;
                --example
                --Remove student first student from waiting list and place in registered
        WITH student AS (DELETE FROM WaitingList WHERE old.course = limitedCourse AND position = 1
        RETURNING *)
            INSERT INTO Registered SELECT student, limitedCourse FROM student;
        DELETE FROM Registered WHERE student = OLD.student AND course = old.course;

          RETURN NEW;
    END;
$unregister$ LANGUAGE 'plpgsql';


CREATE TRIGGER newSpot AFTER DELETE ON Registered
FOR EACH ROW
EXECUTE FUNCTION unregister();

-- Reduces the positions by 1 for all positions greater than the deleted.
CREATE FUNCTION updatePosition() RETURNS TRIGGER AS $$
BEGIN
    UPDATE WaitingList
    SET position = position - 1
    WHERE OLD.position < position AND OLD.limitedCourse = limitedCourse;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Correctly order the waiting list after a deletion.
CREATE TRIGGER updateWaitingList AFTER DELETE ON WaitingList
FOR EACH ROW
EXECUTE FUNCTION updatePosition();