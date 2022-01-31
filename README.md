# [Indeed UK Job Scraper](https://github.com/davidgomezpr1/Indeed_Job_Scraper)
![](https://images.unsplash.com/photo-1487528278747-ba99ed528ebc?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80)

## Motivation

As a Data Analyst looking for a new data analysis role, I was finding it difficult to research the job market in Scotland, where I am currently based. Then I remembered that I am a Data Analyst and decided to kill two birds with one stone by creating something that would allow me to research the market while also demonstrating my data skills, which could prove useful in the process. So, after some research, I discovered that Indeed UK was the preferred website for employers, and I decided to write a pipeline in Python to extract job postings that met my search criteria, based on job title and location. The result will then be imported in the shape of a SQL Table to MS SQL Server where I would carry out some data wrangling and some data analysis. Finally, the cleaned data will be imported to Power BI, where I will build an interactive dashboard. 

I was particularly interested in learning the percentage of remote jobs available, the number of jobs available in the main Scottish cities of Edinburgh and Glasgow, the company that hired the most positions, the average salary I should expect and aim for, and the top ten highest paying jobs, so that I could focus on what the requirements are and perhaps get an idea of what I should learn next.

## Overview

- Creation of code in Python that web-scrapes job listings from Indeed UK.
- Due to concerns that a job of interest would slip right through without my noticing, the extracted postings would then be manually reviewed, disregarding the possibility of automating the entire process.
- Importing the values into a SQL Server table to carry out dat wrangling and data analysis.
- Connecting SQL Server to Power BI to build an interactive dashboard.

## Conclusions

- 518 rows were initially extracted by the web-scraper after running the main function with the desired attributes (JobTitle = 'data analysis', JobLocation = 'scotland').
- Once in SQL, duplicate rows were dealt with, elimination a total of 188 duplicate rows.
- Data was cleaned by adding new columns, splitting values in existing columns and removing those that were no longer needed.
- 9.7% of jobs are fully remote, while 5.15% are temporarily remote, which we would assume will change back to on-site or hybrid once the covid rules ease up.
- 168 jobs are based in Edinburgh, while approximately half that are based in the city of Glasgow.
- I learned that, with a total of 12 job postings, Barclays is the company with the most job openings.
- The average daily salary is £293 and the average yearly wage is £34,084.
- 'Senior' positions were removed as I am underqualified for these.
- The top 10 highest paying jobs have a salary range of £ to £ .
 
