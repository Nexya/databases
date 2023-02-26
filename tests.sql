\ir setup.sql

---------------------------------------------

-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
--INSERT INTO Registrations VALUES ('2222222222', 'CCC111');

-- TEST #2: Register an already registered student.
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registrations VALUES ('2222222222', 'CCC111');

-- TEST #3: Register to limited course.
-- EXPECTED OUTCOME: Pass
--INSERT INTO Registrations VALUES ('4444444444', 'CCC555');

-- TEST #4: Register to already passed course.
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registrations VALUES ('4444444444','CCC111');


---------------------------------------------

CALL removeRegistration('1111111111','CCC222');
SELECT (SELECT status 
        FROM registrations 
        WHERE student = '3333333333'
        AND course = 'CCC222') = 'registered' AS successful_Queue_Insert;
