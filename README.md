# Airline_Reservation_System
A SQL  system to manage flights and bookings

1. Schema Design (code line 1-39)
a) Flights: Flight information
b) Customers: User information
c) Seats: Individual seat info per flight
d) Bookings: Which customer booked which seat on which flight

2. Sample Data (code line 41-71)
   
3. Queries (code line 73-79)
a) Available Seats for a flight
b) Flight Search by Origin/Destination/Date

4. Triggers (code line 81-105)
a) Booking-Update Seat Availabiltiy
b) Booking Cancellation-Release Seat

5. Flight Availability View (code line 107-110)
   
6. Booking Summary Report (code line 112-125)


# Student_Result_Processing
A SQL  system to manage students results.

1. Schema Design (code line 1-41)
a) Students: Details of students
b) Courses: Students courses
c) Semesters: To hold student's semester information
d) Grades: To manage students grades
e) Student GPA: To calculate the students GPA

2. Sample Data (code line 42-68)

3. Grade to Grade Point Mapping (Helper Table and View) (code line 70-82)
   
4. Queries (code line 84-104)
   a) GPA Calculation Per Student Per Semester
   b) Pass/Fail Statistics per Semester

5. Rank List using Window Functions (Per Semester) (code line 106-114)

6. Triggers for GPA Calculation (On new Grades Insert) (code line 116-134)

7. Semester-wise Result Summary View (code line 136-146)
