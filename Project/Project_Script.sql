
-- Section 6: SQL Script For Database Creation
-- ******************************************************************************************************************
CREATE DATABASE Rentrack;
USE Rentrack;

-- 1. VEHICLE
CREATE TABLE VEHICLE (
    VehicleID INT AUTO_INCREMENT PRIMARY KEY,
Type VARCHAR(255) NOT NULL CHECK (Type IN ('tourism', 'heavyweight', 'super heavyweight')),
    Brand VARCHAR(255) NOT NULL
);

-- 2. DRIVER
CREATE TABLE DRIVER (
    DriverID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(255) NOT NULL,
    LastName VARCHAR(255) NOT NULL,
DrivingLicenseType VARCHAR(255) NOT NULL CHECK (DrivingLicenseType IN ('tourism', 'heavyweight', 'super heavyweight'))
);

-- 3. CUSTOMER
CREATE TABLE CUSTOMER (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    Address VARCHAR(255) NOT NULL,
    Number VARCHAR(255) NOT NULL
);


-- 4. INDIVIDUAL
CREATE TABLE INDIVIDUAL (
    IndividualID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Name VARCHAR(255) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

-- 5. BUSINESS
CREATE TABLE BUSINESS (
    BusinessID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    Name VARCHAR(255) NOT NULL,
    Type VARCHAR(255) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);

-- 6. RESERVATION
CREATE TABLE RESERVATION (
    ReservationID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
VehicleTypeDesired VARCHAR(255) NOT NULL CHECK (VehicleTypeDesired IN ('tourism', 'heavyweight', 'super heavyweight')),
      RendezvousLocation VARCHAR(255) NOT NULL,
AppointmentDateTime DATETIME NOT NULL CHECK  (DAYOFWEEK(AppointmentDateTime) BETWEEN 2 AND 6),
	ExpectedDuration INT NOT NULL CHECK (ExpectedDuration <= 365),
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID)
);
-- 7. MISSION
CREATE TABLE MISSION (
    MissionID INT AUTO_INCREMENT PRIMARY KEY,
    VehicleID INT,
    DriverID INT,
    ReservationID INT,
    StartDateTime DATETIME NOT NULL,
    EndDateTime DATETIME NOT NULL,
    FOREIGN KEY (VehicleID) REFERENCES VEHICLE(VehicleID),
    FOREIGN KEY (DriverID) REFERENCES DRIVER(DriverID),
    FOREIGN KEY (ReservationID) REFERENCES RESERVATION(ReservationID),
    CHECK (DATEDIFF(EndDateTime, StartDateTime) <= 5 
               AND DAYOFWEEK(StartDateTime) BETWEEN 2 AND 6 
               AND DAYOFWEEK(EndDateTime) BETWEEN 2 AND 6)
);

-- 8. PAYMENT
CREATE TABLE PAYMENT (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    TotalAmountPaid INT NOT NULL
);

-- 9. INVOICE
CREATE TABLE INVOICE (
    InvoiceID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT,
    PaymentID INT,
    ReservationID INT,
    IssueDate DATETIME NOT NULL,
    DueDate DATETIME NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES CUSTOMER(CustomerID),
    FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID),
    FOREIGN KEY (ReservationID) REFERENCES RESERVATION(ReservationID)
);

-- 10. INVOICELINE
CREATE TABLE INVOICELINE (
    InvoiceLineID INT AUTO_INCREMENT PRIMARY KEY,
    InvoiceID INT,
    MissionID INT,
    OdometerStart INT NOT NULL,
    OdometerEnd INT NOT NULL,
    ActualStartDate DATETIME NOT NULL,
    ActualEndDate DATETIME NOT NULL,
    CalAmountDue INT NOT NULL,
    FOREIGN KEY (InvoiceID) REFERENCES INVOICE(InvoiceID),
    FOREIGN KEY (MissionID) REFERENCES MISSION(MissionID)
);

