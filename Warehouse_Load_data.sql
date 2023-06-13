USE [master]
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE [name]=N'StoreSales_analysis')
DROP DATABASE [StoreSales_analysis]
GO

USE StoreSales_analysis
GO

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[StoreSalesAnalysisStagingTable]') AND type in (N'U'))
DROP TABLE [StoreSalesAnalysisStagingTable]
GO

CREATE TABLE [StoreSalesAnalysisStagingTable](
	area_code varchar(20),
	state_name varchar(20),
	market varchar(20),
	market_size varchar(100),
	profit varchar(50),
	margin	varchar(20),
	sales varchar(50),
	cogs varchar(50),
	total_expense	varchar(50),
	marketing varchar(50),
	inventory varchar(50),
	budget_profit varchar(30),
	budget_cogs varchar(50),
	budget_margin varchar(50),
	budget_sales varchar(50),
	date_type datetime,
	product_name varchar(50),
	product_type varchar(50)
)

bulk insert StoreSalesAnalysisStagingTable
from 'C:\Users\user\Desktop\Lally(Renesslaer)\Adv. data resc mgmt\for_project\PROJECT\SALES_NEW.csv'
with (format = 'csv')

Select * from StoreSalesAnalysisStagingTable


--	Drop the factStoreSalesAnalysis table
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'factStoreSalesAnalysis') AND type in (N'U'))
DROP TABLE factStoreSalesAnalysis
GO


select distinct state_name
from StoreSalesAnalysisStagingTable --20 states

select distinct market
from StoreSalesAnalysisStagingTable -- 4 - east,central,south,west

select distinct market_size
from StoreSalesAnalysisStagingTable --2 -small market, major market

select distinct product_name
from StoreSalesAnalysisStagingTable --4 espresso,tea,herbeal tea,coffee

select distinct product_type
from StoreSalesAnalysisStagingTable -- 13 rows


IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimstate_name]') AND type in (N'U'))
DROP TABLE [dimstate_name]
GO

CREATE TABLE dimstate_name(
  state_nameID INT IDENTITY(1,1) NOT NULL, -- computer creates this means we have to specify identity(1,1)
  constraint PK_dimstate_name primary key clustered(state_nameID),    
  state_nameDescription VARCHAR(100),

   )

   
 INSERT INTO dimstate_name
 select distinct state_name
 from StoreSalesAnalysisStagingTable
 order by state_name  ASC

   select * from dimstate_name

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimMarket]') AND type in (N'U'))
DROP TABLE [dimMarket]
GO


CREATE TABLE dimMarket(
  MarketID INT IDENTITY(1,1) NOT NULL, -- computer creates this means we have to specify identity(1,1)
    constraint PK_dimMarket primary key clustered(MarketID),
  MarketDescription VARCHAR(50) NOT NULL 
   )

    INSERT INTO dimMarket
 select distinct market
 from StoreSalesAnalysisStagingTable
 order by Market ASC

    select * from dimMarket

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimMarket_size]') AND type in (N'U'))
DROP TABLE [dimMarket_size]
GO

CREATE TABLE dimMarket_size(
  market_sizeID INT IDENTITY(1,1) NOT NULL, -- computer creates this means we have to specify identity(1,1)
    constraint PK_dimMarket_size primary key clustered(market_sizeID),
  market_sizeDescription VARCHAR(50) 
   )

   Insert into dimMarket_size
   values 
   ('MAJOR Market'),
   ('SMALL Market')
   
   select * from dimMarket_size

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimProduct_name]') AND type in (N'U'))
DROP TABLE [dimProduct_name]
GO

CREATE TABLE dimProduct_name(
  ProdID INT IDENTITY(1,1) NOT NULL, -- computer creates this means we have to specify identity(1,1)
    constraint PK_dimProduct_name primary key clustered(ProdID),
  ProdNameDescription VARCHAR(50),
   )
   
       INSERT INTO dimProduct_name
 select distinct product_name
 from StoreSalesAnalysisStagingTable
 order by product_name ASC

select * from dimProduct_name

IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dimProduct_type]') AND type in (N'U'))
DROP TABLE [dimProduct_type]
GO

CREATE TABLE dimProduct_type(
  Prod_typeID INT IDENTITY(1,1) NOT NULL, -- computer creates this means we have to specify identity(1,1)
    constraint PK_dimProduct_type primary key clustered(Prod_typeID),
  ProdTypeDescription VARCHAR(50),
   )

         INSERT INTO dimProduct_type
 select distinct product_type
 from StoreSalesAnalysisStagingTable
 order by product_type ASC

 select * from dimProduct_type


 ---fact table creation

