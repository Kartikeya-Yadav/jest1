-- Assignment: Banking System

use JIBE_Main_Training;

-- Create tables
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

create table Bank_Transactions_ (
    TransactionID int identity(1,1) primary key,
    AccountID int ,
    TransactionType varchar(20),
    Amount decimal(10, 2),
    TransactionDate date,
	foreign key (AccountID) references Bank_Accounts(AccountID)
);

create table Bank_Audit_ (
    AuditID int identity(1,1) primary key,
    AccountID int,
    Amount decimal(10, 2),
    TransactionDate date,
    Action varchar(50),
	foreign key (AccountID) references Bank_Accounts(AccountID)
);


-- Insert data into Bank_Customers and Bank_Accounts tables.
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
on Bank_Transactions_(Amount, TransactionDate);

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
select dbo.fn_IntrestCalculation(2) as Intrest;


-- Task 3: Create Stored Procedure for Transactions.
create procedure sp_TransferMoney
(
	@FromAccountID int,
	@ToAccountID int,
	@Amount decimal(10, 2)
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
	insert into Bank_Transactions_ (AccountID, TransactionType, Amount, TransactionDate)
	values (@FromAccountID, 'Debit', @Amount, GETDATE());
	-- Insert a record in the Transactions table for ToAccount
	insert into Bank_Transactions_ (AccountID, TransactionType, Amount, TransactionDate)
	values (@ToAccountID, 'Credit', @Amount, GETDATE());
	commit transaction;
end;

exec sp_TransferMoney 
	@FromAccountID = 2,
	@ToAccountID = 1,
	@Amount = 400.0;

select * 
from Bank_Transactions_;

select *
from Bank_Accounts;



-- Task 4: Create a Trigger to prevent overdraft
create trigger trg_InsuffBalance
on Bank_Accounts
after update
as 
begin
	declare @AccountID int, @NewBalance decimal(10,2);

    select @AccountID = inserted.AccountID, @NewBalance = inserted.Balance
    from inserted;

    if @NewBalance < 0
    begin
        -- If the balance is insufficient, rollback the transaction
        print 'Insufficient funds! Transaction aborted.';
        rollback transaction;
	end
end;

drop trigger trg_InsuffBalance;



-- Task 5: Create Audit Trigger
create trigger trg_Audit
on Bank_Transactions_
after insert 
as
begin
	declare @AccountID int, @Amount decimal(10, 2), @TransactionDate date, @Action varchar(50)

	select  @AccountID = AccountID, @Amount = Amount, @TransactionDate = TransactionDate, @Action = TransactionType
	from inserted;

	insert into Bank_Audit_ (AccountID, Amount, TransactionDate, Action)
	values (@AccountID, @Amount, @TransactionDate, @Action);
end;

select *
from Bank_Audit_;