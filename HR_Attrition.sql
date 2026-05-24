Create database hr_attrition;

use hr_attrition;

drop table employees

create table employees (
Age int not null,
Attrition varchar(5) not null,
BussinessTravel varchar(50) not null,
DailyRate int not null,
Department varchar(50) not null,
DistanceFromHome int not null,
Education int not null,
EducationField varchar(50) not null,
EmployeeNumber int not null,
EnviromentSatisfaction int not null,
Gender varchar(50) not null,
HourlyRate int not null,
JobInvolvement int not null,
JobLevel int not null,
JobRole varchar(50) not null,
JobSatisfaction int not null,
MaritalStatus varchar(50) not null,
MonthlyIncome int not null,
MonthlyRate int not null,
NumCompaniesWorked int not null,
OverTime varchar(50) not null,
PercentSalaryHike int not null,
PerformanceRating int not null,
RelationshipSatisfaction int not null,
StockOptionLevel int not null,
TotalWorkingYears int not null,
TrainingTimeLastYear int not null,
WorkLifeBalance int not null,
YearsAtCompany int not null,
YearsInCurrentRole int not null,
YearsSinceLastPromotion int not null,
YearsWIthCurrManager int not null,
AgeGroup varchar(50) not null,
SalaryBand varchar(50) not null,
DeptAvgSalary decimal(10,2) not null,
SalaryStatus varchar(50) not null,
AttritionRisk varchar(50) not null
);

select count(*) from employees;

-- 1 — Saare attrition employees list karo
select 
EmployeeNumber,age, Department, Jobrole, monthlyincome
from employees
where attrition = "Yes"
order by monthlyincome desc;
-- Total 237 rows by salary desc

-- 2 — Sales department ke attrition employees
select EmployeeNumber,age, Jobrole, monthlyincome, overtime
from employees
where attrition = "Yes"
and department = "Sales"
order by age asc;
-- Youngest Sales employees who left

-- 3 — Young + Overtime + Left (3 conditions)
select employeenumber, department, age, monthlyincome
from employees
where attrition = "Yes"
and Age < 30 
and overtime = "Yes"
order by age asc
limit 10;
-- Top 10 youngest overtime workers who resigned

-- 4 — Attrition count per department
select Department,
count(*) Total_Employees,
sum(case when attrition = "Yes" then 1 else 0 end) Attrition_count
from employees
group by Department
order by Attrition_count desc;

-- 5 — Avg salary per job role
select
JobRole, 
round(avg(monthlyincome), 2) Avg_Salary,
count(*) Total_Employees
from employees
group by jobrole
order by Avg_Salary desc;

-- 6 — Max years at company per Education Field
select EducationField,
max(YearsAtCompany) Max_years,
min(yearsatcompany) Min_years,
Round(avg(yearsatcompany),2) Avg_Years
from employees
group by educationfield
order by avg_years desc;

-- 7 — Departments with attrition > 20
select
department,
count(*) Attrition_count
from employees
where attrition = "Yes"
group by department
having count(*) > 20
order by Attrition_count desc;

-- 8 — Job roles jahan avg salary < 5000
select
JobRole,
round(avg(monthlyincome), 2) Avg_Salary,
count(*) Headcount
from employees
group by jobRole
having avg(monthlyincome) <5000
order by Avg_Salary asc;

 -- 9 — WHERE + HAVING dono saath
 select department, jobrole,
 round(avg(monthlyincome), 2) Avg_Salary
 from employees
 where OverTime = "Yes"
 group by Department,jobRole
 having avg(MonthlyIncome) < 4000
 order by Avg_Salary asc;
 
-- 10 — Attrition Risk label
select 
EmployeeNumber, Department, JobRole, JobSatisfaction, OverTime,
case
when JobSatisfaction <= 2 and OverTime = "Yes" then "High Risk"
when JobSatisfaction <= 2 or Overtime = "Yes" then "Medium Risk"
else "Low Risk" end as AttritionRisk
from employees
order by AttritionRisk asc;

-- 11 — Risk count summary
select 
case
when JobSatisfaction <= 2 and OverTime = "Yes" then "High Risk"
when JobSatisfaction <= 2 or Overtime = "Yes" then "Medium Risk"
else "Low Risk" end as Risk_level,
count(*) Total_employees
from employees
group by Risk_level
order by Total_employees desc;

-- 12 — Salary band classification
select
EmployeeNumber,MonthlyIncome,
case
when monthlyincome < 3000 then "Low"
when MonthlyIncome < 7000 then "Mid"
when MonthlyIncome < 12000 then "High"
else "Very High" end as SalaryBand
from employees;

-- 13 — Above average salary employees
select
EmployeeNumber, department, jobrole, MonthlyIncome
from employees
where MonthlyIncome > (select avg(MonthlyIncome) from employees)
order by MonthlyIncome desc;

-- 14 — Dept avg se zyada salary wale
select
e.EmployeeNumber, e.Department, e.MonthlyIncome,
dept_avg.avg_salary
from employees e
join 
(select department, round(avg(monthlyincome), 0) as avg_salary from employees group by department) as dept_avg
on e.department = dept_avg.department
where e.MonthlyIncome > dept_avg.avg_salary
order by e.department, MonthlyIncome desc;

-- 15 — High risk + above avg salary employees
select
EmployeeNumber, department, jobrole, MonthlyIncome
from employees
where MonthlyIncome > (select avg(MonthlyIncome) from employees)
and JobSatisfaction <= 2
and Overtime = "Yes"
order by MonthlyIncome desc;

-- Second table (dept_budget)
create table dept_budget (
department varchar(50) not null,
budget int not null,
max_headcount int not null
);

insert into dept_budget values
('Human Resources', 500000, 80),
('Research & Development', 7000000, 1000),
('Sales', 3500000, 500);

-- 16 — JOIN: Salary vs Budget
 select
 e.department, 
 count(*) Headcount,
 db.max_headcount,
 sum(e.monthlyincome) Total_salary,
 db.budget,
 round(sum(e.MonthlyIncome) * 100/db.budget , 1) dept_used_pact
 from employees e
 join
 dept_budget db
 on e.Department = db.department
 group by e.Department, db.budget, db.max_headcount
 order by dept_used_pact desc;
 
 -- 17 — CREATE VIEW (high risk employees) 
 create view High_risk_employees
 as select 
EmployeeNumber, department, jobrole, MonthlyIncome, OverTime, JobSatisfaction
 from employees
 where OverTime = "Yes"
 and JobSatisfaction <= 2;
 
select * from high_risk_employees;
 
 
-- 18 — CTE: Attrition rate % per department
 with dept_stats as (
 select department,
 count(*) total,
 sum(case when attrition = "Yes" then 1 else 0 end) left_count
 from employees 
 group by Department
 )
 select 
 department,
 total,
 Left_count,
 round(left_count * 100 / total, 2) Attrition_rate_pact
 from dept_stats
 order by Attrition_rate_pact desc;
 
 