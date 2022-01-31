-- Let's do some cleaning of the data. We will start by seeing whether or not we have duplicates in our table. We will use a CTE to do so.

-- Let's add a new id column.



Alter Table scraped_jobs
Add id Int Identity(1, 1)
Go

select * from scraped_jobs

WITH CTE([JobTitle], 
    [Company], 
    [JobLocation],
	[Today],
	[JobSummary],
	[JobSalary],
    duplicatecount)
AS (SELECT [JobTitle], 
		   [Company], 
		   [JobLocation],
		   [Today],
		   [JobSummary],
	       [JobSalary], 
           ROW_NUMBER() OVER(PARTITION BY [JobTitle], 
										  [Company], 
										  [JobLocation],
										  [Today],
										  [JobSummary],
										  [JobSalary]
           ORDER BY id) AS DuplicateCount
    FROM scraped_jobs)
SELECT *
FROM CTE;

-- Any row that has a value of [DuplicateCount] greater than 1, it is a duplicate row. Thus, we should delete these:

WITH CTE([JobTitle], 
    [Company], 
    [JobLocation],
	[Today],
	[JobSummary],
	[JobSalary],
    duplicatecount)
AS (SELECT [JobTitle], 
		   [Company], 
		   [JobLocation],
		   [Today],
		   [JobSummary],
	       [JobSalary], 
           ROW_NUMBER() OVER(PARTITION BY [JobTitle], 
										  [Company], 
										  [JobLocation],
										  [Today],
										  [JobSummary],
										  [JobSalary]
           ORDER BY id) AS DuplicateCount
    FROM scraped_jobs)
DELETE FROM CTE
WHERE DuplicateCount > 1;

-- 188 duplicate rows have been eliminated.

-- Let's now split the JobLocation column as it sometimes includes information about the work modality of the role(remote, temporarily remote...) and the zip code.
-- Creating a WorkModality and ZipCode column

ALTER TABLE scraped_jobs
ADD WorkModality nvarchar(255)

ALTER TABLE scraped_jobs
ADD ZipCode nvarchar(255)

-- Updating the WorkModality and JobLocation column values by leveraging a Case Statement and the Substring and Charindex functions.

UPDATE scraped_jobs  
SET WorkModality = CASE WHEN CHARINDEX('•', JobLocation) > 0  
THEN SUBSTRING(JobLocation, CHARINDEX('•', JobLocation)+1, LEN(JobLocation)) 
ELSE 'unspecified'
END  

UPDATE scraped_jobs  
SET JobLocation = CASE WHEN CHARINDEX('•', JobLocation) > 0  
THEN SUBSTRING(JobLocation, 1, CHARINDEX('•', JobLocation)-1)
ELSE JobLocation  
END  


update scraped_jobs
set Zipcode = SUBSTRING(JobLocation,charindex(' ',JobLocation)+1, len(JobLocation))


update scraped_jobs
set ZipCode = case when JobLocation like '% %'
then ZipCode
else 'unspecified'
end;

--Labelling the ZipCode values that do not provide ZipCode information as 'unspecified'.

update scraped_jobs
set ZipCode = case when ZipCode like '%loc%'
then 'unspecified'
else ZipCode
end

update scraped_jobs
set ZipCode = case when ZipCode like 'king%'
then 'unspecified'
else ZipCode
end

--Cleaning the JobLocation column to extract only the city where the role is based.

UPDATE scraped_jobs  
SET JobLocation = CASE WHEN CHARINDEX(' ', JobLocation) > 0  
THEN SUBSTRING(JobLocation, 1, charindex(' ',JobLocation))
ELSE JobLocation  
END 

update scraped_jobs
set JobLocation = case when JobLocation like '%+%'
then SUBSTRING(JobLocation, 1, charindex('+',JobLocation)-1)
else JobLocation
end

--Updating the 'United Kingdom' locations to 'Nationwide'.

update scraped_jobs
set JobLocation = case when JobLocation like '%uni%'
then 'Nationwide'
else JobLocation
end

select * from scraped_jobs

-- I realized the job salary, when specified, is given in either daily or yearly rate. Thus, for us to be able to make a sensible comparison, the yearly and daiy rates should have its own columns.

-- Creating a yearly and daily salary column.

select JobSalary
from scraped_jobs
where JobSalary like '%year%'

ALTER TABLE scraped_jobs
ADD YearlySalary nvarchar(255)

ALTER TABLE scraped_jobs
ADD DailySalary nvarchar(255)

Update scraped_jobs
set YearlySalary = case when JobSalary like '%year%'
then JobSalary
else null
end

Update scraped_jobs
set DailySalary = case when JobSalary like '%day%'
then JobSalary
else null
end

-- Splitting the ranges to Upper and Lower range for both the DailySalary and YearlySalary columns.

-- DailySalary column. 

ALTER TABLE scraped_jobs
ADD DailySalary_Upper nvarchar(255)

Update scraped_jobs
set DailySalary_Upper = SUBSTRING(DailySalary, charindex('£',DailySalary)+1, charindex('a',DailySalary)-2)

Update scraped_jobs
set DailySalary_Upper = case when  DailySalary_Upper like'%£%'
then SUBSTRING(DailySalary_Upper, charindex('£',DailySalary_Upper)+1, len(DailySalary_Upper))
else DailySalary_Upper
end

ALTER TABLE scraped_jobs
ADD DailySalary_Lower nvarchar(255)

Update scraped_jobs
set DailySalary_Lower = SUBSTRING(DailySalary, charindex('£',DailySalary)+1, charindex('-',DailySalary))

Update scraped_jobs
set DailySalary_Lower = trim(replace(DailySalary_Lower,'-',' '))


