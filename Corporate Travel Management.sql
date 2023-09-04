DROP DATABASE employeetravelmanagement;
CREATE DATABASE IF NOT EXISTS employeetravelmanagement;
USE EmployeeTravelManagement;

-- TABLES
-- Employees Table
CREATE TABLE IF NOT EXISTS Employees
(EmployeeID INT NOT NULL,
EmpFirstName VARCHAR(25),
EmpLastName VARCHAR(25),
hiredate DATE,
dept_name VARCHAR(25),
designation VARCHAR(45),
ReportsTo VARCHAR(45),
PRIMARY KEY (EmployeeID));

-- Employee Travel Request Table
CREATE TABLE IF NOT EXISTS Travel_Requests
(EmployeeID INT NOT NULL,
RequestID INT NOT NULL AUTO_INCREMENT,
TravelType VARCHAR(20),
LeavingFrom VARCHAR(45),
GoingTo VARCHAR(45),
DepartDate DATE,
ReturnDate DATE,
PurposeofTravel VARCHAR(50),
TransportType VARCHAR(20),
ServiceClass VARCHAR(20),
HotelType VARCHAR(50),
CostEstimate FLOAT,
Submitted_Date DATE,
Request_Status VARCHAR(15) DEFAULT 'Assigned',
PRIMARY KEY (RequestID),
CONSTRAINT Travel_Requests_FK FOREIGN KEY (EmployeeID)
REFERENCES Employees (EmployeeID));

ALTER TABLE Travel_Requests AUTO_INCREMENT=1111;

-- Employee Approval workflow
CREATE TABLE IF NOT EXISTS TravelApproval
(RequestID INT NOT NULL,
EmployeeID INT NOT NULL,
EmpName VARCHAR(60),
ParticipantApprover VARCHAR(50),
actionStatus VARCHAR(25) DEFAULT 'Assigned',
PRIMARY KEY(RequestID,EmployeeID),
CONSTRAINT TravelApproval_FK FOREIGN KEY (RequestID)
REFERENCES Travel_Requests (RequestID));

-- Company Preferred Airlines Table
CREATE TABLE IF NOT EXISTS preferred_airlines
(flight_no VARCHAR(10),
airline_name VARCHAR(25),
terminal VARCHAR(50),
to_airport VARCHAR(50),
service_class varchar(20),
ticket_cost FLOAT,
PRIMARY KEY (flight_no));

-- Airlines Booking Table
CREATE TABLE IF NOT EXISTS Booking_details
(BookingID INT NOT NULL AUTO_INCREMENT,
flight_no VARCHAR(10),
EmployeeCode INT NOT NULL,
Destination VARCHAR(50),
TravelDate DATE,
ReturnDate DATE,
BookingDate DATE,
Travel_Class VARCHAR(15),
Carrier VARCHAR(50),
Terminal VARCHAR(50),
Travel_Cost FLOAT,
PRIMARY KEY (BookingID),
CONSTRAINT Booking_details_FK FOREIGN KEY (EmployeeCode)
REFERENCES Travel_Requests (EmployeeID));

ALTER TABLE Booking_details AUTO_INCREMENT=1000;

-- Junction Table for Preferred_Airlines and Booking_details
CREATE TABLE IF NOT EXISTS service_on_airlines(
s_on_flight_no VARCHAR(10),
s_on_BookingID INT,
 PRIMARY KEY (s_on_flight_no,s_on_BookingID),
 KEY s_on_BookingID (s_on_BookingID),
 KEY s_on_flight_no (s_on_flight_no),
 CONSTRAINT service_on_airlines_fk2 FOREIGN KEY 
(s_on_flight_no) REFERENCES preferred_airlines (flight_no) ON DELETE 
CASCADE,
 CONSTRAINT service_on_airlines_fk1 FOREIGN KEY 
(s_on_BookingID) REFERENCES Booking_details (BookingID));

-- Hotel/Apartment Details
CREATE TABLE IF NOT EXISTS preferred_accommdation
(accom_ID INT NOT NULL AUTO_INCREMENT,
accom_type VARCHAR(10),
accom_name VARCHAR(50),
location VARCHAR(50),
PRIMARY KEY (accom_ID));
ALTER TABLE preferred_accommdation AUTO_INCREMENT=1234;

-- Accomodation Details Table
CREATE TABLE IF NOT EXISTS Accommodation
(BookingID INT NOT NULL AUTO_INCREMENT,
EmpCode INT,
Cust_Name VARCHAR(25) NOT NULL,
room_no INT,
AccomName VARCHAR(50),
AccomType VARCHAR(10),
CheckIn DATE,
CheckOut DATE,
AccomCost FLOAT,
PRIMARY KEY (BookingID),
CONSTRAINT Accommodation_FK FOREIGN KEY (EmpCode)
REFERENCES Travel_Requests (EmployeeID));
ALTER TABLE Accommodation AUTO_INCREMENT=1001;

-- Junction Table for preferred_accomdation and accomodation
CREATE TABLE IF NOT EXISTS service_on_accomodation(
s_on_accom_ID INT,
s_on_BookingID INT,
 PRIMARY KEY (s_on_accom_ID,s_on_BookingID),
 KEY s_on_BookingID (s_on_BookingID),
 KEY s_on_accom_ID (s_on_accom_ID),
 CONSTRAINT service_on_accommodation_fk2 FOREIGN KEY 
(s_on_accom_ID) REFERENCES preferred_accommdation (accom_ID) ON DELETE 
CASCADE,
 CONSTRAINT service_on_accommodation_fk1 FOREIGN KEY 
(s_on_BookingID) REFERENCES Accommodation (BookingID));

-- All Employees Travel History
CREATE TABLE IF NOT EXISTS EmployeesTravelLog
(EmpID INT NOT NULL,
EmpFirstName VARCHAR(25),
EmpLastName VARCHAR(25),
Place VARCHAR(40),
Purpose VARCHAR(50),
TravelDate DATE,
TotalCost FLOAT,
PRIMARY KEY (EmpID,TravelDate),
CONSTRAINT EmployeesTravelLog_FK FOREIGN KEY (EmpID)
REFERENCES Employees (EmployeeID));

-- Employee Expense Report tables
-- Employee Expense Table 
CREATE TABLE IF NOT EXISTS Employee_Expense
(EmpID INT NOT NULL,
Exp_InvID INT AUTO_INCREMENT,
EmpName VARCHAR(50),
from_Date DATE,
to_Date DATE,
Submitted_by DATE,
PRIMARY KEY (Exp_InvID),
CONSTRAINT Employee_Expense_FK FOREIGN KEY (EmpID)
REFERENCES Employees (EmployeeID));

