-- Project: Hotel Management System

-- 2. Physical Design

-- 2.1 Database Design 

use JIBE_Main_Training;

create table Hotel_Customers(
	CustomerId int primary key,
	Name varchar(50),
	Email varchar(50),
	Phone char(10),
	Address varchar(100)
);

create table Hotel_Rooms(
	RoomId int primary key,
	RoomType varchar(20),
	PricePerNight decimal(10, 2),
	Status varchar(20) check(Status in ('Available', 'NotAvailable'))
);

create table Hotel_Bookings(
	BookingId int identity(1,1) primary key,
	CustomerId int,
	RoomId int,
	CheckInDate date,
	CheckOutDate date,
	TotalAmount decimal(10, 2),
	Foreign key (CustomerId) references Hotel_Customers(CustomerId),
	Foreign key (RoomId) references Hotel_Rooms(RoomId)
);

create table Hotel_Payments(
	PaymentId int identity(1,1) primary key,
	BookingId int,
	PaymentDate date,
	Amount decimal(10, 2),
	PaymentMethod varchar(20),
	Foreign key (BookingId) references Hotel_Bookings(BookingId)
);

create table Hotel_Employee(
	EmployeeId int primary key,
	Name varchar(50),
	Position varchar(20),
	Salary decimal(10, 2),
	HireDate date,
	ManagerId int,
	Foreign key (ManagerId) references Hotel_Employee(EmployeeId)
);

create table Hotel_Services(
	ServiceId int primary key,
	ServiceName varchar(50),
	Price decimal(10, 2)
);

create table Hotel_HotelBranch(
	BranchId int primary key,
	BranchName varchar(50),
	LocationDecription varchar(100)
);




-- 1. Data Insertion

insert into Hotel_Customers (CustomerId, Name, Email, Phone, Address) values
(1, 'Virat Kohli', 'virat@gmail.com', '1234567890', '123 Main St'),
(2, 'Rohit Sharma', 'rohit@gmail.com', '0987654321', '456 Elm St'),
(3, 'K. L. Rahul', 'rahul@gmail.com', '1112223333', '789 Oak St'),
(4, 'Rishab Pant', 'rishab@gmail.com', '4445556666', '321 Pine St'),
(5, 'Axar Patel', 'axar@gmail.com', '7778889999', '654 Cedar St');

insert into Hotel_Rooms (RoomId, RoomType, PricePerNight, Status) values
(101, 'Single', 500.00, 'Available'),
(102, 'Double', 750.00, 'NotAvailable'),
(103, 'Suite', 1500.00, 'Available'),
(104, 'Single', 500.00, 'Available'),
(105, 'Double', 750.00, 'NotAvailable');

insert into Hotel_Bookings (CustomerId, RoomId, CheckInDate, CheckOutDate, TotalAmount) values
(1, 101, '2025-01-01', '2025-01-05', 2000.00),
(2, 102, '2025-02-01', '2025-02-05', 3000.00),
(3, 103, '2025-03-01', '2025-03-05', 6000.00),
(4, 104, '2025-04-01', '2025-04-05', 2000.00),
(5, 105, '2025-05-01', '2025-05-05', 3000.00);

insert into Hotel_Payments (BookingId, PaymentDate, Amount, PaymentMethod)values
(1, '2025-01-06', 2000.00, 'Credit Card'),
(2, '2025-02-06', 3000.00, 'UPI'),
(3, '2025-03-06', 6000.00, 'Cash'),
(4, '2025-04-06', 2000.00, 'Credit Card'),
(5, '2025-05-06', 3000.00, 'UPI');

insert into Hotel_Employee (EmployeeId, Name, Position, Salary, HireDate, ManagerId) values
(1, 'Shri Nashte', 'Manager', 50000.00, '2020-01-01', null),
(2, 'Jay Gajarkar', 'Receptionist', 30000.00, '2021-02-01', 1),
(3, 'Omkar Bagal', 'Housekeeper', 25000.00, '2021-03-01', 1),
(4, 'Auysh Koli', 'Chef', 35000.00, '2022-04-01', 1),
(5, 'Lavanya Satpute', 'Security', 30000.00, '2022-05-01', 1);

