CREATE FUNCTION isLimitedCapacityCourse(course TEXT) RETURNS BOOLEAN AS $$
BEGIN
    RETURN (SELECT (SELECT code FROM LimitedCourses WHERE code = course) IS NOT NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE FUNCTION limitedCapacity() RETURNS TRIGGER AS $$
DECLARE
    currentCourseCapacity INT := 
        (SELECT capacity FROM LimitedCourses WHERE LimitedCourses.code = NEW.course);
    studentRegistered INT := 
        (SELECT (SELECT COUNT(student) FROM Registered WHERE Registered.course = NEW.course));
BEGIN
    IF (isLimitedCapacityCourse(NEW.course))
        THEN 
        IF (studentRegistered > currentCourseCapacity)
            THEN
            INSERT INTO WaitingList VALUES(NEW.student,NEW.course,5);
            DELETE FROM Registered 
            WHERE Registered.course = NEW.course AND Registered.student = NEW.student;
        END IF;
    END IF;
    RETURN NULL;
END
$$ LANGUAGE 'plpgsql';

CREATE FUNCTION gradeFound(stu TEXT,cou TEXT) RETURNS BOOLEAN AS $$
BEGIN
    RETURN (SELECT (SELECT grade FROM Taken WHERE Taken.course = cou
    AND Taken.student = stu) IS NOT NULL);
END;
$$ LANGUAGE 'plpgsql';

CREATE FUNCTION haveGrade() RETURNS TRIGGER AS $$
BEGIN
    IF (gradeFound(NEW.student,NEW.course))
        THEN RAISE EXCEPTION 'You already have a grade';
    END IF;
    RETURN NULL;
END
$$ LANGUAGE 'plpgsql';