-- Employee Invoice table for all expense categories
CREATE TABLE IF NOT EXISTS Expense_Invoice
(Exp_InvID INT NOT NULL,
SubmittedBy INT NOT NULL,
EmpFName VARCHAR(25),
EmpLName VARCHAR(25),
ExpenseDesc VARCHAR(100),
ExpenseCategory VARCHAR(50),
Amount FLOAT,
SubmissionDate DATE,
PRIMARY KEY (Exp_InvID,ExpenseCategory),
CONSTRAINT Expense_Invoice_FK FOREIGN KEY (SubmittedBy)
REFERENCES Employees (EmployeeID),
CONSTRAINT Expense_Invoice_FK1 FOREIGN KEY (Exp_InvID)
REFERENCES Employee_Expense (Exp_InvID));

-- Employee Reimbursement table
CREATE TABLE IF NOT EXISTS Employee_Reimbursement
(Reimbursement_ID INT UNIQUE NOT NULL AUTO_INCREMENT,
Reimbursement_Amount Float NOT NULL,
Reimbursement_Status VARCHAR(50) DEFAULT 'Assigned',
PRIMARY KEY (Reimbursement_ID),
Exp_InvID INT,
FOREIGN KEY (Exp_InvID) REFERENCES Employee_Expense(Exp_InvID));


-- Employee reimbursement_audit table
CREATE TABLE IF NOT EXISTS reimbursement_audit (
  id INT AUTO_INCREMENT PRIMARY KEY,
  Exp_InvID INT NOT NULL,
  Reimbursement_ID INT NOT NULL,
  changedat DATETIME DEFAULT NULL,
  action VARCHAR(50) DEFAULT NULL,
  CONSTRAINT Employee_Reimbursement_FK1 FOREIGN KEY (Reimbursement_ID)
REFERENCES Employee_Reimbursement (Reimbursement_ID));

SHOW TABLES;

-- Stored Functions
-- To Calculate the total expenses for all categories
DELIMITER $$
CREATE FUNCTION GetTotalExpenses(
      Expense_Invoice INT
)
RETURNS DECIMAL(10,2)
DETERMINISTIC -- Used to get same value everytime this function is executed.
BEGIN
     DECLARE Total_Amount DECIMAL(10,2);
     SELECT SUM(Amount)
           INTO Total_Amount 
           FROM Expense_Invoice
		WHERE Exp_InvID = Expense_Invoice
        GROUP BY Exp_InvID;
        
     RETURN (Total_Amount);
END $$
DELIMITER ;

-- Categorize the Employee into Frequent and Normal Traveller
DELIMITER $$
CREATE FUNCTION Frequent_Traveller(
      EmpID INT
)
RETURNS VARCHAR(50)
DETERMINISTIC -- Used to get same value everytime this function is executed.
BEGIN
     DECLARE Total_Trips INT;
	 DECLARE Traveler_Type VARCHAR(50);
     SELECT COUNT(*)
           INTO Total_Trips 
           FROM EmployeesTravelLog AS ETL
		WHERE ETL.EmpID = EmpID;
	IF Total_Trips <> 0 THEN
	IF Total_Trips < 3 THEN
	    SET Traveler_Type = 'Non-Frequent Traveler';
	ELSE
	    SET Traveler_Type = 'Frequent Traveler';
	END IF;
	END IF;
        
     RETURN (Traveler_Type);
END $$
DELIMITER ;

-- Stored Procedures
-- Company Travel Policy
DELIMITER //
CREATE PROCEDURE CompanyTravelPolicy( 
IN RequestID INT
)
BEGIN
DECLARE Status VARCHAR(15) DEFAULT 'Assigned';
DECLARE daysforapproval INT DEFAULT 0;
SELECT 
    DATEDIFF(TR.DepartDate, TR.Submitted_Date)
INTO daysforapproval FROM
    Travel_Requests TR
WHERE
    TR.RequestID = RequestID;
    IF daysforapproval > 15 THEN
       SET Status = 'Approved';
	ELSE
       SET Status = 'Rejected';
    END IF;
-- SET SQL_SAFE_UPDATES = 0;
UPDATE Travel_requests TR
SET 
    Request_Status = Status
WHERE
    TR.RequestID = RequestID;
UPDATE TravelApproval TA 
SET 
    actionStatus = Status
WHERE
    TA.RequestID = RequestID;
END //
DELIMITER ;

-- To calculate reimbursement of employee and insert details into reimbursement table
DELIMITER //
CREATE PROCEDURE CalculateReimbursement(
       Exp_InvID INT
)
BEGIN
   INSERT INTO Employee_Reimbursement (Reimbursement_Amount, Exp_InvID)
   SELECT GetTotalExpenses(Exp_InvID), EI.Exp_InvID
        FROM Expense_Invoice EI
    WHERE EI.Exp_InvID = Exp_InvID 
    GROUP BY EI.Exp_InvID;
END //
DELIMITER ;

-- To approve the reimbursement of employee
DELIMITER //
CREATE PROCEDURE Reimbursement_Approval(
    IN Exp_InvID INT
)
BEGIN
DECLARE S1, S2, S3 VARCHAR(50) DEFAULT 1;
DECLARE C1, C2, C3 VARCHAR(50) DEFAULT 'Miscellaneous';
DECLARE Amount1,Amount2,Amount3 FLOAT DEFAULT 0;

SELECT EI.Amount, EI.ExpenseCategory
INTO Amount1, C1
FROM expense_invoice EI
WHERE EI.Exp_InvID = Exp_InvID
AND EI.ExpenseCategory IN ('Accomodation');

SELECT EI.Amount, EI.ExpenseCategory
INTO Amount2, C2
FROM expense_invoice EI
WHERE EI.Exp_InvID = Exp_InvID
AND EI.ExpenseCategory IN ('Flight');

SELECT EI.Amount, EI.ExpenseCategory
INTO Amount3, C3
FROM expense_invoice EI
WHERE EI.Exp_InvID = Exp_InvID
AND EI.ExpenseCategory IN ('Miscellaneous');

IF (Amount1 <= 1000 and C1 ='Accomodation') AND (Amount2 <= 3000 and C2 ='Flight') AND (Amount3 <= 200 and C3 ='Miscellaneous') THEN
SET SQL_SAFE_UPDATES = 0;
UPDATE Employee_Reimbursement ER
SET Reimbursement_Status = 'Approved'
WHERE ER.Exp_InvID = Exp_InvID;
ELSE 
SET SQL_SAFE_UPDATES = 0;
UPDATE Employee_Reimbursement ER
SET Reimbursement_Status = 'Rejected'
WHERE ER.Exp_InvID = Exp_InvID;
END IF;
END //
DELIMITER ;

