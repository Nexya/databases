-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('2222222222', 'CCC111');

-- TEST #2: Register an already registered student.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('2222222222', 'CCC111');

-- TEST #3: Register to limited course.
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('4444444444', 'CCC555');

-- TEST #4: Register to already passed course.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('4444444444','CCC111');

-- TEST #5: Check prerequisite.
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('1111111111','CCC222');

-- TEST #6: Insert into a non-full course
-- EXPECTED OUTCOME: Pass
-- DELETE FROM Registered WHERE student = '1111111111'AND course = 'CCC333';
