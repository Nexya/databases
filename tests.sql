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

-- TEST #5: Check prerequisite that is not fulfilled
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('1111111111','CCC222');

-- TEST #6: Unregister registered student
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC111';

-- TEST #9: Unregister student that has already been unregistered
-- EXPECTED OUTCOME: Fail
DELETE FROM Registrations WHERE student = '2222222222' AND course = 'CCC111'; -- NOT WORKING

-- TEST #10: Add student to waitinglist that is already there 
-- EXPECTED OUTCOME: Fail
INSERT INTO Registrations VALUES ('3333333333','CCC222'); 

-- TEST #11: Check prerequisite that is fulfilled
-- EXPECTED OUTCOME: Pass
INSERT INTO Registrations VALUES ('5555555555','CCC333');

-- TEST #12: Unregister from an overfull course with a waiting list -- ADD OVERFULL 
-- EXPECTED OUTCOME: Pass
DELETE FROM Registrations WHERE course = 'CCC333' AND student = '2222222222';