-- TRIGGERS
-- Add a trigger to insert values into TravelApproval table once a Travel request is raised.
DELIMITER $$
CREATE TRIGGER travel_approval_worflow
AFTER INSERT ON Travel_Requests FOR EACH ROW
BEGIN
IF NEW.Request_Status LIKE '%Assigned%' THEN
      INSERT INTO TravelApproval (RequestID, EmployeeID, EmpName, ParticipantApprover, actionStatus)
	  SELECT Travel_Requests.RequestID, Travel_Requests.EmployeeID, CONCAT(EmpFirstName, '', EmpLastName),
      ReportsTo, Request_Status
      FROM Travel_requests
      INNER JOIN Employees
      ON Travel_requests.EmployeeID = Employees.EmployeeID
      WHERE Travel_requests.RequestID = NEW.RequestID;
      END IF;
END $$
DELIMITER ;

-- To capture changes in reimbursement_status
CREATE TRIGGER after_reimbursement_update
    AFTER UPDATE ON Employee_Reimbursement
    FOR EACH ROW
INSERT INTO reimbursement_audit
SET action = NEW.reimbursement_status,
    Exp_InvID = OLD.Exp_InvID,
    Reimbursement_ID = OLD.Reimbursement_ID,  
    changedat = NOW();

-- Data loading into Employees
INSERT INTO Employees (EmployeeID, EmpFirstName, EmpLastName, hiredate, dept_name, designation, ReportsTo)
VALUES
(1001, 'Anee', 'Patterson', '2017-07-19', 'Development', 'Software Developer', 'Alex Cose'),
(1002, 'Jeremy', 'Walker', '2021-11-09', 'Design', 'UX Design', 'Judy Williams'),
(1003, 'Alex', 'Cose', '2013-05-12', 'Development', 'Senior Manager', 'Tom Smith'),
(1004, 'Judy', 'Williams', '2009-10-21', 'Design', 'Lead Designer', 'Tom Smith'),
(1005, 'Alan', 'Johnson', '2008-08-08', 'Human Resources', 'Senior Manager HR', 'Liu Han'),
(1006, 'Tony', 'Stark', '1980-12-17', 'Development', 'Software Developer', 'Kim Jarvis'),
(1007, 'Tim', 'Adolf', '1981-02-20', 'Design', 'UX Design', 'Sam Miles'),
(1008, 'Kim', 'Jarvis', '1981-09-28', 'Development', 'Senior Manager', 'Kevin Hill'),
(1009, 'Sam', 'Miles', '1996-07-01', 'Design', 'Lead Designer', 'Kevin Hill'),
(1010, 'Kevin', 'Hill', '1992-06-21', 'Human Resources', 'Senior Manager HR', 'Liu Han'),
(1011, 'Connie', 'Smith', '1992-12-09', 'Development', 'Software Developer', 'Pual Timothy'),
(1012, 'Alfred', 'Kinsley', '2000-11-17', 'Design', 'UX Design', 'John Connor'),
(1013, 'Paul', 'Timothy', '2010-09-08', 'Development', 'Senior Manager', 'Rose Summers'),
(1014, 'John', 'Connor', '1983-01-12', 'Design', 'Lead Designer', 'Rose Summers'),
(1015, 'Rose', 'Summers', '1999-12-03', 'Human Resources', 'Senior Manager HR', 'Liu Han'),
(1016, 'Andrew', 'Smith', '2007-02-22', 'Development', 'Software Developer', 'Wendy Shwan'),
(1017, 'Karen', 'Mathew', '2010-05-01', 'Design', 'UX Design', 'Madii Himburry'),
(1018, 'Wendy', 'Shawn', '1998-05-01', 'Development', 'Senior Manager', 'Athena Wilson'),
(1019, 'Madii', 'Himburry', '2001-06-21', 'Design', 'Lead Designer', 'Athena Wilson'),
(1020, 'Athena', 'Wilson', '2013-07-01', 'Human Resources', 'Senior Manager HR', 'Samuel Jackson'),
(1021, 'Jennifer', 'Lawrence', '2007-07-02', 'Development', 'Software Developer', 'Chris Hemsworth'),
(1022, 'Scarlet', 'Johanson', '2001-03-10', 'Design', 'UX Design', 'Peter Parker'),
(1023, 'Chris', 'Hemsworth', '2012-05-05', 'Development', 'Senior Manager', 'Bruce Banner'),
(1024, 'Peter', 'Parker', '2017-11-11', 'Design', 'Lead Designer', 'Tony Stark'),
(1025, 'Bruce', 'Banner', '2008-09-09', 'Human Resources', 'Senior Manager HR', 'Chris Evans');