-- 11. CHEQUE
CREATE TABLE CHEQUE (
    ChequeID INT AUTO_INCREMENT PRIMARY KEY,
    PaymentID INT,
    ChequeNumber INT NOT NULL,
    BankName VARCHAR(255) NOT NULL,
    ChequeDate DATETIME NOT NULL,
    AmountPaidByCheque INT NOT NULL,
    FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID)
);

-- 12. CASH
CREATE TABLE CASH (
    CashID INT AUTO_INCREMENT PRIMARY KEY,
    PaymentID INT,
    AmountPaidByCash INT NOT NULL,
    FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID)
);

-- 13. CREDIT
CREATE TABLE CREDIT (
    CreditCardID INT AUTO_INCREMENT PRIMARY KEY,
    PaymentID INT,
    CreditCardNumber VARCHAR(255) NOT NULL,
    ExpiryDate DATETIME NOT NULL,
    SecurityCode VARCHAR(255) NOT NULL,
    AmountPaidByCredit INT NOT NULL,
    FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID)
);

DELIMITER //
CREATE TRIGGER check_license_and_vehicle
BEFORE INSERT ON MISSION
FOR EACH ROW
BEGIN
    DECLARE driver_license_type VARCHAR(255);
    DECLARE vehicle_type VARCHAR(255);
    -- Get the driver's license type
    SELECT DrivingLicenseType INTO driver_license_type FROM DRIVER WHERE DriverID = NEW.DriverID;
    -- Get the vehicle type
    SELECT Type INTO vehicle_type FROM VEHICLE WHERE VehicleID = NEW.VehicleID;
    -- Check if the driver's license type and vehicle type are compatible
    IF NOT (driver_license_type IN ('tourism', 'heavyweight', 'super heavyweight') AND driver_license_type = vehicle_type) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Driver and vehicle types are not compatible';
    END IF;
END //
DELIMITER ;


-- Section 7: Data Insertion in tables
-- ******************************************************************************************************************

-- Populate VEHICLE table
INSERT INTO VEHICLE (Type, Brand) VALUES
('tourism', 'Toyota'),
('heavyweight', 'Ford'),
('super heavyweight', 'Mercedes'),
('tourism', 'Honda'),
('heavyweight', 'Chevrolet'),
('super heavyweight', 'BMW'),
('tourism', 'Nissan'),
('heavyweight', 'GMC'),
('super heavyweight', 'Audi'),
('tourism', 'Hyundai'),
('heavyweight', 'GMC'),
('super heavyweight', 'Audi'),
('tourism', 'Hyundai');

-- Populate DRIVER table
INSERT INTO DRIVER (FirstName, LastName, DrivingLicenseType) VALUES
('John', 'Doe', 'tourism'),
('Jane', 'Smith', 'heavyweight'),
('Mike', 'Johnson', 'super heavyweight'),
('Emily', 'Williams', 'tourism'),
('Robert', 'Brown', 'heavyweight'),
('Sophia', 'Davis', 'super heavyweight'),
('Daniel', 'Miller', 'tourism'),
('Olivia', 'Anderson', 'heavyweight'),
('Ethan', 'Garcia', 'super heavyweight'),
('Emma', 'Martinez', 'tourism'),
('Oliver', 'Andy', 'heavyweight'),
('Eta', 'Garc', 'super heavyweight'),
('Em', 'Marti', 'tourism');


-- Populate CUSTOMER table
INSERT INTO CUSTOMER (Address, Number) VALUES
('123 Main St', '555-1234'),
('456 Oak Ave', '555-5678'),
('789 Pine Blvd', '555-9876'),
('101 Elm Ln', '555-5432'),
('202 Maple Dr', '555-6789'),
('303 Birch Rd', '555-4321'),
('404 Cedar St', '555-8765'),
('505 Redwood Ave', '555-2345'),
('606 Spruce Blvd', '555-7890'),
('707 Fir Ln', '555-3456'),
('708 Fue Ln', '555-3333');

