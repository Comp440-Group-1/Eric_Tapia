USE [master]
GO
/****** Object:  Database [s16guest01]    Script Date: 5/6/2016 3:34:06 PM ******/
CREATE DATABASE [s16guest01]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N's16guest01', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.CSDB440\MSSQL\DATA\s16guest01.mdf' , SIZE = 7232KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N's16guest01_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.CSDB440\MSSQL\DATA\s16guest01_log.ldf' , SIZE = 784KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [s16guest01] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [s16guest01].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [s16guest01] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [s16guest01] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [s16guest01] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [s16guest01] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [s16guest01] SET ARITHABORT OFF 
GO
ALTER DATABASE [s16guest01] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [s16guest01] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [s16guest01] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [s16guest01] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [s16guest01] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [s16guest01] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [s16guest01] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [s16guest01] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [s16guest01] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [s16guest01] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [s16guest01] SET  ENABLE_BROKER 
GO
ALTER DATABASE [s16guest01] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [s16guest01] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [s16guest01] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [s16guest01] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [s16guest01] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [s16guest01] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [s16guest01] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [s16guest01] SET RECOVERY FULL 
GO
ALTER DATABASE [s16guest01] SET  MULTI_USER 
GO
ALTER DATABASE [s16guest01] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [s16guest01] SET DB_CHAINING OFF 
GO
ALTER DATABASE [s16guest01] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [s16guest01] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
EXEC sys.sp_db_vardecimal_storage_format N's16guest01', N'ON'
GO
USE [s16guest01]
GO
/****** Object:  User [s16guest01]    Script Date: 5/6/2016 3:34:06 PM ******/
CREATE USER [s16guest01] FOR LOGIN [s16guest01] WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [s16guest01]
GO
/****** Object:  StoredProcedure [dbo].[customerInsert]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[customerInsert](
		@Customer_ID int,
        @Name nvarchar(100),
        @Lastname nvarchar(100),
        @Email nvarchar(100),
        @Company_Name nvarchar(100),
        @Address_ID int)

AS

BEGIN
	DECLARE @temp int = (select count(*) from Customer where  
				Name = @Name and 
				Lastname = @Lastname and
				Email = @Email )
	if @temp = 0
	begin
		begin try
			INSERT INTO [dbo].[Customer]
					([Customer_ID]
					,[Name]
					,[Lastname]
					,[Email]
					,[Company_Name]
					,[Address_ID])
				VALUES
					(@Customer_ID ,
					@Name ,
					@Lastname ,
					@Email ,
					@Company_Name ,
					@Address_ID )
		end try
		begin catch
			raiserror('Error',1,1)
		end catch

	end else begin
		raiserror('Duplicate data',1,1)
	end

END
GO
/****** Object:  StoredProcedure [dbo].[customerUpdate]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[customerUpdate](
		@customer_id int,
        @name nvarchar(50),
        @lastname nvarchar(50),
        @email nvarchar(50),
        @company_name nvarchar(50),
        @address_id int)

AS

BEGIN
	DECLARE @temp int = (select count(*) from Customer where  
				customer_id = @customer_id )
	if @temp > 0
	begin
		BEGIN TRY
			SET NOCOUNT ON;

				UPDATE [dbo].[customer]
				   SET [name] = @name
					  ,[lastname] = @lastname
					  ,[email] = @email
					  ,[company_name] = @company_name
				where customer_id = @customer_id
		END try

		BEGIN CATCH
			raiserror('Error',1,1)
		END CATCH

	end else begin
		raiserror('No data',2,1)
	end

END
GO
/****** Object:  StoredProcedure [dbo].[firstReport]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[firstReport]
AS
BEGIN
	SELECT         dbo.Product.Product_Name, dbo.Branch.Branch_Code, SUBSTRING(dbo.Download_history.Download_Date, 1, 2) AS Month, COUNT(*) AS Count
	FROM           dbo.Product INNER JOIN
                   dbo.Branch ON dbo.Product.Product_ID = dbo.Branch.Product_ID INNER JOIN
                   dbo.Download_history ON dbo.Branch.Branch_ID = dbo.Download_history.Branch_ID
	GROUP BY	   dbo.Product.Product_Name, dbo.Branch.Branch_Code, 
					SUBSTRING(dbo.Download_history.Download_Date, 1, 2)

END
GO
/****** Object:  StoredProcedure [dbo].[secondReport]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[secondReport](@Branch_Id int)

AS

BEGIN
	BEGIN TRY
		DECLARE @count int = (select count(*) from Features where  
					Branch_ID = @Branch_ID)
		DECLARE @branchCode nvarchar(10) = (select Branch_Code from Branch where  
					Branch_ID= @Branch_ID)
		if @count > 0
		begin
			if @count = 1
			begin
				DECLARE @featD nvarchar(100) = (select Feature_Description from Features where  
					Branch_ID = @Branch_ID)
					if CHARINDEX ( 'bug fix' ,@featD) > 0 begin
						select 'Its a bug–fix release'
					end else begin
						select CAST(@count AS varchar(10)) + ' features are in the '+ @branchCode + ' release'
					end

			end else begin
				select CAST(@count AS varchar(10)) + ' features are in the '+ @branchCode + ' release'
			end
		end else begin
			select 'No new features in the '+ @branchCode  +' release'
		end
	END TRY
	BEGIN CATCH
		raiserror('secondReport Error!',1,1)
	END CATCH

END
GO
/****** Object:  StoredProcedure [dbo].[spInsertPlatforms]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[spInsertPlatforms](
		@Platform_Name nchar(30))
AS
BEGIN
	DECLARE @temp int = (select count(*) from Platforms where  
				Platform_Name = @Platform_Name)
	if @temp = 0
	begin
		BEGIN TRY
			INSERT INTO [dbo].[Platforms]
					(Platform_Name)
				VALUES
					(@Platform_Name)
		END TRY

		BEGIN CATCH
			raiserror('Error',1,1)
		END CATCH

	end else begin
		raiserror('Duplicate data',1,1)
	end

ENd
GO
/****** Object:  StoredProcedure [dbo].[spUpdateIterations]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[spUpdateIterations](
	@iteration_Id int,
	@product_Id smallint,
	@version_code nchar(30),
	@version_description nchar(100),
	@version_date nchar(10),
	@platform_Id tinyint)
AS

BEGIN
	DECLARE @temp int = (select count(*) from Iterations where  
				iteration_Id = @iteration_Id )
	if @temp > 0
	begin
		BEGIN TRY
			SET NOCOUNT ON;

				UPDATE [dbo].[Iterations]
					SET [product_Id] = @product_Id, 
						[version_code] = @version_code,
						[version_description] = @version_description,
						[version_date] = @version_date,
						[platform_Id] = @platform_Id
					  	where iteration_Id = @iteration_Id
		END try

		BEGIN CATCH
			raiserror('Error',1,1)
		END CATCH

	end else begin
		raiserror('Duplicate data',1,1)
	end

END
GO
/****** Object:  Table [dbo].[address]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[address](
	[address_id] [int] NOT NULL,
	[street] [nvarchar](50) NOT NULL,
	[city_id] [int] NOT NULL,
	[state_id] [int] NULL,
	[country_id] [int] NULL,
	[zipcode] [nchar](10) NULL,
 CONSTRAINT [PK_address] PRIMARY KEY CLUSTERED 
(
	[address_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[authenticate]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[authenticate](
	[customer_id] [int] NOT NULL,
	[username] [nchar](50) NOT NULL,
	[password] [nchar](50) NOT NULL,
	[date] [nchar](10) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[branch]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[branch](
	[branch_id] [int] NOT NULL,
	[platform_id] [int] NOT NULL,
	[product_id] [int] NULL,
	[branch_code] [nvarchar](20) NULL,
	[download_link] [nvarchar](50) NOT NULL,
	[release_type_id] [int] NOT NULL,
	[release_date] [nchar](10) NOT NULL,
	[end_date] [nchar](10) NOT NULL,
 CONSTRAINT [PK_branch] PRIMARY KEY CLUSTERED 
(
	[branch_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[city]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[city](
	[city_id] [int] NOT NULL,
	[city_name] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_city] PRIMARY KEY CLUSTERED 
(
	[city_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[country]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[country](
	[country_id] [int] NOT NULL,
	[country_name] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_country] PRIMARY KEY CLUSTERED 
(
	[country_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[customer]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer](
	[customer_id] [int] NOT NULL,
	[name] [nvarchar](30) NOT NULL,
	[lastname] [nvarchar](20) NOT NULL,
	[email] [nvarchar](40) NOT NULL,
	[company_name] [nvarchar](50) NOT NULL,
	[address_id] [int] NULL,
 CONSTRAINT [PK_customer] PRIMARY KEY CLUSTERED 
(
	[customer_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[customer_phone]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[customer_phone](
	[customer_id] [int] NOT NULL,
	[phone_id] [int] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[download_history]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[download_history](
	[download_id] [int] NOT NULL,
	[customer_id] [int] NOT NULL,
	[branch_id] [int] NOT NULL,
	[download_date] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_download_history] PRIMARY KEY CLUSTERED 
(
	[download_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[features]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[features](
	[iteration_id] [int] NOT NULL,
	[feature_id] [int] NOT NULL,
	[feature_description] [nvarchar](50) NOT NULL,
	[feature_create_date] [date] NOT NULL,
	[branch_id] [int] NULL,
 CONSTRAINT [PK_features] PRIMARY KEY CLUSTERED 
(
	[feature_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[iterations]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[iterations](
	[iteration_id] [int] NOT NULL,
	[product_id] [int] NOT NULL,
	[version_code] [nvarchar](20) NOT NULL,
	[version_description] [nvarchar](200) NOT NULL,
	[version_date] [nvarchar](10) NOT NULL,
	[platform_id] [int] NOT NULL,
 CONSTRAINT [PK_iterations] PRIMARY KEY CLUSTERED 
(
	[iteration_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[phone]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[phone](
	[phone_id] [int] NOT NULL,
	[phone] [nvarchar](15) NOT NULL,
	[phone_type_id] [int] NOT NULL,
 CONSTRAINT [PK_phone] PRIMARY KEY CLUSTERED 
(
	[phone_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[phone_type]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[phone_type](
	[phone_type_id] [int] NOT NULL,
	[phone_type] [nvarchar](10) NOT NULL,
 CONSTRAINT [PK_phone_type] PRIMARY KEY CLUSTERED 
(
	[phone_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[platform]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[platform](
	[platform_id] [int] NOT NULL,
	[platform_name] [nvarchar](20) NOT NULL,
 CONSTRAINT [PK_platform] PRIMARY KEY CLUSTERED 
(
	[platform_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[product]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[product](
	[product_id] [int] NOT NULL,
	[product_name] [nvarchar](30) NOT NULL,
	[product_decription] [nvarchar](200) NULL,
	[product_create_date] [char](10) NOT NULL,
 CONSTRAINT [PK_product] PRIMARY KEY CLUSTERED 
(
	[product_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[release_type]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[release_type](
	[release_type_id] [int] NOT NULL,
	[release_type] [nchar](30) NOT NULL,
 CONSTRAINT [PK_release_type] PRIMARY KEY CLUSTERED 
(
	[release_type_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[state]    Script Date: 5/6/2016 3:34:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[state](
	[state_id] [int] NOT NULL,
	[state_name] [nvarchar](30) NOT NULL,
 CONSTRAINT [PK_state] PRIMARY KEY CLUSTERED 
(
	[state_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[address]  WITH CHECK ADD  CONSTRAINT [FK_address_city] FOREIGN KEY([city_id])
REFERENCES [dbo].[city] ([city_id])
GO
ALTER TABLE [dbo].[address] CHECK CONSTRAINT [FK_address_city]
GO
ALTER TABLE [dbo].[address]  WITH CHECK ADD  CONSTRAINT [FK_address_country] FOREIGN KEY([country_id])
REFERENCES [dbo].[country] ([country_id])
GO
ALTER TABLE [dbo].[address] CHECK CONSTRAINT [FK_address_country]
GO
ALTER TABLE [dbo].[address]  WITH CHECK ADD  CONSTRAINT [FK_address_state] FOREIGN KEY([state_id])
REFERENCES [dbo].[state] ([state_id])
GO
ALTER TABLE [dbo].[address] CHECK CONSTRAINT [FK_address_state]
GO
ALTER TABLE [dbo].[authenticate]  WITH CHECK ADD  CONSTRAINT [FK_authenticate_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[customer] ([customer_id])
GO
ALTER TABLE [dbo].[authenticate] CHECK CONSTRAINT [FK_authenticate_customer]
GO
ALTER TABLE [dbo].[branch]  WITH CHECK ADD  CONSTRAINT [FK_branch_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[product] ([product_id])
GO
ALTER TABLE [dbo].[branch] CHECK CONSTRAINT [FK_branch_product]
GO
ALTER TABLE [dbo].[branch]  WITH CHECK ADD  CONSTRAINT [FK_branch_release_type] FOREIGN KEY([release_type_id])
REFERENCES [dbo].[release_type] ([release_type_id])
GO
ALTER TABLE [dbo].[branch] CHECK CONSTRAINT [FK_branch_release_type]
GO
ALTER TABLE [dbo].[customer]  WITH CHECK ADD  CONSTRAINT [FK_customer_address] FOREIGN KEY([address_id])
REFERENCES [dbo].[address] ([address_id])
GO
ALTER TABLE [dbo].[customer] CHECK CONSTRAINT [FK_customer_address]
GO
ALTER TABLE [dbo].[customer_phone]  WITH CHECK ADD  CONSTRAINT [FK_customer_phone_customer1] FOREIGN KEY([customer_id])
REFERENCES [dbo].[customer] ([customer_id])
GO
ALTER TABLE [dbo].[customer_phone] CHECK CONSTRAINT [FK_customer_phone_customer1]
GO
ALTER TABLE [dbo].[customer_phone]  WITH CHECK ADD  CONSTRAINT [FK_customer_phone_phone] FOREIGN KEY([phone_id])
REFERENCES [dbo].[phone] ([phone_id])
GO
ALTER TABLE [dbo].[customer_phone] CHECK CONSTRAINT [FK_customer_phone_phone]
GO
ALTER TABLE [dbo].[customer_phone]  WITH CHECK ADD  CONSTRAINT [FK_customer_phone_phone1] FOREIGN KEY([phone_id])
REFERENCES [dbo].[phone] ([phone_id])
GO
ALTER TABLE [dbo].[customer_phone] CHECK CONSTRAINT [FK_customer_phone_phone1]
GO
ALTER TABLE [dbo].[download_history]  WITH CHECK ADD  CONSTRAINT [FK_download_history_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branch] ([branch_id])
GO
ALTER TABLE [dbo].[download_history] CHECK CONSTRAINT [FK_download_history_branch]
GO
ALTER TABLE [dbo].[download_history]  WITH CHECK ADD  CONSTRAINT [FK_download_history_customer] FOREIGN KEY([customer_id])
REFERENCES [dbo].[customer] ([customer_id])
GO
ALTER TABLE [dbo].[download_history] CHECK CONSTRAINT [FK_download_history_customer]
GO
ALTER TABLE [dbo].[features]  WITH CHECK ADD  CONSTRAINT [FK_features_branch] FOREIGN KEY([branch_id])
REFERENCES [dbo].[branch] ([branch_id])
GO
ALTER TABLE [dbo].[features] CHECK CONSTRAINT [FK_features_branch]
GO
ALTER TABLE [dbo].[features]  WITH CHECK ADD  CONSTRAINT [FK_features_iterations] FOREIGN KEY([iteration_id])
REFERENCES [dbo].[iterations] ([iteration_id])
GO
ALTER TABLE [dbo].[features] CHECK CONSTRAINT [FK_features_iterations]
GO
ALTER TABLE [dbo].[iterations]  WITH CHECK ADD  CONSTRAINT [FK_iterations_platform] FOREIGN KEY([platform_id])
REFERENCES [dbo].[platform] ([platform_id])
GO
ALTER TABLE [dbo].[iterations] CHECK CONSTRAINT [FK_iterations_platform]
GO
ALTER TABLE [dbo].[iterations]  WITH CHECK ADD  CONSTRAINT [FK_iterations_product] FOREIGN KEY([product_id])
REFERENCES [dbo].[product] ([product_id])
GO
ALTER TABLE [dbo].[iterations] CHECK CONSTRAINT [FK_iterations_product]
GO
ALTER TABLE [dbo].[phone]  WITH CHECK ADD  CONSTRAINT [FK_phone_phone_type] FOREIGN KEY([phone_type_id])
REFERENCES [dbo].[phone_type] ([phone_type_id])
GO
ALTER TABLE [dbo].[phone] CHECK CONSTRAINT [FK_phone_phone_type]
GO
USE [master]
GO
ALTER DATABASE [s16guest01] SET  READ_WRITE 
GO
