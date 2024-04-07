-- Error Code: 1175. You are using safe update mode and you tried to update a table without a WHERE that uses a KEY column.  
##To disable safe mode, toggle the option in Preferences -> SQL Editor and reconnect.
##Or following code will do the needful.
SET SQL_SAFE_UPDATES = 0; 

-- Set wait_timeout to 600 seconds (10 minutes)
SET GLOBAL wait_timeout = 600;

-- Set interactive_timeout to 600 seconds (10 minutes)
SET GLOBAL interactive_timeout = 600;



#Drop the Customer Churn Schema if already exists
DROP SCHEMA IF EXISTS Customer_Churn;

#Create Schema
CREATE SCHEMA Customer_Churn;

#selecting Custoemr_Churn schema
USE Customer_Churn;

#drop Customer table if alredy exists
DROP TABLE IF EXISTS Customer;

#table can be created manually or use import wizard
CREATE TABLE Customer (
customer_id VARCHAR(100),
cust_Name VARCHAR(100),
age INT,
gender CHAR(50),
security_no VARCHAR(100),
region_category VARCHAR(100),
membership_category VARCHAR(100),
joining_date DATE, #yyyy-mm-dd format is used in MySQL
joined_through_referral CHAR(100),
referral_id VARCHAR(100),
preferred_offer_types VARCHAR(100),
medium_of_operation VARCHAR(100),
internet_option VARCHAR(100),
last_visit_time TIME, #hh:mm:ss format is used by MySQL
days_since_last_login INT, 
avg_time_spent DOUBLE,
avg_transaction_value DOUBLE,
avg_frequency_login_days VARCHAR(100),
points_in_wallet VARCHAR(100),
used_special_discount CHAR(100),
offer_application_preference CHAR(100),
past_complaint CHAR(50),
complaint_status VARCHAR(100),
feedback VARCHAR(100),
churn_risk_score INT
);

#DO NOT EXECUTE FOLLOWING COMMANDS UNLESS YOU IMPORT THE DATA USING IMPORT WIZARD.
#IF YOU DO NOT KNOW HOW TO USE IMPORT WIZARD ON MYSQL, PLEASE FOLLOW BELOW STEPS
#Data import wizard steps:
# 1.	Expand Schema, Expand Tables
# 2.	Right Click on the table in which data will be imported
# 3.	Select Table Data Import Wizard
# 4.	Browse for the CSV file to import
# 5.	Select apppriate destination columns and complete import

#Verify inserted data
SELECT COUNT(*) AS Observations
FROM Customer
ORDER BY Observations DESC;

SELECT * 
FROM Customer
LIMIT 10;

#How to handle Null or missing data?
#If table has only Null values use COALESCE otherwise

SELECT COUNT(*) - COUNT(COALESCE(cust_Name,	age,	gender,	
								security_no,	region_category,	membership_category,	joining_date,	
                                joined_through_referral,	referral_id,	preferred_offer_types,	medium_of_operation,	
                                internet_option,	last_visit_time,	days_since_last_login,	avg_time_spent,	avg_transaction_value,	
                                avg_frequency_login_days,	points_in_wallet,	used_special_discount,	offer_application_preference,	
                                past_complaint,	complaint_status,	feedback,	churn_risk_score)) AS total_null_count
FROM Customer; #There are no blank values or trailing spaces, so need to perfom null check with CASE