create table [dbo].[factStoreSalesAnalysis](
   -- Store_ID int Identity(1,1) NOT NULL,
	--constraint PK_factStoreSalesAnalysis primary key clustered(Store_ID),
	Area_Code varchar(20),
	constraint PK_factStoreSalesAnalysis primary key clustered(area_code),
	StateName int,
		constraint FK_dimstate_name_factStoreSalesAnalysis foreign key (stateName)
		references dimstate_name(state_nameID),
	Market_ident int,
		CONSTRAINT FK_dimMarket_factStoreSalesAnalysis FOREIGN KEY (Market_ident)
		REFERENCES dimMarket (MarketID),
	Market_size_ident int,
		CONSTRAINT FK_dimMarket_size_factStoreSalesAnalysis FOREIGN KEY (market_size_ident)
		REFERENCES dimMarket_size (market_sizeID),

	profit varchar(50),
	margin	varchar(20),
	sales varchar(50),
	cogs varchar(50),
	total_expense	varchar(50),
	marketing varchar(50),
	inventory varchar(50),
	budget_profit varchar(30),
	budget_cogs varchar(50),
	budget_margin varchar(50),
	budget_sales varchar(50),
    ProductNameID int,	
		CONSTRAINT FK_dimProduct_name_factStoreSalesAnalysis FOREIGN KEY (ProductNameID)
		REFERENCES dimProduct_name (ProdID),
	Product_TypeID int,
        CONSTRAINT FK_dimProduct_type_factStoreSalesAnalysis FOREIGN KEY (Product_TypeID)
		REFERENCES dimProduct_type (Prod_typeID),
    date_type datetime,

)

SET IDENTITY_INSERT dbo.factStoreSalesAnalysis ON;  
GO  
Insert into factStoreSalesAnalysis
select
   area_code,
   state_name, 
		case
			when state_name IS NULL then 1
			when state_name = 'California' then	2
			when state_name = 'Colorado' then	3
			when state_name = 'Connecticut' then	4
			when state_name = 'Florida' then	5
			when state_name = 'Illinois' then	6
			when state_name = 'Iowa' then	7
			when state_name = 'Louisiana' then	8
			when state_name = 'Massachusetts' then	9
			when state_name = 'Missouri' then	10
			when state_name = 'Nevada' then	11
			when state_name = 'New Hampshire' then	12
            when state_name = 'New Mexico' then	13
            when state_name = 'New York' then	14
            when state_name = 'Ohio' then	15
            when state_name = 'Oklahoma' then	16
            when state_name = 'Oregon' then	17
            when state_name = 'Texas' then	18
            when state_name = 'Utah' then	19
            when state_name = 'Washington' then	20
            when state_name = 'Wisconsin' then	21
		end,
	market,
		case
			when market IS NULL then 1
			when market = 'Central' then 2
			when market = 'East' then	3
			when market = 'South' then 4
            when market = 'West' then 5
		end,
	market_size, 
		case
		   when market_size IS NULL then 1
		   when market_size = 'MAJOR Market' then	2
		   when market_size = 'SMALL Market' then	3
		end,

	profit,
	margin,
	sales,
	cogs,
	total_expense,
	marketing ,
	inventory ,
	budget_profit,
	budget_cogs,
	budget_margin,
	budget_sales,
	product_name,
		case
			when product_name IS NULL then 1
			when product_name = 'Coffee' then	2
			when product_name = 'Espresso' then	3
			when product_name = 'Herbal Tea' then	4
			when product_name = 'Tea' then	5
        end,
	product_type,
	    case
			when product_type IS NULL then 1
			when product_type = 'Amaretto' then	2
			when product_type = 'Caffe Latte' then	3
			when product_type = 'Caffe Mocha' then	4
			when product_type = 'Chamomile' then	5
			when product_type = 'Columbian' then	6
			when product_type = 'Darjeeling' then	7
			when product_type = 'Decaf Espresso' then	8
			when product_type = 'Decaf Irish Cream' then	9
			when product_type = 'Earl Grey' then	10
			when product_type = 'Green Tea' then	11
			when product_type = 'Lemon' then	12
            when product_type = 'Mint' then	13
            when product_type = 'Regular Espresso' then	14
		end,
		date_type=YEAR(date_type) * 10000 + MONTH(date_type) * 100 + DAY(date_type)
from StoreSalesAnalysisStagingTable



select distinct area_code
from StoreSalesAnalysisStagingTable


	--area_code varchar(20),
	--state_name varchar(20),
	--market varchar(20),
	--market_size varchar(100),
	--profit varchar(50),
	--margin	varchar(20),
	--sales varchar(50),
	--cogs varchar(50),
	--total_expense	varchar(50),
	--marketing varchar(50),
	--inventory varchar(50),
	--budget_profit varchar(30),
	--budget_cogs varchar(50),
	--budget_margin varchar(50),
	--budget_sales varchar(50),
	--date_type datetime,
	--product_name varchar(50),
	--product_type varchar(50)