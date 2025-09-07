-- Students Table
CREATE TABLE Students (
    StudentID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    EnrollmentNo VARCHAR(20) UNIQUE,
    Department VARCHAR(50)
);
-- Courses Table
CREATE TABLE Courses (
    CourseID INT AUTO_INCREMENT PRIMARY KEY,
    CourseCode VARCHAR(10) UNIQUE,
    CourseName VARCHAR(100),
    Credits INT NOT NULL
);
-- Semesters Table
CREATE TABLE Semesters (
    SemesterID INT AUTO_INCREMENT PRIMARY KEY,
    SemesterName VARCHAR(20),
    Year INT
);
-- Grades Table
CREATE TABLE Grades (
    GradeID INT AUTO_INCREMENT PRIMARY KEY,
    StudentID INT,
    CourseID INT,
    SemesterID INT,
    Grade CHAR(2),
    Marks INT,
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (CourseID) REFERENCES Courses(CourseID),
    FOREIGN KEY (SemesterID) REFERENCES Semesters(SemesterID)
);
-- Student GPA Table
CREATE TABLE StudentGPA (
    StudentID INT,
    SemesterID INT,
    GPA DECIMAL(4,2),
    PRIMARY KEY (StudentID, SemesterID),
    FOREIGN KEY (StudentID) REFERENCES Students(StudentID),
    FOREIGN KEY (SemesterID) REFERENCES Semesters(SemesterID)
);
-- Insert Students
INSERT INTO Students (Name, EnrollmentNo, Department) VALUES
('Alice Shaw', 'ENR001', 'CSE'),
('Bob Thomas', 'ENR002', 'CSE'),
('Charlie Iris', 'ENR003', 'ECE');
-- Insert Courses
INSERT INTO Courses (CourseCode, CourseName, Credits) VALUES
('CS101', 'Data Structures', 4),
('CS102', 'Databases', 3),
('EC101', 'Digital Systems', 4);
-- Insert Semesters
INSERT INTO Semesters (SemesterName, Year) VALUES
('Sem 1', 2025),
('Sem 2', 2025);
-- Insert Grades (Sample values)
INSERT INTO Grades (StudentID, CourseID, SemesterID, Grade, Marks) VALUES
(1, 1, 1, 'A', 89),  -- Data Structures, Sem 1
(1, 2, 1, 'B+', 75), -- Databases, Sem 1
(1, 3, 2, 'A+', 91); -- Digital Systems, Sem 2
INSERT INTO Grades (StudentID, CourseID, SemesterID, Grade, Marks) VALUES
(2, 1, 1, 'B', 72), 
(2, 2, 1, 'B', 78),
(2, 3, 2, 'A', 86);
INSERT INTO Grades (StudentID, CourseID, SemesterID, Grade, Marks) VALUES
(3, 1, 1, 'C', 60), 
(3, 2, 1, 'B+', 81),
(3, 3, 2, 'B', 75);

-- Grade Points Table
CREATE TABLE GradePoints (
    Grade CHAR(2) PRIMARY KEY,
    Point DECIMAL(3,1)
);
INSERT INTO GradePoints (Grade, Point) VALUES
('A+', 10.0),
('A', 9.0),
('B+', 8.0),
('B', 7.0),
('C', 6.0),
('D', 5.0),
('F', 0.0);

-- GPA Calculation Query
SELECT
    g.StudentID,
    s.Name,
    g.SemesterID,
    SUM(c.Credits * gp.Point) / SUM(c.Credits) AS GPA
FROM Grades g
JOIN Courses c ON g.CourseID = c.CourseID
JOIN Students s ON g.StudentID = s.StudentID
JOIN GradePoints gp ON g.Grade = gp.Grade
GROUP BY g.StudentID, g.SemesterID;

-- Pass/Fail Count Query
SELECT
    sem.SemesterName,
    COUNT(DISTINCT CASE WHEN gp.Point > 0 THEN g.StudentID END) AS PassCount,
    COUNT(DISTINCT CASE WHEN gp.Point = 0 THEN g.StudentID END) AS FailCount
FROM Grades g
JOIN GradePoints gp ON g.Grade = gp.Grade
JOIN Semesters sem ON g.SemesterID = sem.SemesterID
GROUP BY sem.SemesterName;

-- Semester Rank List
SELECT
    sg.SemesterID,
    s.Name,
    sg.GPA,
    RANK() OVER (PARTITION BY sg.SemesterID ORDER BY sg.GPA DESC) AS RankInSemester
FROM StudentGPA sg
JOIN Students s ON sg.StudentID = s.StudentID
ORDER BY sg.SemesterID, RankInSemester;

DELIMITER //
CREATE TRIGGER AfterGradeInsert
AFTER INSERT ON Grades
FOR EACH ROW
BEGIN
    -- Update or insert the StudentGPA for this student and semester
    INSERT INTO StudentGPA (StudentID, SemesterID, GPA)
    SELECT 
        NEW.StudentID,
        NEW.SemesterID,
        SUM(c.Credits * gp.Point) / SUM(c.Credits)
    FROM Grades g
    JOIN Courses c ON g.CourseID = c.CourseID
    JOIN GradePoints gp ON g.Grade = gp.Grade
    WHERE g.StudentID = NEW.StudentID AND g.SemesterID = NEW.SemesterID
    ON DUPLICATE KEY UPDATE GPA = VALUES(GPA);
END;
//
DELIMITER ;

CREATE VIEW SemesterResultSummary AS
SELECT
    sem.SemesterName,
    s.Name AS StudentName,
    SUM(c.Credits * gp.Point) / SUM(c.Credits) AS GPA,
    GROUP_CONCAT(CONCAT(c.CourseCode, ':', g.Grade) SEPARATOR ', ') AS GradesSummary
FROM Grades g
JOIN Students s ON g.StudentID = s.StudentID
JOIN Courses c ON g.CourseID = c.CourseID
JOIN Semesters sem ON g.SemesterID = sem.SemesterID
JOIN GradePoints gp ON g.Grade = gp.Grade
GROUP BY g.StudentID, g.SemesterID;