-- Data loading into Travel Requests
INSERT INTO Travel_Requests (EmployeeID, TravelType, LeavingFrom, GoingTo, DepartDate, ReturnDate,
PurposeofTravel,TransportType, ServiceClass, HotelType, CostEstimate, Submitted_Date)
VALUES
(1001, 'Domestic', 'Dallas', 'Austin', '2022-11-19', '2022-11-21', 'Conference', 'Flight', 'Economy', '3-Star', 1000, '2022-11-02'),
(1001, 'Domestic', 'Austin', 'Dallas', '2022-05-03', '2022-05-11', 'Client Negotiation', 'Flight', 'Economy', '3-Star', 1000, '2022-04-23'),
(1002, 'Domestic', 'SanFransisco', 'Austin', '2020-09-08', '2020-09-17', 'Conference', 'Flight', 'Business', '5-Star', 3000, '2020-08-22'),
(1002, 'International', 'SanFransisco', 'New Delhi', '2020-10-17', '2020-10-27', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2020-10-02'),
(1003, 'International', 'New York', 'London', '2020-09-08', '2020-09-17', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2020-08-23'),
(1004, 'International', 'SanFransisco', 'Nepal', '2021-10-01', '2021-10-03', 'Client Negotiation', 'Flight', 'Business', '5-Star', 5000, '2021-09-18'),
(1004, 'International', 'Berlin', 'New Delhi', '2021-10-03', '2021-10-17', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2021-09-16'),
(1005, 'Domestic', 'SanFransisco', 'Austin', '2020-09-08', '2020-09-17', 'Conference', 'Flight', 'Business', '5-Star', 3000, '2020-09-02'),
(1005, 'International', 'Austin', 'Berlin', '2020-10-03', '2020-10-10', 'Client Negotiation', 'Flight', 'Business', '5-Star', 5000, '2020-09-18'),
(1006, 'International', 'Sydney', 'Bali', '2010-10-10', '2010-10-21', 'Conference', 'Flight', 'Economy', '3-Star', 3000, '2010-09-24'),
(1007, 'International', 'Paris', 'Dubai', '2018-08-15', '2018-08-25', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2018-08-01'),
(1007, 'Domestic', 'Dubai', 'Abhu Dhabi', '2021-01-02', '2021-02-03', 'Conference', 'Flight', 'Business', '5-Star', 3000, '2020-12-14'),
(1008, 'Domestic', 'New York', 'Atlanta', '2019-07-01', '2019-07-30', 'Onsite Work', 'Flight', 'Business', '5-Star', 3000, '2019-06-12'),
(1009, 'International', 'California', 'Tokyo', '2018-03-01', '2018-03-10', 'Client Negotiation', 'Flight', 'Business', '5-Star', 5000, '2018-02-12'),
(1009, 'International', 'Tokyo', 'Los Angeles', '2018-03-10', '2018-03-22', 'Conference', 'Flight', 'Business', '5-Star', 5000, '2018-03-01'),
(1010, 'Domestic', 'Boston', 'Connecticut', '2022-04-08', '2022-04-17', 'Conference', 'Flight', 'Business', '5-Star', 3000, '2022-03-23'),
(1010, 'Domestic', 'Connecticut', 'Phoenix', '2022-04-19', '2022-05-21', 'Conference', 'Flight', 'Economy', '3-Star', 1000, '2022-04-02'),
(1010, 'International', 'Phoenix', 'Mumbai', '2010-06-06', '2010-06-17', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2010-05-18'),
(1010, 'International', 'Mumbai', 'Bali', '2010-06-19', '2010-07-17', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2010-06-03'),
(1011, 'International', 'New York', 'Vancouver', '2020-09-08', '2020-09-17', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2020-09-01'),
(1011, 'Domestic', 'Vancouver', 'Toronto', '2022-11-19', '2022-11-25', 'Conference', 'Flight', 'Economy', '3-Star', 1000, '2022-10-28'),
(1012, 'Domestic', 'Dallas', 'Austin', '2022-11-19', '2022-11-21', 'Conference', 'Flight', 'Economy', '3-Star', 1000, '2022-11-04'),
(1013, 'International', 'Singapore', 'New Delhi', '2021-09-07', '2021-09-29', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2021-08-16'),
(1014, 'International', 'Providencia', 'Seoul', '2018-10-01', '2018-10-03', 'Client Negotiation', 'Flight', 'Business', '5-Star', 5000, '2018-09-14'),
(1014, 'International', 'Lisbon', 'New York', '2020-02-10', '2020-02-26', 'Onsite Work', 'Flight', 'Business', '5-Star', 5000, '2020-02-06'),
(1015, 'International', 'Chicago', 'Cairo', '2021-10-01', '2021-10-03', 'Client Negotiation', 'Flight', 'Business', '5-Star', 5000, '2021-09-08'),
(1015, 'Domestic', 'Boston', 'Houston', '2020-11-26', '2020-11-30', 'Conference', 'Flight', 'Business', '5-Star', 3000, '2020-11-10');

-- Data loading into preferred_airlines
INSERT INTO preferred_airlines (flight_no, airline_name, terminal,
to_airport, service_class, ticket_cost)
VALUES
('A0001', 'Spirit', 'Dallas/Fort Worth International Airport','Austin-Bergstrom International Airport','Economy', 1000),
('A0002', 'Spirit', 'Austin-Bergstrom International Airport','Dallas/Fort Worth International Airport','Economy', 1000),
('B0001', 'Emirates', 'San Francisco International Airport','Austin-Bergstrom International Airport','Business', 3000),
('B0002', 'Emirates', 'San Francisco International Airport','Indira Gandhi International Airport','Business', 3000),
('C0001', 'Gulf', 'John F. Kennedy International Airport','Heathrow Airport','Business', 3000),
('D0001', 'Emirates', 'San Francisco International Airport','Tribhuvan International Airport', 'Business',3000),
('E0001', 'United Airlines', 'Berlin Brandenburg Airport,','Indira Gandhi International Airport','Business', 3000),
('F0001', 'Spirit', 'San Francisco International Airport','Austin-Bergstrom International Airport','Business', 3000),
('G0001', 'Emirates', 'Austin-Bergstrom International Airport','Berlin Brandenburg Airport','Business', 3000),
('H0001', 'Gulf', 'Sydney Airport','Ngurah Rai International Airport','Economy', 1000),
('I0001', 'Emirates', 'Paris Charles de Gaulle Airport','Dubai International Airport','Business', 3000),
('J0001', 'United Airlines', 'Dubai International Airport','Abu Dhabi International Airport','Business', 3000),
('K0001', 'Spirit', 'John F. Kennedy International Airport','Hartsfield-Jackson Atlanta International Airport','Business', 3000),
('L0001', 'Emirates', '    Los Angeles International Airport','Haneda Airport','Business', 3000),
('M0001', 'Gulf', 'Boston Logan International Airport','Bradley International Airport','Business', 3000),
('N0001', 'Emirates', 'Bradley International Airport','Phoenix Sky Harbor International Airport','Business', 3000),
('O0001', 'United Airlines', 'Phoenix Sky Harbor International Airport','Chhatrapati Shivaji Maharaj International Airport','Economy', 1000),
('P0001', 'Spirit', 'Chhatrapati Shivaji Maharaj International Airport','Ngurah Rai International Airport','Business', 3000),
('Q0001', 'Emirates', 'John F. Kennedy International Airport','Vancouver International Airport','Business', 3000),
('R0001', 'Gulf', 'Vancouver International Airport','Toronto Pearson International Airport','Business', 3000),
('S0001', 'Emirates', 'Dallas/Fort Worth International Airport','Austin-Bergstrom International Airport','Economy', 1000),
('T0001', 'United Airlines', 'Singapore Changi Airport','Indira Gandhi International Airport','Economy', 3000),
('U0001', 'Spirit', 'Providenciales International Airport (PLS)','Incheon International Airport','Business', 3000),
('V0001', 'Emirates', 'Humberto Delgado Airport','John F. Kennedy International Airport','Business', 3000),
('W0001', 'Gulf', 'OHare International Airport','Cairo International Airport','Business', 3000),
('X0001', 'Emirates', 'Boston Logan International Airport','George Bush Intercontinental Airport','Business', 3000);

-- Data loading into Booking_Details
INSERT INTO Booking_details (flight_no, EmployeeCode, Destination, TravelDate, ReturnDate,
BookingDate, Travel_Class, Carrier, Terminal, Travel_Cost)
VALUES
('A0001', '1001', 'Austin', '2022-11-19', '2022-11-21', '2022-11-10','Economy', 'Spirit', 'Austin-Bergstrom International Airport', 1000),
('B0001', '1002', 'Austin', '2020-09-08', '2020-09-17', '2020-09-03', 'Business', 'Emirates', 'Austin-Bergstrom International Airport', 3000),
('C0001', '1003', 'London', '2020-09-08', '2020-09-17', '2020-09-02', 'Business', 'Gulf', 'Heathrow Airport', 3000),
('E0001', '1004', 'New Delhi', '2021-10-03', '2021-10-17', '2021-10-01', 'Business', 'United Airline','Indira Gandhi International Airport', 3000),
('H0001', '1006', 'Bali', '2010-10-10', '2010-10-21', '2022-10-04','Economy', 'Gulf', 'Ngurah Rai International Airport', 1000),
('J0001', '1007', 'Abhu Dhabi', '2021-01-02', '2021-02-03', '2021-01-01', 'Business', 'United Airlines', 'Abu Dhabi International Airport', 3000),
('K0001', '1008', 'Atlanta', '2019-07-01', '2019-07-30', '2020-06-26', 'Business', 'Spirit', 'Hartsfield-Jackson Atlanta International Airport', 3000),
('L0001', '1009', 'Tokyo', '2018-03-01', '2018-03-10', '2021-02-25', 'Business', 'Emirates', 'Haneda Airport', 3000),
('M0001', '1010', 'Connecticut', '2022-04-08', '2022-04-17', '2022-04-03', 'Business', 'Gulf', 'Bradley International Airport', 2000),
('N0001', '1010', 'Phoenix', '2022-04-19', '2022-05-21', '2022-04-15','Economy', 'Emirates', 'Phoenix Sky Harbor International Airport', 1000),
('O0001', '1010', 'Mumbai', '2010-06-06', '2010-06-17', '2010-05-28', 'Business', 'United Airlines', 'Chhatrapati Shivaji Maharaj International Airport', 4000),
('P0001', '1010', 'Bali', '    2010-06-19', '2010-07-17', '2010-06-12', 'Business', 'Spirit', 'Ngurah Rai International Airport', 3000),
('R0001', '1011', 'Toronto', '2022-11-19', '2022-11-25', '2022-11-10', 'Economy', 'Gulf', 'Toronto Pearson International Airport', 1000),
('T0001', '1013', 'New Delhi', '2021-09-07', '2021-09-29', '2021-09-01', 'Business', 'United Airlines', 'Indira Gandhi International Airport', 3000),
('U0001', '1014', 'Seoul', '2018-10-01', '2018-10-03', '2018-09-26', 'Business', 'Spirit', 'Incheon International Airport', 3000),
('W0001', '1015', 'Cairo', '2021-10-01', '2021-10-03', '2021-09-28', 'Business', 'Gulf', 'Cairo International Airport', 3000),
('X0001', '1015', 'Houston', '2020-11-26', '2020-11-30', '2020-09-01', 'Business', 'Emirates', 'George Bush Intercontinental Airport', 3000);

-- Data loading into service_on_airlines
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO service_on_airlines (s_on_flight_no, s_on_BookingID)
VALUES ('A0001','1001'),('B0001','1002'),('C0001','1003'),('E0001','1004'),('H0001','1005'),('J0001','1006'),('K0001','1007'),('L0001','1008'),('M0001','1009'),
('N0001','1010'),('O0001','1011'),('P0001','1012'),('R0001','1013'),('T0001','1014'),('U0001','1015'),('W0001','1016'),('X0001','1017');
SET FOREIGN_KEY_CHECKS=1;
-- Data loading into preferred_accomdation
INSERT INTO preferred_accommdation (accom_type, accom_name, location)
VALUES ('Hotel', 'Novotel', 'Austin'), 
('Air BnB', 'Paradise', 'New Delhi'), 
('Hotel', 'JW Marriot', 'London'),
('Air BnB', 'Oasis', 'Berlin'),
('Apartment', 'Estate of Richardson', 'Austin'),
('Hotel', 'Hilton', 'Austin'),
('Hotel', 'RadissonBlu', 'New Delhi'),
('Hotel', 'Hilton', 'London'),
('Air BnB', 'Palm Springs', 'Berlin'),
('Hotel', 'Ramada', 'Berlin'),
('Hotel', 'Novotel', 'Austin'),
('Air BnB', 'Paradise', 'New Delhi'),
('Hotel', 'JW Marriot', 'London'),
('Air BnB', 'Oasis', 'Berlin'),
('Apartment', 'Estate of Richardson', 'Austin'),
('Hotel', 'Novotel', 'Austin'),
('Air BnB', 'Paradise', 'New Delhi'),
('Hotel', 'JW Marriot', 'London'),
('Air BnB', 'Mitra', 'New Delhi'),
('Apartment', 'Estate of Frankford', 'Austin'),
('Hotel', 'MM Suites', 'Austin'),
('Hotel', 'Hyatt', 'New Delhi'),
('Hotel', 'DoubleTree', 'London'),
('Hotel', 'Adlon', 'Berlin'),
('Hotel', 'Indigo', 'Austin');

-- Data Loading into accommodation
INSERT INTO Accommodation (EmpCode, Cust_Name, room_no, AccomName, AccomType, CheckIn, CheckOut, AccomCost)
VALUES
(1001,'Anne Patterson', 101, 'Novotel', 'Hotel', '2022-11-19', '2022-11-21', 1000),
(1002,'Jeremy Walker', 201, 'Paradise', 'Air BnB', '2020-09-08', '2020-09-17', 800),
(1003,'Alex Cose', 301, 'JW Marriot', 'Hotel', '2020-09-08', '2020-09-17', 2000),
(1004,'Judy Williams', 401, 'Oasis', 'Air BnB', '2021-10-03', '2021-10-17', 800),
(1007,'Tim Adolf ', 501, 'Estate of Richardson', 'Apartment', '2010-10-10', '2010-10-21', 600),
(1008,'Kim Jarvis', 101, 'Novotel', 'Hotel', '2021-01-02', '2021-02-03', 1000),
(1009,'Sam Miles', 201, 'Paradise', 'Air BnB', '2019-07-01', '2019-07-30', 800),
(1010,'Kevin Hill', 301, 'JW Marriot', 'Hotel', '2018-03-01', '2018-03-10', 2000),
(1010,'Kevin Hill', 401, 'Oasis', 'Air BnB', '2022-04-08', '2022-04-17', 800),
(1010,'Kevin Hill', 501, 'Estate of Richardson', 'Apartment', '2022-04-19', '2022-05-21', 600),
(1010,'Kevin Hill', 101, 'Novotel', 'Hotel', '2010-06-06', '2010-06-17', 1000),
(1013,'Connie Smith ', 201, 'Paradise', 'Air BnB', '2010-06-19', '2010-07-17', 800),
(1013,'Paul Timothy', 301, 'JW Marriot', 'Hotel', '2022-11-19', '2022-11-25', 2000),
(1014,'John Connor', 401, 'Oasis', 'Air BnB', '2021-09-07', '2021-09-29', 800),
(1015,'Rose Summers', 501, 'Estate of Richardson', 'Apartment', '2018-10-01', '2018-10-03', 600),
(1015,'Rose Summers', 101, 'Novotel', 'Hotel', '2021-10-01', '2021-10-03', 1000);

-- Data loading into service_on_accomodation
SET FOREIGN_KEY_CHECKS=0;
INSERT INTO service_on_accomodation (s_on_accom_ID, s_on_BookingID)
VALUES
('1234','1001'),('1235','1002'),('1236','1003'),('1237','1004'),('1238','1005'),
('1239','1007'),('1240','1008'),('1241','1009'),('1242','1010'),('1243','1011'),
('1244','1012'),('1245','1012'),('1246','1013'),('1247','1014'),
('1248','1015'),('1249','1016'),('1250','1017');
SET FOREIGN_KEY_CHECKS=1;

-- Data Loading into Employees Travel Log table
INSERT INTO EmployeesTravelLog(EmpID, EmpFirstName, EmpLastName, Place, Purpose, TravelDate)
VALUES
(1001, 'Anee', 'Patterson', 'Austin', 'Conference', '2022-11-19'),
(1002, 'Jeremy', 'Walker', 'New Delhi', 'Onsite Work', '2020-09-08'),
(1003, 'Alex', 'Cose', 'London', 'Onsite Work', '2020-09-08'),
(1004, 'Judy', 'Williams', 'Berlin', 'Client Negotiation', '2021-10-01'),
(1006, 'Tony', 'Stark', 'Bali', 'Conference', '2010-10-10'),
(1007, 'Tim', 'Adolf', 'Abhu Dhabi', 'Conference', '2021-01-02'),
(1008, 'Kim', 'Jarvis', 'Atlanta', 'Onsite Work', '2019-07-01'),
(1009, 'Sam', 'Miles', 'Tokyo', 'Client Negotiation', '2018-03-01'),
(1010, 'Kevin', 'Hill', 'Connecticut', 'Conference', '2022-04-08'),
(1010, 'Kevin', 'Hill', 'Phoenix', 'Conference', '2022-04-19'),
(1010, 'Kevin', 'Hill', 'Mumbai', 'Onsite Work', '2010-06-06'),
(1010, 'Kevin', 'Hill', 'Bali', 'Onsite Work', '2010-06-19'),
(1011, 'Connie', 'Smith', 'Toronto', 'Conference', '2022-11-19'),
(1013, 'Paul', 'Timothy', 'New Delhi', 'Onsite Work', '2021-09-07'),
(1014, 'John', 'Connor', 'Seoul', 'Client Negotiation', '2018-10-01'),
(1015, 'Rose', 'Summers', 'Cairo', 'Client Negotiation', '2021-10-01'),
(1015, 'Rose', 'Summers', 'Houston', 'Conference', '2020-11-26');

-- Data Loading into Employee_Expense

INSERT INTO Employee_Expense(EmpID, Exp_InvID, EmpName, from_Date, to_Date, Submitted_by)
VALUES
(1001, 901,'Anne Patterson', '2022-11-19', '2022-11-21', '2022-11-25'),
(1002, 902, 'Jeremy Walker', '2020-09-08', '2020-09-17', '020-09-26'),
(1003, 903, 'Alex Cose', '2020-09-08', '2020-09-17', '2020-09-28'),
(1004, 904, 'Judy Williams', '2021-10-01', '2021-10-03', '2021-10-08'),
(1006, 905, 'Tony Stark', '2010-10-10', '2010-10-21', '2010-10-28'),
(1007, 906, 'Tim Adolf', '2021-01-02', '2021-02-03', '2021-02-10'),
(1008, 907, 'Kim Jarvis', '2019-07-01', '2019-07-30', '2019-08-09'),
(1009, 908, 'Sam Miles', '2018-03-01', '2018-03-10', '2018-03-16'),
(1010, 909, 'Kevin Hill', '2022-04-08', '2022-04-17', '2022-04-30'),
(1010, 910, 'Kevin Hill', '2022-04-19', '2022-05-21', '2022-05-28'),
(1010, 911, 'Kevin Hill', '2010-06-06', '2010-06-17', '2010-06-27'),
(1010, 912, 'Kevin Hill', '2010-06-19', '2010-07-17', '2010-07-24'),
(1011, 913, 'Connie Smith', '2022-11-19', '2022-11-25', '2022-12-02'),
(1013, 914, 'Paul Timothy', '2021-09-07', '2021-09-29', '2021-10-05'),
(1014, 915, 'John Connor', '2018-10-01', '2018-10-03', '2018-10-07'),
(1015, 916, 'Rose Summers', '2021-10-01', '2021-10-03', '2021-10-11'),
(1015, 917, 'Rose Summers', '2020-11-26', '2020-11-30', '2020-12-06');

-- Data Loading into Employee Invoice
INSERT INTO Expense_Invoice (Exp_InvID, SubmittedBy, EmpFName, EmpLName, ExpenseDesc, ExpenseCategory, Amount, SubmissionDate)
VALUES
('901', '1001', 'Anne', 'Patterson', 'Transportation', 'Flight', '1000','2022-11-25'),
('901', '1001', 'Anne', 'Patterson', 'Hotel Expense','Accomodation', '1000','2022-11-25'),
('901', '1001', 'Anne', 'Patterson', 'Cab', 'Miscellaneous', '200','2022-11-25'),
('902', '1002', 'Jeremy', 'Walker', 'Transportation', 'Flight', '3000','2020-09-26'),
('902', '1002', 'Jeremy', 'Walker', 'Hotel Expense', 'Accomodation', '800','2020-09-26'),
('902', '1002', 'Jeremy', 'Walker', 'Food', 'Miscellaneous', '100','2020-09-26'),
('903', '1003', 'Alex', 'Cose', 'Conference', 'Flight', '3000','2020-09-28'),
('903', '1003', 'Alex', 'Cose', 'Onsite Work', 'Accomodation', '2000','2020-09-28'),
('903', '1003', 'Alex', 'Cose', 'Onsite Work', 'Miscellaneous' , '50','2020-09-28'),
('904', '1004', 'Judy', 'Williams', 'Transportation', 'Flight' , '3000','2021-10-08'),
('904', '1004', 'Judy', 'Williams', 'Hotel expense', 'Accomodation' , '800','2021-10-08'),
('904', '1004', 'Judy', 'Williams', 'Health', 'Miscellaneous', '500','2021-10-08'),
('905', '1006', 'Tony', 'Stark', 'Transportation', 'Flight', '1000','2021-10-08'),
('905', '1006', 'Tony', 'Stark', 'Hotel expense', 'Accomodation','2000','2021-10-08'),
('905', '1006', 'Tony', 'Stark', 'Business Tools', 'Miscellaneous', '150','2010-10-28'),
('906', '1007', 'Tim', 'Adolf', 'Transportation', 'Flight','3000', '2021-02-10'),
('906', '1007', 'Tim', 'Adolf', 'Hotel expense', 'Accomodation', '1000','2021-02-10'),
('906', '1007', 'Tim', 'Adolf', 'Food', 'Miscellaneous', '80','2021-02-10'),
('907', '1008', 'Kim', 'Jarvis', 'Transportation', 'Flight' , '3000','2019-08-09'),
('907', '1008', 'Kim', 'Jarvis', 'Hotel expense', 'Accomodation' , '800','2019-08-09'),
('907', '1008', 'Kim', 'Jarvis', 'Cab', 'Miscellaneous' , '120','2019-08-09'),
('908', '1009', 'Sam', 'Miles', 'Transportation', 'Flight', '3000','2018-03-16'),
('908', '1009', 'Sam', 'Miles', 'Hotel expense', 'Accomodation', '2000','2018-03-16'),
('908', '1009', 'Sam', 'Miles', 'Food', 'Miscellaneous','200','2018-03-16'),
('909', '1010', 'Kevin', 'Hill', 'Transportation', 'Flight', '2000','2022-04-30'),
('909', '1010', 'Kevin', 'Hill', 'Hotel expense', 'Accomodation','800', '2022-04-30'),
('909', '1010', 'Kevin', 'Hill', 'Food', 'Miscellaneous', '45','2022-04-30'),
('910', '1010', 'Kevin', 'Hill', 'Transportation', 'Flight', '1000','2022-05-28'),
('910', '1010', 'Kevin', 'Hill', 'Hotel expense', 'Accomodation','600', '2022-05-28'),
('910', '1010', 'Kevin', 'Hill', 'Cab', 'Miscellaneous', '90','2022-05-28'),
('911', '1010', 'Kevin', 'Hill', 'Transportation', 'Flight', '4000','2010-06-27'),
('911', '1010', 'Kevin', 'Hill', 'Hotel expense', 'Accomodation','1000', '2010-06-27'),
('911', '1010', 'Kevin', 'Hill', 'Food', 'Miscellaneous', '170','2010-06-27'),
('912', '1010', 'Kevin', 'Hill', 'Transportation', 'Flight', '3000','2010-07-24'),
('912', '1010', 'Kevin', 'Hill', 'Hotel expense', 'Accomodation','800', '2010-07-24'),
('912', '1010', 'Kevin', 'Hill', 'Health', 'Miscellaneous', '300','2010-07-24'),
('913', '1011', 'Connie', 'Smith', 'Transportation', 'Flight', '1000','2022-12-02'),
('913', '1011', 'Connie', 'Smith', 'Hotel expense', 'Accomodation','2000', '2022-12-02'),
('913', '1011', 'Connie', 'Smith', 'Food', 'Miscellaneous', '220','2022-12-02'),
('914', '1013', 'Paul', 'Timothy', 'Transportation', 'Flight', '3000','2021-10-05'),
('914', '1013', 'Paul', 'Timothy', 'Hotel expense', 'Accomodation','800', '2021-10-05'),
('914', '1013', 'Paul', 'Timothy', 'Cab', 'Miscellaneous', '190','2021-10-05'),
('915', '1014', 'John', 'Connor', 'Transportation', 'Flight', '3000','2018-10-07'),
('915', '1014', 'John', 'Connor', 'Hotel expense', 'Accomodation','600', '2018-10-07'),
('915', '1014', 'John', 'Connor', 'Food', 'Miscellaneous', '170','2018-10-07'),
('916', '1015', 'Rose', 'Summers', 'Transportation', 'Flight', '3000','2021-10-11'),
('916', '1015', 'Rose', 'Summers', 'Hotel expense', 'Accomodation','1000', '2021-10-11'),
('916', '1015', 'Rose', 'Summers', 'Food', 'Miscellaneous', '280','2021-10-11'),
('917', '1015', 'Rose', 'Summers', 'Transportation', 'Flight', '3000','2020-12-06'),
('917', '1015', 'Rose', 'Summers', 'Hotel expense', 'Accomodation','1000', '2020-12-06'),
('917', '1015', 'Rose', 'Summers', 'Cab', 'Miscellaneous', '300','2020-12-06');

-- Calling CompanyTravelPolicy()
CALL CompanyTravelPolicy(1111);
CALL CompanyTravelPolicy(1112);
CALL CompanyTravelPolicy(1113);
CALL CompanyTravelPolicy(1114);
CALL CompanyTravelPolicy(1115);
CALL CompanyTravelPolicy(1116);
CALL CompanyTravelPolicy(1117);
CALL CompanyTravelPolicy(1118);
CALL CompanyTravelPolicy(1119);
CALL CompanyTravelPolicy(1120);
CALL CompanyTravelPolicy(1121);
CALL CompanyTravelPolicy(1122);
CALL CompanyTravelPolicy(1123);
CALL CompanyTravelPolicy(1124);
CALL CompanyTravelPolicy(1125);
CALL CompanyTravelPolicy(1126);
CALL CompanyTravelPolicy(1127);
CALL CompanyTravelPolicy(1128);
CALL CompanyTravelPolicy(1129);
CALL CompanyTravelPolicy(1130);
CALL CompanyTravelPolicy(1131);
CALL CompanyTravelPolicy(1132);
CALL CompanyTravelPolicy(1133);
CALL CompanyTravelPolicy(1134);
CALL CompanyTravelPolicy(1135);
CALL CompanyTravelPolicy(1136);
CALL CompanyTravelPolicy(1137);

CALL CalculateReimbursement(901);
CALL CalculateReimbursement(902);
CALL CalculateReimbursement(903);
CALL CalculateReimbursement(903);
CALL CalculateReimbursement(904);
CALL CalculateReimbursement(905);
CALL CalculateReimbursement(906);
CALL CalculateReimbursement(907);
CALL CalculateReimbursement(908);
CALL CalculateReimbursement(909);
CALL CalculateReimbursement(910);
CALL CalculateReimbursement(911);
CALL CalculateReimbursement(912);
CALL CalculateReimbursement(913);
CALL CalculateReimbursement(914);
CALL CalculateReimbursement(915);
CALL CalculateReimbursement(916);
CALL CalculateReimbursement(917);

select * from Employee_Reimbursement;

CALL Reimbursement_Approval(901);
CALL Reimbursement_Approval(902);
CALL Reimbursement_Approval(903);
CALL Reimbursement_Approval(903);
CALL Reimbursement_Approval(904);
CALL Reimbursement_Approval(905);
CALL Reimbursement_Approval(906);
CALL Reimbursement_Approval(907);
CALL Reimbursement_Approval(908);
CALL Reimbursement_Approval(909);
CALL Reimbursement_Approval(910);
CALL Reimbursement_Approval(911);

select * from Reimbursement_audit;

-- Query to find out the top 5 employees with highest expense invoice generated and the invoice submitted dates for the same
-- Here we joined Employees(e) table on Employee_Expense(ee) and then joined Employee_Expense(ee) on Expense_Invoice(ei) table
SELECT e.EmpFirstName, e.EmpLastName, ei.Amount, ei.SubmissionDate
FROM Employees e
JOIN Employee_Expense ee ON e.EmployeeID = ee.EmpID
JOIN Expense_Invoice ei ON ee.Exp_InvID = ei.Exp_InvID
ORDER BY ei.amount DESC
LIMIT 5;

-- Query to find out the employees who went on a trip with most number of days along with the estimated and actual travel costs. We are
-- also interested to find out only those employees trip details where the actual travel cost doesn't deviate more than $1000 from estimated costs.
-- Here we joined Employees(e) table on Travel_Requests(tr) and then joined Travel_Requests(tr) on Booking_details(bd) table
-- The duration in days is calculated by subtracting travel date from return date as Trip_Duration_Days
SELECT DISTINCT e.EmployeeID,  e.EmpFirstName, e.EmpLastName, (bd.ReturnDate-bd.TravelDate) AS Trip_Duration_Days, tr.CostEstimate, bd.Travel_Cost
FROM Employees e
JOIN Travel_Requests tr ON e.EmployeeID = tr.EmployeeID
JOIN Booking_details bd ON tr.EmployeeID = bd.EmployeeCode
WHERE abs(tr.CostEstimate - bd.Travel_Cost) <= 1000
ORDER BY Trip_Duration_Days;

-- Employee with Maximum Reimbursement clamied 
select distinct Employees.EmployeeID, Employees.EmpFirstName, Employees.EmpLastName, Employees.ReportsTo,
Travel_Requests.PurposeofTravel,Travel_Requests.DepartDate ,Employee_Reimbursement.Reimbursement_Amount
from Employees join Travel_Requests
on Employees.EmployeeID  = Travel_Requests.EmployeeID
join Expense_Invoice
on Employees.EmployeeID = Expense_Invoice.SubmittedBy
join Employee_Expense
on Expense_Invoice.SubmittedBy = Employee_Expense.EmpID
join Employee_Reimbursement
on Employee_Expense.Exp_InvID = Employee_Reimbursement.Exp_InvID
where  Reimbursement_Amount = 
(
SELECT max(Reimbursement_Amount) FROM Employee_Reimbursement 
    WHERE  Reimbursement_Amount IN (
                       SELECT DISTINCT 
    Reimbursement_Amount FROM Employee_Reimbursement 
 ORDER BY Reimbursement_Amount DESC
)
);

-- The  SQL query will join the Employees, Travel_Requests, and preferred_airlines tables together and display the employee's first and last name,the travel type, and the Service class.
SELECT EmpFirstName, EmpLastName, TravelType, airline_name, service_class
FROM Employees
JOIN Travel_Requests ON Employees.EmployeeID = Travel_Requests.EmployeeID
JOIN preferred_airlines ON Travel_Requests.ServiceClass = preferred_airlines.service_class;

-- LEFT JOIN
-- Here using this query to find out employee travelling location and Travel type.
-- Join with Travel_Requests  and Employees 

SELECT  e.hiredate,t.TravelType,t.LeavingFrom,t.GoingTo,e.EmpFirstName,e.EmpLastName 
FROM Travel_Requests t  LEFT JOIN Employees e
ON e.EmployeeID=t.EmployeeID
WHERE e.dept_name='Design';

-- NESTED Queries:

-- Query to find out the employee who traveled for conference by using business class

SELECT * FROM Travel_Requests WHERE EmployeeID IN 
(SELECT EmployeeID FROM Employees WHERE PurposeofTravel in 
(SELECT Purpose from employeestravellog where Purpose Like 'Con%' and ServiceClass='Business'));

-- Retrieve all infomation of Employees where employees in Travel_Requests.

SELECT  * FROM  Employees WHERE EmployeeID 
IN(SELECT EmployeeID FROM Travel_Requests);

--  query to Retrieve flight_no,Destination,TravelDate,infomation of Airlines and if ticket Price is more than 3000.

SELECT  flight_no,Destination,TravelDate,Carrier,BookingID FROM  Booking_details WHERE 
flight_no IN(SELECT flight_no FROM preferred_airlines where airline_name like'Emirates%' and ticket_cost >=3000);


-- View to show the entire travel log of employees from pre-trip to post-trip
CREATE VIEW Travel_History_v AS
SELECT CONCAT(Employees.EmpFirstName,' ',Employees.EmpLastName) AS EmployeeName,
Employees.designation, Travel_Requests.GoingTo, Travel_Requests.PurposeofTravel,
Travel_Requests.Request_Status, Booking_details.flight_no,
Employee_Expense.Exp_InvID, Employee_Reimbursement.Reimbursement_Amount, 
Employee_Reimbursement.Reimbursement_Status
FROM Employees
INNER JOIN Travel_Requests ON 
Employees.EmployeeID = Travel_Requests.EmployeeID
INNER JOIN Booking_details ON 
Travel_Requests.EmployeeID = Booking_details.EmployeeCode
INNER JOIN Employee_Expense ON
Booking_details.EmployeeCode = Employee_Expense.EmpID
INNER JOIN Employee_Reimbursement ON 
Employee_Expense.Exp_InvID = Employee_Reimbursement.Exp_InvID;

SELECT * FROM Travel_History_v;