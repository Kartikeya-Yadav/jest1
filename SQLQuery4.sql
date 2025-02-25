-- Index in SQL
-- Functions, Stored Procedures and Triggers.

use JIBE_Main_Training;

select *
from employee_k;

exec sp_help employee_k;

set statistics io on;
set statistics time on;

-- Create table without index and primary key
CREATE TABLE EmployeeIndexExample (
    EmployeeID INT,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    DepartmentID INT
);

--Add random values
DECLARE @i INT = 1;
WHILE @i <= 50
BEGIN
    INSERT INTO EmployeeIndexExample (EmployeeID, FirstName, LastName, Email, DepartmentID)
    VALUES (
        @i,
        'FirstName' + SUBSTRING(CONVERT(VARCHAR(50), NEWID()), 1, 5),
        'LastName' + SUBSTRING(CONVERT(VARCHAR(50), NEWID()), 1, 5),
        'employee' + CAST(@i AS VARCHAR(10)) + SUBSTRING(CONVERT(VARCHAR(50), NEWID()), 1, 3) + '@example.com',
        ABS(CHECKSUM(NEWID())) % 10 + 1 -- Random department between 1 and 10
    );
    SET @i = @i + 1;
END;

select * from EmployeeIndexExample;

select *
from EmployeeIndexExample
where DepartmentID = 4 and Email = 'employee43201@example.com';


-- Create clustered index
create clustered index idx_EmployeeID on EmployeeIndexExample(EmployeeID);

select *
from EmployeeIndexExample
where DepartmentID = 4 and Email = 'employee43201@example.com';


-- Create nonclustered index
create nonclustered index idx_FirstName on EmployeeIndexExample(FirstName);

select *
from EmployeeIndexExample
where FirstName = 'FirstName8ACF3';


-- Create unique index
create unique index idx_Email on EmployeeIndexExample(Email);

select * 
from EmployeeIndexExample
where Email = 'employee43201@example.com';


-- Drop index
drop index idx_EmployeeID on EmployeeIndexExample;
drop index idx_FirstName on EmployeeIndexExample;
drop index idx_Email on EmployeeIndexExample;

-- Create Composite Index
create index idx_FirstName_LastName
on EmployeeIndexExample(LastName, FirstName);

select * 
from EmployeeIndexExample
where FirstName = 'FirstName8ACF3' and LastName = 'LastNameF1675';

drop index idx_FirstName_LastName on EmployeeIndexExample;

exec sp_help EmployeeIndexExample;

set statistics io off;
set statistics time off;


-- Functions 
create function fn_GetEmployeeFullName
(
    @EmployeeID int
)
returns varchar(100)
as
begin
    declare @FullName varchar(100);

    select @FullName = FirstName + ' ' + LastName
    from EmployeeIndexExample
    where EmployeeID = @EmployeeID;

    return @FullName;
end;

select dbo.fn_GetEmployeeFullName(2) as FullName;


create function fn_GetEmployeesByDepartment
(
    @DepartmentID int
)
returns table
as
return
(
    select EmployeeID, FirstName, LastName
    from EmployeeIndexExample
    where DepartmentID = @DepartmentID
);

select * from dbo.fn_GetEmployeesByDepartment(1);


-- Procedures

create procedure sp_GetEmployeeDetails
(
    @EmployeeID int
)
as
begin
    select EmployeeID, FirstName, LastName, DepartmentID
    from EmployeeIndexExample
    where EmployeeID = @EmployeeID;
end;

exec dbo.sp_GetEmployeeDetails @EmployeeID = 1;

create procedure sp_InsertEmployee
(
	@EmployeeID int,
    @FirstName varchar(50),
    @LastName varchar(50),
    @Email varchar(100),
    @DepartmentID int
)
as
begin
	insert into EmployeeIndexExample (EmployeeID, FirstName, LastName, Email, DepartmentID) values
    (@EmployeeID, @FirstName, @LastName, @Email, @DepartmentID);
end;

exec sp_InsertEmployee 
	@EmployeeID = 101,
    @FirstName = 'Shri',
    @LastName = 'Nashte',
    @Email = 'shri@gmail.com',
    @DepartmentID = 1;

select * 
from EmployeeIndexExample;
where DepartmentID = 1;



-- Triggers
-- After Trigger
create trigger trg_InsertEmployee
on EmployeeIndexExample
after insert
as
begin
	print 'New row inserted in EmployeeIndexExample';
end;

insert into EmployeeIndexExample (EmployeeID, FirstName, LastName, Email, DepartmentID) values
(102, 'Jay', 'Gajarkar', 'jay@gmail.com', 2);

-- Instead of delete trigger
create trigger trg_InsteadOfDelete
on EmployeeIndexExample
instead of delete
as
begin
	update EmployeeIndexExample
	set DepartmentID = null
	where EmployeeID in (select EmployeeID from deleted);
end;

delete from EmployeeIndexExample
where FirstName = 'Jay';


-- DDL Trigger
CREATE TRIGGER trg_prevent_table_creation
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS 
BEGIN
   PRINT 'You can not create, drop and alter table in this database';
   ROLLBACK;
END;


