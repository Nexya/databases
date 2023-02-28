---------------------------------------------

-- TEST #1: Register for an unlimited course.
-- EXPECTED OUTCOME: Pass
--INSERT INTO Registrations VALUES ('2222222222', 'CCC111');

-- TEST #2: Register to limited course.
-- EXPECTED OUTCOME: Pass
--INSERT INTO Registrations VALUES ('4444444444', 'CCC555');

-- TEST #3: Waiting for a limited course.
-- EXPECTED OUTCOME: ?

-- Test #4: Removed from a waiting list (with additional students in it).
-- EXPECTED OUTCOME: PASS
-- DELETE FROM WaitingList WHERE student = '3333333333' AND limitedCourse = 'CCC222';

-- TEST #5: Unregister from an unlimited course.
-- EXPECTED OUTCOME: Pass
-- DELETE FROM registered WHERE student = '1111111111' AND course = 'CCC111';

-- TEST 6: unregistered from a limited course without a waiting list.
-- EXPECTED OUTCOME: 

-- TEST 7: unregistered from a limited course with a waiting list, when the student is registered.
-- EXPECTED OUTCOME: 

-- TEST 8: unregistered from a limited course with a waiting list, 
-- when the student is in the middle of the waiting list;
-- EXPECTED OUTCOME: 

-- TEST #9: unregistered from an overfull course with a waiting list.
-- EXPECTED OUUTCOME: Fail
-- DELETE FROM Registered WHERE student = '1111111111' AND course = 'CCC222';

-- TEST #10: Register an already registered student.
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registrations VALUES ('2222222222', 'CCC111');

-- TEST #11: Register to already passed course.
-- EXPECTED OUTCOME: Fail
--INSERT INTO Registrations VALUES ('4444444444','CCC111');


---------------------------------------------



-- TEST #6: Insert into a non-full course
-- EXPECTED OUTCOME: Pass
-- DELETE FROM Registered WHERE student = '1111111111'AND course = 'CCC333';

/* SELECT (SELECT status 
        FROM registrations 
        WHERE student = '3333333333'
        AND course = 'CCC333') = 'registered' AS successful_Queue_Insert;

SELECT * FROM CourseQueuePositions WHERE course = 'CCC333'; */