#If table has blank values then use (Case WHEN THEN) 
#following query handles both null and blank records
SELECT 
    SUM(CASE WHEN cust_Name = '' OR cust_Name IS NULL THEN 1 ELSE 0 END) AS blank_cust_Name,
    SUM(CASE WHEN age = '' OR age IS NULL THEN 1 ELSE 0 END) AS blank_age,
    SUM(CASE WHEN gender = '' OR gender IS NULL THEN 1 ELSE 0 END) AS blank_gender,
    SUM(CASE WHEN security_no = '' OR security_no IS NULL THEN 1 ELSE 0 END) AS blank_security_no,
    SUM(CASE WHEN region_category = '' OR region_category IS NULL THEN 1 ELSE 0 END) AS blank_region_category,
    SUM(CASE WHEN membership_category = '' OR membership_category IS NULL THEN 1 ELSE 0 END) AS blank_membership_category,
    SUM(CASE WHEN joined_through_referral = '' OR joined_through_referral IS NULL THEN 1 ELSE 0 END) AS blank_joined_through_referral,
    SUM(CASE WHEN referral_id = '' OR referral_id IS NULL THEN 1 ELSE 0 END) AS blank_referral_id,
    SUM(CASE WHEN preferred_offer_types = '' OR preferred_offer_types IS NULL THEN 1 ELSE 0 END) AS blank_preferred_offer_types,
    SUM(CASE WHEN medium_of_operation = '' OR medium_of_operation IS NULL THEN 1 ELSE 0 END) AS blank_medium_of_operation,
    SUM(CASE WHEN internet_option = '' OR internet_option IS NULL THEN 1 ELSE 0 END) AS blank_internet_option,
    SUM(CASE WHEN last_visit_time = '' OR last_visit_time IS NULL THEN 1 ELSE 0 END) AS blank_last_visit_time,
    SUM(CASE WHEN days_since_last_login = '' OR days_since_last_login IS NULL THEN 1 ELSE 0 END) AS blank_days_since_last_login,
    SUM(CASE WHEN avg_time_spent = '' OR avg_time_spent IS NULL THEN 1 ELSE 0 END) AS blank_avg_time_spent,
    SUM(CASE WHEN avg_transaction_value = '' OR avg_transaction_value IS NULL THEN 1 ELSE 0 END) AS blank_avg_transaction_value,
    SUM(CASE WHEN avg_frequency_login_days = '' OR avg_frequency_login_days IS NULL THEN 1 ELSE 0 END) AS blank_avg_frequency_login_days,
    SUM(CASE WHEN points_in_wallet = '' OR points_in_wallet IS NULL THEN 1 ELSE 0 END) AS blank_points_in_wallet,
    SUM(CASE WHEN used_special_discount = '' OR used_special_discount IS NULL THEN 1 ELSE 0 END) AS blank_used_special_discount,
    SUM(CASE WHEN offer_application_preference = '' OR offer_application_preference IS NULL THEN 1 ELSE 0 END) AS blank_offer_application_preference,
    SUM(CASE WHEN past_complaint = '' OR past_complaint IS NULL THEN 1 ELSE 0 END) AS blank_past_complaint,
    SUM(CASE WHEN complaint_status = '' OR complaint_status IS NULL THEN 1 ELSE 0 END) AS blank_complaint_status,
    SUM(CASE WHEN feedback = '' OR feedback IS NULL THEN 1 ELSE 0 END) AS blank_feedback,
    SUM(CASE WHEN churn_risk_score = '' OR churn_risk_score IS NULL THEN 1 ELSE 0 END) AS blank_churn_risk_score
FROM Customer;

#replacing blank values with respecitve column's mode/NA value
UPDATE Customer
SET preferred_offer_types = 'Not_Available'
WHERE preferred_offer_types = '' OR preferred_offer_types IS NULL; #288 blank values

UPDATE Customer
SET region_category = 'Town'
WHERE region_category = '' OR region_category IS NULL; #5428 blank values

#Calculating mean of 'points_in_wallet' to replace 3443 NULL values
/*SELECT ROUND(AVG(points_in_wallet),0)
FROM Customer; #mean is 623*/
UPDATE Customer
SET points_in_wallet = (
    SELECT AVG(wallet)
    FROM (
        SELECT points_in_wallet AS wallet
        FROM Customer
        WHERE points_in_wallet IS NOT NULL
    ) AS subquery
)
WHERE points_in_wallet IS NULL OR points_in_wallet = '';

SELECT ROUND(points_in_wallet,0) AS Points,
		COUNT(*) AS 'Number of Customers'
FROM Customer
GROUP BY Points
ORDER BY 'Number of Customers' DESC;


#Medium of Operations and Joined through reference have question mark '?' value.
#replacing Medium of Operations column ? with tablet and Joined through reference ? with Not Available

UPDATE Customer
SET joined_through_referral = 'NA'
WHERE joined_through_referral = '?';

UPDATE Customer
SET medium_of_operation = 'Tablet'
WHERE medium_of_operation = '?';

#medium_of_operation device type Both is ambiguous, so let's update it with Both-Desktop and Smartphone
UPDATE Customer
SET medium_of_operation = 'Desktop and Smartphone'
WHERE medium_of_operation = 'Both';