insert into Hotel_HotelBranch (BranchId, BranchName, LocationDecription) values
(1, 'Mumbai Central', 'Near Central Station, Mumbai'),
(2, 'Pune West', 'Next to Pune University, Pune'),
(3, 'Kohapur', 'Mahalakshi Temple, Rankala Lake, Mountans,Kohapur'),
(4, 'Chennai Beach', 'Close to Marina Beach, Chennai'),
(5, 'Navi Mumbai', 'Near Flemingo point Beach, Navi Mumbai');


-- 2. Quries using joins.

-- Customer Booking Details.
select Hotel_Customers.Name, Hotel_Rooms.RoomType, Hotel_Bookings.CheckInDate, Hotel_Bookings.TotalAmount
from Hotel_Customers 
inner join Hotel_Bookings on Hotel_Customers.CustomerId = Hotel_Bookings.CustomerId
inner join Hotel_Rooms on Hotel_Bookings.RoomId = Hotel_Rooms.RoomId;

-- Employee list with managers.
select emp.Name as Employee, emp.Position, man.Name as Manager
from Hotel_Employee as emp
left join Hotel_Employee as man on emp.ManagerId = man.EmployeeId;

-- Rooms that never booked.
select Hotel_Rooms.RoomId, Hotel_Rooms.RoomType, Hotel_Rooms.PricePerNight
from Hotel_Rooms
left join Hotel_Bookings on  Hotel_Rooms.RoomId = Hotel_Bookings.RoomId
where Hotel_Bookings.RoomId = null;


-- 3. Subquries.

-- Customers with multiple bookings.


-- Most Expencive Room booked.
select *
from Hotel_Rooms
where PricePerNight = (
    select max(PricePerNight)
    from Hotel_Rooms
    where RoomId in (
        select RoomId
        from Hotel_Bookings
    )
);

-- Views
create view ActiveBooking_ as
select 
	Hotel_Customers.Name,
	Hotel_Rooms.RoomType, 
	Hotel_Bookings.CheckInDate,
	Hotel_Bookings.CheckOutDate
from Hotel_Customers 
inner join Hotel_Bookings on Hotel_Customers.CustomerId = Hotel_Bookings.CustomerId
inner join Hotel_Rooms on Hotel_Bookings.RoomId = Hotel_Rooms.RoomId;
	
select *
from ActiveBooking_;


-- 5. Indexing 

-- Create Index on RoomType
create index idx_Rooms on Hotel_Rooms(RoomType);

-- Create Composite index on CheckInDate, CheckOutDate
create index idx_CheackInAndOut on Hotel_Bookings(CheckInDate, CheckOutDate);


-- 6. Stored Procedures and Functions.

-- Create Stored procedure to get total revenu generate in month.
create procedure sp_CalculateMonthlyRevenue(
    @Year int,
    @Month int
)
as
begin
    select sum(Amount) as TotalRevenue_In_Month
    from Hotel_Payments
    where year(PaymentDate) = @Year and month(PaymentDate) = @Month;
end;

exec sp_CalculateMonthlyRevenue
	@Year = 2025,
    @Month = 3;

-- Create UD Function to calculate the total number of days customer stayed.
create function fn_CalculateTotalDays(
    @CustomerId int
)
returns int
as
begin
    declare @TotalDays int;

    select @TotalDays = sum(datediff(day, CheckInDate, CheckOutDate))
    from Hotel_Bookings
    where CustomerId = @CustomerId;

    return @TotalDays;
end;

select dbo.fn_CalculateTotalDays(1);


--7. Triggers 
create trigger trg_CalceleBooking
on Hotel_Bookings
instead of delete
as 
begin
	update Hotel_Rooms
	set Status = 'Available'
	where RoomId = (select RoomId from deleted);
	print 'Booking Calceled !';
end;

delete 
from Hotel_Bookings
where BookingId = 1;



-- 10. Full Text Search
select * from Hotel_HotelBranch
where LocationDecription like '%Beach%';

exec sp_help Hotel_HotelBranch;

create fulltext index on Hotel_HotelBranch(LocationDecription)
key index PK__Hotel_Ho__A1682FC5A06E1382;

select * from Hotel_HotelBranch
where contains(LocationDecription, 'Beach');