-- Drop the trigger
SELECT name AS TriggerName,
       parent_class_desc AS Scope,
       create_date AS CreationDate
FROM sys.triggers
ORDER BY create_date;

drop trigger trg_InsteadOfDelete;
drop trigger trg_prevent_table_creation on database;



-- Assignment: Banking System

create table Bank_Customers(
	CustomerId int primary key,
	CustomerName varchar(50),
	Email varchar(50),
	PhoneNumber char(10)
);

create table Bank_Accounts (
    AccountID int primary key,
    CustomerID int,
	AccountNumber int unique,
    AccountType varchar(20),
    Balance decimal(10, 2),
	foreign key (CustomerID) references Bank_Customers(CustomerID)
);

create table Bank_Transactions (
    TransactionID int primary key,
    AccountID int ,
    TransactionType varchar(20),
    Amount decimal(10, 2),
    TransactionDate date,
	foreign key (AccountID) references Bank_Accounts(AccountID)
);

create table Bank_Audit (
    AuditID int primary key,
    AccountID int,
    Amount decimal(10, 2),
    TransactionDate date,
    Action varchar(50),
	foreign key (AccountID) references Bank_Accounts(AccountID)
);

insert into Bank_Customers (CustomerId, CustomerName, Email, PhoneNumber) values
(1, 'John Doe', 'john.doe@example.com', '9876543210'),
(2, 'Jane Smith', 'jane.smith@example.com', '9123456789'),
(3, 'Alice Johnson', 'alice.johnson@example.com', '9988776655'),
(4, 'Robert Brown', 'robert.brown@example.com', '9876543120'),
(5, 'Linda Davis', 'linda.davis@example.com', '9123456879'),
(6, 'James Wilson', 'james.wilson@example.com', '9988776644'),
(7, 'Patricia Taylor', 'patricia.taylor@example.com', '9876543221'),
(8, 'Michael Thomas', 'michael.thomas@example.com', '9123456780'),
(9, 'Barbara Moore', 'barbara.moore@example.com', '9988776633'),
(10, 'William Jackson', 'william.jackson@example.com', '9876543232');

insert into Bank_Accounts (AccountID, CustomerID, AccountNumber, AccountType, Balance) values
(1, 1, 1234567890, 'Savings', 1000.00),
(2, 2, 1234567891, 'Current', 2000.50),
(3, 3, 1234567892, 'Savings', 1500.75),
(4, 4, 1234567893, 'Current', 3000.00),
(5, 5, 1234567894, 'Savings', 2500.25),
(6, 6, 1234567895, 'Current', 3500.00),
(7, 7, 1234567896, 'Savings', 4500.50),
(8, 8, 1234567897, 'Current', 4000.00),
(9, 9, 1234567898, 'Savings', 5000.00),
(10, 10, 1234567899, 'Current', 6000.75);

select *
from Bank_Customers;

select *
from Bank_Accounts;

-- Task 1: Implement Indexing.
-- 1.
create clustered index idx_AccountID on Bank_Accounts(AccountID);--This is created by default due to prtimary key.
-- 2.
create nonclustered index idx_CustomerName on Bank_Customers(CustomerName);
-- 3.
create index idx_AmountTransactionDate 
on Bank_Transactions(Amount, TransactionDate);
-- 4.
create unique index idx_AccountNumber on Bank_Accounts(AccountNumber);

-- Task 2: Create Scalar function for Intrest Calculation.
create function fn_IntrestCalculation
(
	@AccountId int
)
returns decimal(10, 2)
as
begin
	declare @Intrest decimal(10, 2);

	select @Intrest = (Balance*0.05)
	from Bank_Accounts
	where AccountId = @AccountId;

	return @Intrest;
end;

select dbo.fn_IntrestCalculation(1) as Intrest;

-- Task 3: Create Stored Procedure for Transactions.
create procedure sp_TransferMoney
(
	@FromAccountId int,
	@ToAccountId int,
	@Amount
)
as 
begin
	begin transaction;

    -- Check if the FromAccount has sufficient balance
    if (select Balance from Bank_Accounts where AccountID = @FromAccountID) < @Amount
    begin
		print 'Insufficient funds';
        rollback transaction;
        return;
    end

    -- Deduct the amount from the FromAccount
    update Bank_Accounts
    set Balance = Balance - @Amount
	where AccountID = @FromAccountID;

	-- Add the amount to the ToAccount
	update Bank_Accounts
	set Balance = Balance + @Amount
	where AccountID = @ToAccountID;

	-- Insert a record in the Transactions table for FromAccount
	INSERT INTO Transactions (AccountID, TransactionType, Amount, TransactionDate, Description)
	VALUES (@FromAccountID, 'Debit', @Amount, GETDATE(), 'Transfer to AccountID: ' + CAST(@ToAccountID AS NVARCHAR(10)));

	-- Insert a record in the Transactions table for ToAccount
	INSERT INTO Transactions (AccountID, TransactionType, Amount, TransactionDate, Description)
	VALUES (@ToAccountID, 'Credit', @Amount, GETDATE(), 'Transfer from AccountID: ' + CAST(@FromAccountID AS NVARCHAR(10)));
	
	COMMIT TRANSACTION;
end;