#Verify the update
SELECT medium_of_operation AS 'Types of Devices Used',
		Count(*) AS Count
FROM Customer
GROUP BY medium_of_operation
ORDER BY Count DESC;

#referral_id has 'xxxxxxxx' records, let's change these values to random values
UPDATE Customer
SET referral_id = CONCAT('CID', 1300) 
WHERE referral_id = 'xxxxxxxx';

#verify the update
SELECT COUNT(*) AS 'Referral IDs with CID1300'
FROM Customer
WHERE referral_id = 'CID1300';


# Normalization
#I will create 4 new tables to perform normalization.
#1. Main table Customer 2. Complaints 3. Customer_Preferrences 4. Customer_Activity 5. Membership 

#Drop if already exists
DROP TABLE IF EXISTS Complaints;

#Complaint table
CREATE TABLE Complaints(
CPK INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
customer_id VARCHAR(100),
past_complaint CHAR(50),
complaint_status VARCHAR(100),
feedback VARCHAR(100)
);

#Updating Complain Primary Key to begin with 1001 Auto Increment
ALTER TABLE Complaints
AUTO_INCREMENT = 1001;

#Inserting data into Complaints from Customer table
INSERT INTO Complaints(customer_id, past_complaint, complaint_status, feedback)
SELECT DISTINCT customer_id, past_complaint, complaint_status, feedback #distinct will make sure that repeated customer_id will have the same CPK id
FROM Customer;

#Verifying the insert
SELECT * FROM Complaints; #CPK will show 37992 as we are starting Auto increment from 1001 instead of 1


##Adding Foreign key reference

#Create reference column in Customer table
ALTER TABLE Customer
ADD COLUMN Complaint_key INT NULL;

#Linking Customer and Complaint table
UPDATE Customer cu, Complaints co 
SET cu.Complaint_key = co.CPK
WHERE cu.customer_id = co.customer_id; #this query might show output response as lost connection with server, 
										#if so please restart the connection or MYSQL app 

/*
UPDATE Customer cu
SET cu.Complaint_key = (
  SELECT co.CPK FROM Complaints co 
  WHERE cu.customer_id = co.customer_id
)
WHERE cu.customer_id IN (
  SELECT customer_id FROM (
    SELECT cu.customer_id FROM Customer cu
    JOIN Complaints co ON cu.customer_id = co.customer_id
    LIMIT 1000
  ) tmp
);*/ #batch processing

SELECT * FROM Customer
LIMIT 5;

#Dropping past_complaint, complaint_status, feedback from Customer table
ALTER TABLE Customer
DROP COLUMN past_complaint,
DROP COLUMN complaint_status,
DROP COLUMN feedback;

#Foreign key setup
ALTER TABLE Customer
ADD FOREIGN KEY (Complaint_key) REFERENCES Complaints (CPK);


#Drop if aleady exists
DROP TABLE IF EXISTS Membership;

#Create membership table
CREATE TABLE Membership(
MPK INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
preferred_offer_types VARCHAR(100),
Membership_Category VARCHAR(100),
Referred CHAR(100),
referral_id VARCHAR(100),
Customer_ID VARCHAR(100)
);

#Set Primary key start to 101
ALTER TABLE Membership
AUTO_INCREMENT = 1001;

#Insert data into Membership table from Customer
INSERT INTO Membership( preferred_offer_types, Membership_Category, Referred, referral_id, Customer_ID)
SELECT DISTINCT  preferred_offer_types, membership_category, joined_through_referral, referral_id, customer_id
FROM Customer;

#Verifying Membership table data
SELECT * FROM Membership
WHERE Customer_ID = 'fffe4300490044003600300030003800';

##Adding Foreign key reference 
ALTER TABLE Customer
ADD COLUMN Membership_key INT;

#Link Customer and Membership tables
UPDATE Customer cu, Membership me
SET cu.Membership_key = me.MPK
WHERE cu.customer_id = me.Customer_ID; 

#verifying the link
SELECT * FROM Customer
LIMIT 5;

#Delete Membership columns from the customre table
ALTER TABLE Customer
DROP COLUMN preferred_offer_types,
DROP COLUMN membership_category, 
DROP COLUMN joined_through_referral,
DROP COLUMN referral_id;