-- Populate INDIVIDUAL table
INSERT INTO INDIVIDUAL (CustomerID, Name) VALUES
(1, 'John Doe'),
(3, 'Jane Smith'),
(5, 'Mike Johnson'),
(7, 'Emily Williams'),
(9, 'Robert Brown'),
(11, 'Robby B');

-- Populate BUSINESS table
INSERT INTO BUSINESS (CustomerID, Name, Type) VALUES
(2, 'ABC Corporation', 'Enterprise'),
(4, 'XYZ Partnership', 'Partnership'),
(6, 'Business Customer 4', 'Franchise'),
(8, 'Business Customer 6', 'Company'),
(10,'Business Customer 10', 'Enterprise');

-- Populate RESERVATION table
INSERT INTO RESERVATION (CustomerID, VehicleTypeDesired, RendezvousLocation, AppointmentDateTime, ExpectedDuration) VALUES
(1, 'tourism', 'LocationA', '2023-11-01 10:00:00', 2),
(2, 'heavyweight', 'LocationB', '2023-11-02 11:30:00', 1),
(3, 'super heavyweight', 'LocationC', '2023-11-06 12:45:00', 2),
(4, 'tourism', 'LocationD', '2023-11-07 09:15:00', 3),
(5, 'heavyweight', 'LocationE', '2023-11-13 14:20:00', 1),
(6, 'super heavyweight', 'LocationF', '2023-11-14 16:30:00', 1),
(7, 'tourism', 'LocationG', '2023-11-07 08:45:00', 3),
(8, 'heavyweight', 'LocationH', '2023-10-11 17:00:00', 2),
(9, 'super heavyweight', 'LocationI', '2023-11-09 13:00:00', 1),
(10, 'tourism', 'LocationJ', '2023-10-10 15:30:00', 7),
(1, 'tourism', 'LocationA', '2023-11-22 15:30:00', 2),
(2, 'tourism', 'LocationA', '2023-12-20 15:30:00', 1),
(2, 'tourism', 'LocationA', '2023-12-13 15:30:00', 1);

-- Populate MISSION table
INSERT INTO MISSION (VehicleID, DriverID, ReservationID, StartDateTime, EndDateTime) VALUES
(1, 1, 1, '2023-11-01 10:00:00', '2023-11-03 10:00:00'),
(2, 2, 2, '2023-11-02 11:30:00', '2023-11-03 11:30:00'), 
(3, 3, 3, '2023-11-06 12:45:00', '2023-11-08 12:45:00'),
(4, 4, 4, '2023-11-07 09:15:00', '2023-11-10 09:15:00'),
(5, 5, 5, '2023-11-13 14:20:00', '2023-11-14 14:20:00'),
(6, 6, 6, '2023-11-14 16:30:00', '2023-11-15 16:30:00'),
(7, 7, 7, '2023-11-07 08:45:00', '2023-11-10 08:45:00'),
(8, 8, 8, '2023-10-11 17:00:00', '2023-10-13 17:00:00'),
(9, 9, 9, '2023-11-09 13:00:00', '2023-11-10 13:00:00'),
(10, 10, 10, '2023-10-10 15:30:00', '2023-10-13 15:30:00'),
(10, 10, 10, '2023-10-16 15:30:00', '2023-10-19 15:30:00'),
(4,1, 11, '2023-11-22 15:30:00', '2023-11-24 15:30:00'),
(4,1, 12, '2023-12-20 15:30:00', '2023-12-21 15:30:00'),
(7,7, 13, '2023-12-13 15:30:00', '2023-12-14 15:30:00');


-- Populate PAYMENT table
INSERT INTO PAYMENT (TotalAmountPaid) VALUES
(800), 
(700),
(0),  
(400),
(1200),
(900),
(2000),
(950),
(0),  
(500),  
(300),
(0); 

