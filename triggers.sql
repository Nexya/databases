CREATE VIEW CourseQueuePositions As
SELECT student, limitedCourse AS course, position AS place
FROM WaitingList;

CREATE FUNCTION getCourseCapacity (course TEXT) RETURNS INT
LANGUAGE SQL
    RETURN (SELECT (SELECT capacity
                    FROM LimitedCourses
                    WHERE LimitedCourses.code = course));

CREATE FUNCTION getStudentRegistered (course TEXT) RETURNS INT
LANGUAGE SQL
    RETURN (SELECT (SELECT COUNT(student)
                    FROM registrations
                    WHERE registrations.course = course
                    AND status = 'registered'));

CREATE FUNCTION isCourseFull (course TEXT) RETURNS BOOLEAN
LANGUAGE SQL
    RETURN getStudentRegistered(course) > getCourseCapacity(course);

CREATE FUNCTION isLimitedCourse (course TEXT) RETURNS BOOLEAN
LANGUAGE SQL
    RETURN (SELECT (SELECT code
                   FROM LimitedCourses
                   WHERE code = course) IS NOT NULL);

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
            INSERT INTO waitinglist VALUES (NEW.student, NEW.course);
        ELSE
            INSERT INTO registered VALUES (NEW.student, NEW.course);
        END IF;

    RETURN NEW;
END;
$register$ LANGUAGE 'plpgsql';


CREATE TRIGGER register INSTEAD OF INSERT OR UPDATE ON registrations
    FOR EACH ROW EXECUTE FUNCTION register();

---

CREATE PROCEDURE removeRegistration(stu TEXT, cou TEXT)
LANGUAGE SQL
AS $$
DELETE FROM Registered
WHERE student = stu
AND course = cou
$$;

CREATE FUNCTION insertIfOpen() RETURNS TRIGGER AS $$
BEGIN
IF (isLimitedCourse(OLD.course) AND NOT isCourseFull(OLD.course)) THEN
    UPDATE Registrations SET status = 'Registered'
    FROM CourseQueuePositions
    WHERE CourseQueuePositions.course = OLD.course
    AND CourseQueuePositions.place = 1;
END IF;
RETURN NULL;
END
$$ LANGUAGE 'plpgsql';


CREATE TRIGGER newSpot AFTER DELETE ON Registered
FOR EACH STATEMENT
EXECUTE FUNCTION insertIfOpen();