select * from scraped_jobs

-- Dropping unnecessary columns.

ALTER TABLE scraped_jobs
DROP COLUMN DailySalary

-- YearlySalary column.

ALTER TABLE scraped_jobs
ADD YearlySalary_Upper nvarchar(255)
ALTER TABLE scraped_jobs
ADD YearlySalary_Lower nvarchar(255)

Update scraped_jobs
set YearlySalary_Upper = SUBSTRING(YearlySalary, charindex('£',YearlySalary)+1, charindex('a',YearlySalary)-2)

Update scraped_jobs
set YearlySalary_Upper = case when  YearlySalary_Upper like'%£%'
then SUBSTRING(YearlySalary_Upper, charindex('£',YearlySalary_Upper)+1, len(YearlySalary_Upper))
else YearlySalary_Upper
end


Update scraped_jobs
set YearlySalary_Lower = SUBSTRING(YearlySalary, charindex('£',YearlySalary)+1, charindex('-',YearlySalary))

Update scraped_jobs
set YearlySalary_Lower = trim(replace(YearlySalary_Lower,'-',' '))

Update scraped_jobs
set YearlySalary_Upper = case when  YearlySalary_Upper like'%a ye%'
then SUBSTRING(YearlySalary_Upper,1, charindex('a',YearlySalary_Upper)-1)
else YearlySalary_Upper
end

-- Dropping unnecessary columns.

ALTER TABLE scraped_jobs
DROP COLUMN YearlySalary

ALTER TABLE scraped_jobs
DROP COLUMN JobSalary

-- How many of the role are 'Senior' positions? These roles should be removed as I do not have the experience required for those jobs.

Select Count(*) as senior_roles
from scraped_jobs
where JobTitle LIKE '%enior%'

-- There are 68 Senior roles. Let's delete them.

DELETE FROM scraped_jobs WHERE JobTitle LIKE '%enior%';

-- Insights

-- What is the percentage of jobs that are remote?

Select WorkModality, ROUND(count(*) * 100.0 / sum(count(*)) over(),2) as percentage_of_total
from scraped_jobs
group by WorkModality 

-- 10.31% of jobs are fully remote, while 5.73% are temporarily remote, to what we could assume will change back to on-site or hybrid once the covid rules ease up.

-- How many jobs are based in Edinburgh or Glasgow?

Select JobLocation, count(*) as number_of_jobs
from scraped_jobs
where JobLocation IN ('Edinburgh','Glasgow')
group by JobLocation

-- 120 jobs are based in Edinburgh, while 76 are based in the neighboring city of Glasgow.

-- What is the company with the greatest amount of job postings?

Select Top(1) Company, count(*) as number_of_jobs_per_company
from scraped_jobs
group by Company
Order by number_of_jobs_per_company desc

-- With a total of 11 job postings, Barclays is the company with the most job openings.

-- Of the specified salary ranges, what are the average daily and average yearly?

-- Casting the Salary columns to integers so that aggregation function can be used on them.

ALTER TABLE scraped_jobs
ALTER COLUMN DailySalary_Upper int;

ALTER TABLE scraped_jobs
ALTER COLUMN DailySalary_Lower int;

ALTER TABLE scraped_jobs
ALTER COLUMN YearlySalary_Upper int;

-- The statement above is giving an error "Conversion failed when converting the nvarchar value '31,636 ' to data type int". Thus, we will need to replace the ',' with a '' so that the fields can be casted.

update scraped_jobs
set YearlySalary_Upper = replace(YearlySalary_Upper, ',', '')

-- The same with the YearlySalary_Lower field.

update scraped_jobs
set YearlySalary_Lower = replace(YearlySalary_Lower, ',', '')

ALTER TABLE scraped_jobs
ALTER COLUMN YearlySalary_Lower int;

--Verifying they have all been casted to int type.

exec sp_help scraped_jobs

-- Performing the calculations.

Select AVG(DailySalary_Upper) as average_daily_lower,
AVG(DailySalary_Lower) as average_daily_lower,
(AVG(DailySalary_Upper)+ AVG(DailySalary_Lower))/2 as average_daily,
AVG(YearlySalary_Upper) as average_yearly_upper,
AVG(YearlySalary_Lower) as average_yearly_lower,
(AVG(YearlySalary_Upper)+ AVG(YearlySalary_Lower))/2 as average_yearly
from scraped_jobs
where DailySalary_Upper is not null OR DailySalary_Lower is not null OR YearlySalary_Upper is not null OR YearlySalary_Lower is not null

-- The average daily salary is £311 and the average yearly wage is £31,902.


-- For the locations considered, what are the top three jobs with the highest compensation?

-- For this, I will first need to convert the daily figures into yearly. I will do this by multiplying the daily salaries into 20 working days that are in a month and 12 months in a year to get the yearly numbers.

ALTER TABLE scraped_jobs
ADD calculated_yearlysalary int;


UPDATE scraped_jobs
SET calculated_yearlysalary = DailySalary_Upper * 20 * 12;

-- Now, let's find the top 10 highest paying jobs. I will find the maximum salary from both the Yearly salaries and the Daily values translated into Yearly figures.

SELECT 
   TOP(10) JobTitle, JobLocation, 
   (SELECT MAX(highestsalary)
      FROM (VALUES (YearlySalary_Upper),(calculated_yearlysalary)) AS Salary(highestsalary)) 
   AS highestsalary
FROM scraped_jobs
Group by JobLocation, YearlySalary_Upper, calculated_yearlysalary, JobTitle
Order by highestsalary desc

-- The highest paying job if a BI Developer (Power BI) based in Glasgow, with a pay equivalent to £120k a year. The salaries range from £65k, all the way up to £120k.