-- Populate INVOICE table
INSERT INTO INVOICE (CustomerID, PaymentID, ReservationID, IssueDate, DueDate) VALUES
(1, 1, 1, '2023-11-03 10:00:00', '2023-11-23 10:00:00'),
(2, 2, 2, '2023-11-03 11:30:00', '2023-11-23 11:30:00'),
(3, 3, 3, '2023-11-08 12:45:00', '2023-11-28 12:45:00'),
(4, 4, 4, '2023-11-10 09:15:00', '2023-11-30 09:15:00'),
(5, 5, 5, '2023-11-14 14:20:00', '2023-11-24 14:20:00'),
(6, 6, 6, '2023-11-15 16:30:00', '2023-11-25 16:30:00'),
(7, 7, 7, '2023-11-10 08:45:00', '2023-11-20 08:45:00'),
(8, 8, 8, '2023-11-10 17:00:00', '2023-11-20 17:00:00'),
(9, 9, 9, '2023-11-10 13:00:00', '2023-11-23 13:00:00'),
(10, 10, 10,'2023-11-24 15:30:00', '2023-12-20 15:30:00'),
(1, 11, 11,'2023-11-24 15:30:00', '2023-12-20 15:30:00');

-- Populate INVOICELINE table
INSERT INTO INVOICELINE (InvoiceID, MissionID, OdometerStart, OdometerEnd, ActualStartDate, ActualEndDate, CalAmountDue) VALUES
(1, 1, 2300, 10000, '2023-11-01 10:00:00', '2023-11-03 10:00:00', 800),
(2, 2, 4900, 15000, '2023-11-02 11:30:00', '2023-11-03 11:30:00', 700),
(3, 3, 5900, 20000, '2023-11-06 12:45:00', '2023-11-08 12:45:00', 1000),
(4, 4, 2700, 50000, '2023-11-07 09:15:00', '2023-11-10 09:15:00', 400),
(5, 5, 6200, 30000, '2023-11-13 14:20:00', '2023-11-14 14:20:00', 1200),
(6, 6, 4100, 10000, '2023-11-14 16:30:00', '2023-11-15 16:30:00', 900),
(7, 7, 1100, 20000, '2023-11-07 08:45:00', '2023-11-10 08:45:00', 2000),
(8, 8, 2345, 15000, '2023-10-11 17:00:00', '2023-10-13 17:00:00', 950),
(9, 9, 2578, 25000, '2023-11-09 13:00:00', '2023-11-10 13:00:00', 700),
(10, 10, 30450, 50000, '2023-10-10 15:30:00', '2023-10-14 15:30:00', 500),
(10, 10, 4700, 30000, '2023-10-16 15:30:00', '2023-10-19 15:30:00', 600);

-- Populate CHEQUE table
INSERT INTO CHEQUE (PaymentID, ChequeNumber, BankName, ChequeDate, AmountPaidByCheque) VALUES
(1, 12345, 'BankA', '2023-11-01 10:00:00', 800),
(2, 54321, 'BankB', '2023-11-02 11:30:00', 700),
(3, 98765, 'BankC', '2023-11-03 12:45:00', 0),
(4, 45678, 'BankD', '2023-11-04 09:15:00', 400),
(5, 87654, 'BankE', '2023-11-05 14:20:00', 1200);

-- Populate CASH table
INSERT INTO CASH (PaymentID, AmountPaidByCash) VALUES
(6, 900),
(7, 2000),
(8, 950),
(9, 0),
(10, 500);

-- Populate CREDIT table
INSERT INTO CREDIT (PaymentID, CreditCardNumber, ExpiryDate, SecurityCode, AmountPaidByCredit) VALUES
(11, '1234567812345670', '2024-01-01 00:00:00', '123', 60),
(11, '2345678923456781', '2024-02-01 00:00:00', '456', 70),
(11, '3456789034567892', '2024-03-01 00:00:00', '789', 80),
(11, '4567890145678903', '2024-04-01 00:00:00', '012', 50),
(11, '5678901256789014', '2024-05-01 00:00:00', '345', 40);


-- Section 8: Implementation of queries 
-- ******************************************************************************************************************

