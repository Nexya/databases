CREATE VIEW CourseQueuePositions As
SELECT student, limitedCourse AS course, position AS place
FROM WaitingList;

CREATE FUNCTION register() RETURNS TRIGGER AS $$
DECLARE
    checkcoursestatus TEXT;
    checkcurrentCourseCapacity INT;
    studentsRegistered INT;
    checkifpassed INT;
BEGIN

    -- is student already registered or in waiting list? 
    checkcoursestatus := 
        (SELECT status FROM registrations WHERE student=NEW.student AND course=NEW.course);
        IF coursestatus='registered' THEN
            RAISE EXCEPTION 'Student is already registered for this course';
        END IF;
      
        IF coursestatus='waiting' THEN
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

    studentsRegistered  := 
        (SELECT (SELECT COUNT(student) FROM registrations WHERE registrations.course = NEW.course AND status = 'registered'));
        IF studentRegistered >= currentCourseCapacityq THEN
            INSERT INTO waitinglist VALUES (NEW.student, NEW.course);
        ELSE
            INSERT INTO registered VALUES (NEW.student, NEW.course);
        END IF;
END;
$$ LANGUAGE 'plpgsql';