#Foreign key reference added to Customer table
ALTER TABLE Customer
ADD FOREIGN KEY (Membership_key) REFERENCES Membership (MPK);

##Create Customer_Preferrences table

#Drop if already exists
DROP TABLE IF EXISTS Customer_Preferrences;

#Create table Customer_Preferrences
CREATE TABLE Customer_Preferrences(
CPPK INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
Customer_ID VARCHAR(100),
medium_of_operation	VARCHAR(100),
internet_option VARCHAR(100)
);

#Set Auto_Increment starting with 1001
ALTER TABLE Customer_Preferrences
AUTO_INCREMENT = 101;

#Insert data into Customer_Preferrences
INSERT INTO Customer_Preferrences(Customer_ID, medium_of_operation, internet_option)
SELECT DISTINCT customer_id, medium_of_operation, internet_option
FROM Customer;

#Verify the data from Customer_Preferrences
SELECT * FROM Customer_Preferrences
LIMIT 5;

#Add foreign key reference into Customer
ALTER TABLE Customer
ADD COLUMN Preferrence_Key INT NULL;

#Link Customer_Preferrences and Customer
 UPDATE Customer cu, Customer_Preferrences cp
 SET cu.Preferrence_Key = cp.CPPK
 WHERE cu.customer_id = cp.Customer_ID;
 
 SELECT * FROM Customer
 LIMIT 5;
 
 #Delete preferred_offer_types, medium_of_operation, internet_option from Customer
 ALTER TABLE Customer
 DROP COLUMN preferred_offer_types, 
 DROP COLUMN medium_of_operation, 
 DROP COLUMN internet_option;
 
 #Setup foreign key reference
 ALTER TABLE Customer
 ADD FOREIGN KEY (Preferrence_Key) REFERENCES Customer_Preferrences (CPPK);
 
 ##Create table Customer_Activity 
 
 #delete if already exists
 
 DROP TABLE IF EXISTS Customer_Activity;
 
 CREATE TABLE Customer_Activity(
customer_id VARCHAR(100),
APK INT NOT NULL PRIMARY KEY AUTO_INCREMENT, 
last_visit_time TIME, #hh:mm:ss format is used by MySQL
days_since_last_login INT, 
avg_time_spent DOUBLE,
avg_transaction_value DOUBLE,
avg_frequency_login_days VARCHAR(100),
points_in_wallet VARCHAR(100),
used_special_discount CHAR(100),
offer_application_preference CHAR(100),
churn_risk_score INT
 );
 
#set auto increment to 1001
ALTER TABLE Customer_Activity
AUTO_INCREMENT = 1001;
 
#insert into Customer_Activity
INSERT INTO Customer_Activity (customer_id, last_visit_time, days_since_last_login,	avg_time_spent,	avg_transaction_value, 
								avg_frequency_login_days, points_in_wallet, used_special_discount, offer_application_preference, 
                                churn_risk_score)
SELECT DISTINCT customer_id, last_visit_time, days_since_last_login,	avg_time_spent,	avg_transaction_value, 
				avg_frequency_login_days, points_in_wallet, used_special_discount, offer_application_preference, churn_risk_score
FROM Customer;

#verify Customer_Activity
SELECT * FROM Customer_Activity
LIMIT 5;

#create Activity_key column in Customer table
ALTER TABLE Customer
ADD COLUMN Activity_key INT NULL;

SELECT * FROM Customer
LIMIT 5; 

#setup reference between Customer and Customer_Activity
UPDATE Customer cu, Customer_Activity ca
SET cu.Activity_key = ca.APK
WHERE cu.customer_id = ca.customer_id;
 
#Delete columns from Customer table
ALTER TABLE Customer
DROP COLUMN last_visit_time, 
DROP COLUMN days_since_last_login,	
DROP COLUMN avg_time_spent,	
DROP COLUMN avg_transaction_value, 
DROP COLUMN avg_frequency_login_days, 
DROP COLUMN points_in_wallet, 
DROP COLUMN used_special_discount, 
DROP COLUMN offer_application_preference, 
DROP COLUMN churn_risk_score;

#foreign key reference established
ALTER TABLE Customer
ADD FOREIGN KEY (Activity_key) REFERENCES Customer_Activity (APK);

ALTER TABLE Customer_Activity
MODIFY COLUMN points_in_wallet BIGINT;

