create schema ecomm;
use ecomm;
show tables;

create table Supplier(
SUPP_ID int primary key,
SUPP_NAME varchar(30),
SUPP_CITY varchar(30),
SUPP_PHONE varchar(12));

create table Customer(
CUS_ID int primary key,
CUS_NAME varchar(30),
CUS_PHONE varchar(12),
CUS_CITY varchar(30),
CUS_GENDER char);

create table Category(
CAT_ID int primary key,
CAT_NAME varchar(30));

create table Product(
PRO_ID int primary key,
PRO_NAME varchar(30),
PRO_DESC varchar(30),
CAT_ID int,
foreign key(CAT_ID) references Category(CAT_ID));

create table ProductDetails(
PROD_ID int primary key,
PRO_ID int,
SUPP_ID int,
PRICE int,
foreign key(PRO_ID) references Product(PRO_ID),
foreign key(SUPP_ID) references Supplier(SUPP_ID));

create table Orders(
ORD_ID int primary key,
ORD_AMOUNT int,
ORD_DATE date,
CUS_ID int,
PROD_ID int,
foreign key(CUS_ID) references Customer(CUS_ID),
foreign key(PROD_ID) references ProductDetails(PROD_ID));

create table Rating(
RAT_ID int primary key,
CUS_ID int,
SUPP_ID int,
RAT_RATSTARS int,
foreign key(CUS_ID) references Customer(CUS_ID),
foreign key(SUPP_ID) references Supplier(SUPP_ID));


insert into Supplier values(1, "Rajesh Retails", "Delhi", "1234567890");
insert into Supplier values(2, "Appario Ltd.", "Mumbai", "2589631470");
insert into Supplier values(3, "Knome products", "Banglore", "9785462315");
insert into Supplier values(4, "Bansal Retails", "Kochi", "8975463285");
insert into Supplier values(5, "Mittal Ltd.", "Lucknow", "7898456532");

insert into Customer values(1, "AAKASH", "9999999999", "DELHI", 'M');
insert into Customer values(2, "AMAN", "9785463215", "NOIDA", 'M');
insert into Customer values(3, "NEHA", "9999999999", "MUMBAI",'F');
insert into Customer values(4, "MEGHA", "9994562399", "KOLKATA", 'F');
insert into Customer values(5, "PULKIT", "7895999999", "LUCKNOW", 'M');

insert into Category values(1, "BOOKS");
insert into Category values(2, "GAMES");
insert into Category values(3, "GROCERIES");
insert into Category values(4, "ELECTRONICS");
insert into Category values(5, "CLOTHES");

insert into Product values(1, "GTA V", "DFJDJFDJFDJFDJFJF", 2);
insert into Product values(2, "TSHIRT", "DFDFJDFJDKFD", 5);
insert into Product values(3, "ROG LAPTOP", "DFNTTNTNTERND", 4);
insert into Product values(4, "OATS", "REURENTBTOTH", 3);
insert into Product values(5, "HARRY POTTER", "NBEMCTHTJTH", 1);
insert into ProductDetails values(1, 1, 2, 1500);
insert into ProductDetails values(2, 3, 5, 30000);
insert into ProductDetails values(3, 5, 1, 3000);
insert into ProductDetails values(4, 2,	3, 2500);
insert into ProductDetails values(5, 4, 1, 1000);

insert into Orders values(20, 1500, "2021-10-12", 3, 5);
insert into Orders values(25, 30500, "2021-09-16", 5, 2);
insert into Orders values(26, 2000,	"2021-10-05", 1, 1);
insert into Orders values(30, 3500, "2021-08-16", 4, 3);
insert into Orders values(50, 2000,	"2021-10-06", 2, 1);

insert into Rating values(1, 2,	2, 4);
insert into Rating values(2, 3, 4, 3);
insert into Rating values(3, 5, 1, 5);
insert into Rating values(4, 1, 3, 2);
insert into Rating values(5, 4, 5, 4);

-- 3)	Display the number of the customer group by their genders 
-- who have placed any order of amount greater than or equal to Rs.3000.
select CUS_GENDER, count(CUS_GENDER) as No_Of_Customers from Customer C, Orders O
where C.CUS_ID = O.CUS_ID and O.ORD_AMOUNT >= 3000
group by CUS_GENDER;

-- 4)	Display all the orders along with the product name 
-- ordered by a customer having Customer_Id=2.
select O.*, Q.PRO_NAME 
from Orders O inner join 
	(select P.PRO_NAME, PD.PROD_ID, P.PRO_ID 
    from Product P right join ProductDetails PD
	on P.PRO_ID = PD.PRO_ID) as Q
on O.PROD_ID = Q.PROD_ID
having O.CUS_ID = 2;

-- 5)	Display the Supplier details who can supply more than one product.
select Supplier.* from Supplier 
inner join
	(select SUPP_ID, count(SUPP_ID) as PROD_COUNT from ProductDetails
	group by SUPP_ID) as P
on Supplier.SUPP_ID = P.SUPP_ID
where P.PROD_COUNT > 1;

-- 6)	Find the category of the product whose order amount is minimum.
select C.* from Orders O, ProductDetails PD, Product P, Category C
where O.PROD_ID = PD.PROD_ID and PD.PRO_ID = P.PRO_ID 
and P.CAT_ID = C.CAT_ID 
and O.ORD_AMOUNT = (select min(ORD_AMOUNT) from Orders);

-- 7)	Display the Id and Name of the Product ordered after “2021-10-05”.
select P.PRO_ID, P.PRO_NAME from Product P, ProductDetails PD, Orders O 
where O.PROD_ID = PD.PROD_ID AND PD.PRO_ID = P.PRO_ID AND O.ORD_DATE > "2021-10-05";

-- 8)	Display customer name and gender whose names start or end with character 'A'.
select CUS_NAME, CUS_GENDER from Customer where CUS_NAME like "A%" or CUS_NAME like "%A";

-- 9)	Create a stored procedure to display the Rating for a Supplier 
-- if any along with the Verdict on that rating if any like 
-- if rating >4 then “Genuine Supplier” 
-- if rating >2 “Average Supplier” 
-- else “Supplier should not be considered”.

Delimiter &&
CREATE PROCEDURE `display_rating_with_verdict`()
BEGIN
select S.*, R.RAT_RATSTARS, 
Case
	when R.RAT_RATSTARS > 4 then "Genuine Supplier"
    when R.RAT_RATSTARS between 3 and 4 then "Average Supplier"
    else "Supplier should not be considered"
end 
as Verdict from Supplier S
inner join Rating R
on R.SUPP_ID = S.SUPP_ID;
END
&& Delimiter ;

call display_rating_with_verdict;