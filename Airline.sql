-- Flights Table
CREATE TABLE Flights (
    FlightID INT AUTO_INCREMENT PRIMARY KEY,
    FlightNumber VARCHAR(10) NOT NULL,
    Origin VARCHAR(50) NOT NULL,
    Destination VARCHAR(50) NOT NULL,
    Departure DATETIME NOT NULL,
    Arrival DATETIME NOT NULL
);

-- Customers Table
CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100) UNIQUE
);

-- Seats Table
CREATE TABLE Seats (
    SeatID INT AUTO_INCREMENT PRIMARY KEY,
    FlightID INT,
    SeatNumber VARCHAR(5),
    SeatClass ENUM('Economy', 'Business', 'First'),
    IsAvailable BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID)
);

-- Bookings Table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    FlightID INT,
    CustomerID INT,
    SeatID INT,
    BookingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Booked','Cancelled') DEFAULT 'Booked',
    FOREIGN KEY (FlightID) REFERENCES Flights(FlightID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SeatID) REFERENCES Seats(SeatID)
);

-- Flights
INSERT INTO Flights (FlightNumber, Origin, Destination, Departure, Arrival) VALUES
('AI101', 'Delhi', 'Mumbai', '2025-09-01 10:00', '2025-09-01 12:15'),
('AI202', 'Mumbai', 'Bangalore', '2025-09-02 08:30', '2025-09-02 10:15');

-- Customers
INSERT INTO Customers (Name, Email) VALUES
('Alice Smith', 'alice@example.com'),
('Bob Patel', 'bob@example.com');

-- Seats for Flight 1
INSERT INTO Seats (FlightID, SeatNumber, SeatClass) VALUES
(1, '1A', 'Economy'),
(1, '1B', 'Economy'),
(1, '2A', 'Business'),
(1, '2B', 'Business');

-- Seats for Flight 2
INSERT INTO Seats (FlightID, SeatNumber, SeatClass) VALUES
(2, '1A', 'Economy'),
(2, '1B', 'Economy'),
(2, '2A', 'Business'),
(2, '2B', 'Business');

-- Bookings
INSERT INTO Bookings (FlightID, CustomerID, SeatID, Status) VALUES
(1, 1, 1, 'Booked'),   -- Alice books 1A on Flight 1
(2, 2, 5, 'Booked');   -- Bob books 1A on Flight 2

-- Update seat availability for booked seats
UPDATE Seats SET IsAvailable = FALSE WHERE SeatID IN (1,5);

SELECT s.SeatNumber, s.SeatClass
FROM Seats s
JOIN Flights f ON f.FlightID = s.FlightID
WHERE f.FlightNumber = 'AI101' AND s.IsAvailable = TRUE;

SELECT * FROM Flights
WHERE Origin = 'Delhi' AND Destination = 'Mumbai' AND Departure >= '2025-09-01';

DELIMITER //

CREATE TRIGGER AfterBooking
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Booked' THEN
        UPDATE Seats SET IsAvailable = FALSE WHERE SeatID = NEW.SeatID;
    END IF;
END;
//
DELIMITER ;

DELIMITER //

CREATE TRIGGER AfterCancellation
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Cancelled' THEN
        UPDATE Seats SET IsAvailable = TRUE WHERE SeatID = NEW.SeatID;
    END IF;
END;
//
DELIMITER ;

CREATE VIEW FlightAvailability AS
SELECT f.FlightNumber, f.Origin, f.Destination, s.SeatNumber, s.SeatClass, s.IsAvailable
FROM Flights f
JOIN Seats s ON f.FlightID = s.FlightID;

SELECT
    b.BookingID,
    c.Name AS CustomerName,
    f.FlightNumber,
    f.Origin,
    f.Destination,
    s.SeatNumber,
    s.SeatClass,
    b.Status,
    b.BookingDate
FROM Bookings b
JOIN Customers c ON b.CustomerID = c.CustomerID
JOIN Flights f ON b.FlightID = f.FlightID
JOIN Seats s ON b.SeatID = s.SeatID;