SELECT COUNT(*) AS Counts,
		avg_frequency_login_days AS Login
FROM Customer_Activity
GROUP BY Login;
		

#avg_frequency_login_days in Customer_Activity contains ERROR 
UPDATE Customer_Activity
SET avg_frequency_login_days = (
								SELECT AVG(avg_frequency_login_days)
								FROM (
										SELECT avg_frequency_login_days
										FROM Customer_Activity
										WHERE avg_frequency_login_days != 'Error'
									)AS subquery
								)
WHERE avg_frequency_login_days = 'Error';

ALTER TABLE Customer_Activity
MODIFY COLUMN avg_frequency_login_days DOUBLE;



###EDA
/*1. Customer segmentation and targeted marketing: By analyzing customer data such as demographics (age, gender), 
activity patterns (avg_transaction_value, avg_frequency_login_days), preferences (preferred_offer_types, medium_of_operation), 
and membership categories, businesses can segment customers into different groups and tailor their marketing strategies, 
promotional offers, and communication channels accordingly.
*/
-- Segment customers based on age and gender
SELECT gender AS Gender, age AS Age, COUNT(*) AS customer_count
FROM Customer
GROUP BY gender, age
ORDER BY customer_count DESC;

-- Segment customers based on membership category and activity level
SELECT m.Membership_Category AS 'Membership Category', 
								CONCAT('$',FORMAT(CEIL(AVG(ca.avg_transaction_value)),'##,###')) AS Avg_spend, 
                                CEIL(AVG(ca.avg_frequency_login_days)) AS Avg_login_frequency
FROM Customer c
JOIN Customer_Activity ca ON c.Membership_key = ca.APK
JOIN Membership m ON c.Membership_key = m.MPK
GROUP BY m.Membership_Category;

-- Marketing Analysis
/*Analyzing which marketing channels (joined_through_referral) and referral sources (referral_id) are most effective 
at acquiring new customers. I will also see which offers preferred_offer_types are most popular among different customer segments.
*/

SELECT referral_id, COUNT(*) AS Counts
FROM Membership
GROUP BY referral_id
HAVING COUNT(*) > 1
ORDER BY Counts DESC;

/*2. Customer retention and churn prevention: By monitoring customer activity (avg_time_spent, days_since_last_login), 
businesses can identify customers at risk of churning and take proactive measures to retain them, such as offering incentives, 
personalized communication, or addressing complaints (Customer_Chum.Complaints table).
*/

-- Identifying outlier
SELECT DISTINCT COUNT(*) AS 'Occurance', 
		days_since_last_login AS 'last login ago'
FROM Customer_Activity 
GROUP BY days_since_last_login
ORDER BY days_since_last_login ASC;

SELECT FLOOR(AVG(days_since_last_login))
FROM Customer_Activity
WHERE days_since_last_login != -999;

-- Identify customers at risk of churning based on inactivity
        #It could be new customers who never logged in, missing data, or any other meaning
		# Eliminate the outlier -999 
SELECT c.customer_id, c.cust_Name, ca.days_since_last_login
FROM Customer c
JOIN Customer_Activity ca ON c.Activity_key = ca.APK
WHERE ca.days_since_last_login != -999 -- Filter the outlier directly 
  AND ca.days_since_last_login > 12 #AVG days_since_last_login is 12
ORDER BY ca.days_since_last_login DESC;

/*3. Product and service improvement: By analyzing customer complaints (past_complaint, complaint_status, feedback) 
and preferences, businesses can identify areas for improvement in their products, services, or customer experience, 
and make data-driven decisions to address these issues.
*/

-- Analyze common complaints and feedback
SELECT complaint_status, COUNT(*) AS complaint_count, ROUND(AVG(LENGTH(feedback)),2) AS avg_feedback_length
FROM Complaints
GROUP BY complaint_status
ORDER BY complaint_count DESC;

-- Identify common complaints and feedback related to specific products or services
SELECT past_complaint AS 'Past Complaint', COUNT(*) AS 'Number of Complaints', AVG(LENGTH(feedback)) AS 'Avg feedback length'
FROM Complaints
WHERE past_complaint = 'Yes' AND (feedback LIKE ('%poor%') OR feedback LIKE ('%too%'))
GROUP BY past_complaint;