-- Query #1: List of customers that are businesses (Enterprises or Companies)
SELECT DISTINCT b.BusinessID, c.CustomerID, c.Address, c.Number, b.Type
FROM CUSTOMER c
JOIN BUSINESS b ON c.CustomerID = b.CustomerID
WHERE b.Type IN ('Company', 'Enterprise');


-- Query #2: List of reservations whose reservation number is greater than 1.
SELECT CustomerID, COUNT(*) AS ReservationCount
FROM RESERVATION
GROUP BY CustomerID
HAVING ReservationCount > 1;

-- Query #3: List of drivers and vehicles having participated in at least one mission.
SELECT DISTINCT d.DriverID, d.FirstName, d.LastName, v.VehicleID, v.Brand
FROM DRIVER d
JOIN MISSION m ON d.DriverID = m.DriverID
JOIN VEHICLE v ON m.VehicleID = v.VehicleID;

-- Query #4: List of missions between October 11, 2023 and October 18, 2023 as well as the drivers and vehicles participating in these missions.
SELECT m.*, d.FirstName AS DriverFirstName, d.LastName AS DriverLastName, v.Brand AS VehicleBrand
FROM MISSION m
JOIN DRIVER d ON m.DriverID = d.DriverID
JOIN VEHICLE v ON m.VehicleID = v.VehicleID
WHERE m.StartDateTime BETWEEN '2023-10-11' AND '2023-10-18';

-- Query #5: The list of customers who have not paid their invoices or have payments less than combined InvoiceLine amounts.
SELECT c.CustomerID, c.Address, c.Number
FROM CUSTOMER c
LEFT JOIN INVOICE i ON c.CustomerID = i.CustomerID
LEFT JOIN (
    SELECT InvoiceID, SUM(CalAmountDue) AS CombinedAmountDue
    FROM INVOICELINE
    GROUP BY InvoiceID
) il_sum ON i.InvoiceID = il_sum.InvoiceID
LEFT JOIN PAYMENT p ON i.PaymentID = p.PaymentID
WHERE p.TotalAmountPaid < il_sum.CombinedAmountDue;

-- Query #6: List of drivers who have driven 'GMC' brand vehicles.
SELECT DISTINCT d.DriverID, d.FirstName, d.LastName
FROM DRIVER d
JOIN MISSION m ON d.DriverID = m.DriverID
JOIN VEHICLE v ON m.VehicleID = v.VehicleID
WHERE v.Brand = 'GMC';

-- Query #7: Customers with invoices greater than 1000 $ based on the respective InvoiceLines, including combined amounts.
SELECT c.CustomerID, c.Address, c.Number,
       i.InvoiceID,
       SUM(il.CalAmountDue) AS AmountDue
FROM CUSTOMER c
JOIN INVOICE i ON c.CustomerID = i.CustomerID
LEFT JOIN INVOICELINE il ON i.InvoiceID = il.InvoiceID
GROUP BY c.CustomerID, i.InvoiceID
HAVING AmountDue > 1000;

-- Query #8: List of all customers with their number of associated invoices.
SELECT c.CustomerID, c.Address, c.Number, COUNT(i.InvoiceID) AS NumberOfInvoices
FROM CUSTOMER c
LEFT JOIN INVOICE i ON c.CustomerID = i.CustomerID
GROUP BY c.CustomerID, c.Address, c.Number;

-- Query #9: What are the last names and first names of the drivers who have a mission between the following dates: October 1, 2023, and November 30, 2023, whose mileage (number of kilometers traveled) is more than 7000 km
SELECT DISTINCT d.DriverID, d.FirstName, d.LastName
FROM DRIVER d
JOIN MISSION m ON d.DriverID = m.DriverID
JOIN INVOICELINE il ON m.MissionID = il.MissionID
WHERE m.StartDateTime BETWEEN '2023-10-01' AND '2023-11-30'
AND (il.OdometerEnd - il.OdometerStart) > 7000;