/*4. Risk assessment and fraud detection: By monitoring customer activity patterns (avg_transaction_value, avg_frequency_login_days) 
and security information (security_no), businesses can potentially identify suspicious behavior or fraudulent activities, 
enabling them to take appropriate measures to mitigate risks. 
This query provides a way to pinpoint customers who are either unusually high spenders or unusually infrequent in their login activity. 
This information could be valuable for targeted marketing campaigns or analyzing customer behavior patterns.
*/

-- Detect suspicious transaction patterns
	#By setting the threshold at 3 standard deviations away from the mean, 
    #it effectively filters for customers whose behavior falls outside the typical range.
SELECT c.cust_Name AS Customer, ca.avg_transaction_value As 'Avg Transation', ca.avg_frequency_login_days AS 'Avg login days'
FROM Customer c
JOIN Customer_Activity ca ON c.Activity_key = ca.APK
WHERE ca.avg_transaction_value > (SELECT AVG(avg_transaction_value) + 3 * STDDEV(avg_transaction_value) FROM Customer_Activity)
   OR ca.avg_frequency_login_days < (SELECT AVG(avg_frequency_login_days) - 3 * STDDEV(avg_frequency_login_days) FROM Customer_Activity)
GROUP BY Customer, ca.avg_transaction_value, ca.avg_frequency_login_days
ORDER BY ca.avg_transaction_value DESC, ca.avg_frequency_login_days ASC;


/*5. Customer lifetime value (CLV) analysis: By combining customer demographic data, activity patterns, 
and transaction history, businesses can calculate the lifetime value of each customer and prioritize 
their efforts towards retaining and growing their most valuable customer segments.
*/

-- Calculate customer lifetime value based on avg. transaction value and activity frequency
		# As we have churn score range between -1 and 5, the impact of churn risk is scaled between 0 and 1.  
        #A score of 1 means no influence, while a score of 5 completely reduces the CLV.
        # I assume a 20% discount was offered by the store maanger
SELECT c.cust_Name, 
       CONCAT('$', FORMAT(CEIL(ca.avg_transaction_value * ca.avg_frequency_login_days * (1 - (churn_risk_score + 1) / 6) * IF(used_special_discount = 'Yes', 0.8, 1)+0.0001),'##,###')) AS Estimated_CLV,
       DENSE_RANK() OVER (ORDER BY CEIL(ca.avg_transaction_value * ca.avg_frequency_login_days * (1 - (churn_risk_score + 1) / 6) * IF(used_special_discount = 'Yes', 0.8, 1)+ 0.0001) DESC) AS CLV_Rank
FROM Customer c
JOIN Customer_Activity ca ON c.Activity_key = ca.APK
WHERE region_category = 'Village' 
ORDER BY CLV_Rank ASC;


/*6. Personalization and recommendation systems: By leveraging 
customer preferences (preferred_offer_types, medium_of_operation), activity patterns, 
and demographic data, businesses can develop personalized recommendations for products, 
services, or content, enhancing the customer experience and increasing engagement.
*/

-- Recommend products based on customer preferences and activity
SELECT c.cust_Name AS Customer, m.preferred_offer_types AS 'Redeemed Offer', FLOOR(ca.avg_frequency_login_days) AS 'Avg login days'
FROM Customer c
JOIN Customer_Preferrences cp ON c.Preferrence_Key = cp.CPPK
JOIN Customer_Activity ca ON c.Activity_key = ca.APK
JOIN Membership m on c.Membership_key = m.MPK
WHERE ca.avg_frequency_login_days > (SELECT AVG(avg_frequency_login_days) FROM Customer_Activity)
ORDER BY ca.avg_frequency_login_days DESC;

-- Recommending services, products to customers who live in 'Village' 
	-- and have avg_transaction_value is greater than table Avg and points in wallet are greater than table Avg
SELECT c.cust_Name AS Customer, ca.avg_transaction_value AS 'Avg Transaction in $', ca.points_in_wallet AS 'Wallet Points'
FROM Customer c
JOIN Customer_Activity ca ON c.Activity_key = ca.APK
WHERE c.region_category = 'Village' AND (ca.points_in_wallet > (SELECT AVG(points_in_wallet) FROM Customer_Activity) AND (ca.avg_transaction_value > (SELECT AVG(avg_transaction_value) FROM Customer_Activity)))
ORDER BY ca.points_in_wallet DESC;







