select * from loans;
--  Easy questions  --	

-- Q1. What is the total number of loans in the dataset? --

select count(id) from loans;   

-- Q2. How many loans defaulted vs. not defaulted? (Count of status = 1 and 0) --

select (case when status = 1 then 'Default' else 'Non-default' end) as "Default_Vs_Non-Default", count(status) "Total_Loans" from loans group by status;

-- Q3. What is the percentage default rate? --

select round((sum(status)/count(id))*100,2) "Percentage_default_rate" from loans;

-- Q4. Count loans by loan_type (type1 vs type2). Which type is most common? --

select loan_type, count(id) Total_loans from loans where loan_type in ('type1','type2') group by loan_type;

-- Q5. Count loans by loan_purpose (p1, p2, p3, p4). Which purpose is highest? --

select loan_purpose, count(id) from loans where loan_purpose in ('p1','p2','p3','p4') group by loan_purpose;

-- Q6. What is the average LTV across all loans? --

select round(avg(LTV),2) Average_LTV from loans;

-- Q7. What is the minimum and maximum credit score? --

select min(Credit_Score) Min_Credit_Score, max(Credit_Score) Max_Credit_Score from loans;

-- Q8. Find how many loans have open_credit = nopc vs opc. --

select open_credit, count(id) from loans group by open_credit;

-- Q9. Calculate the number of loans for each region (North, South, etc.). --

select region, count(id) Total_loans from loans group by region;


-- Q10. What is the average interest rate spread? --

select round(avg(Interest_rate_spread),2) from loans where Interest_rate_spread != '';

-- Q11. What percentage of loans were pre-approved (approv_in_adv = pre)? --

select round(sum(case when approv_in_adv = 'pre' then 1 else 0 end)/count(id)*100,2) "%_of_pre_approved_loans" from loans;

-- Q12. What percentage of applications were submitted through institution (to_inst)? --

select round(sum(case when submission_of_application = 'to_inst' then 1 else 0 end)/count(id)*100,2) "submitted_through_institution" from loans;

-- Q13. Count the number of loans by Gender. --

select Gender, count(id) Total_Loans from loans group by Gender; 

-- Q14. What is the average term of loans? (in months) --

select round(avg(term),2) Average_of_Term from loans;

-- Q15. Count loans by credit_type (CIBIL, EXP, CRIF, EQUI). --

select credit_type, count(id) Total_Loans from loans group by credit_type;

-- Q16. What is the average DTI ratio (dtir1)? --

select avg(dtir1) Average_DTIR from loans where dtir1 != ''; 

-- Q17. What is the average LTV for default vs non-default loans? --

select (case when status = 1 then "Default" else "Non-Default" end) DVN, round(avg(ltv),2) from loans where LTV != '' group by DVN; 

-- Q18. How many loans have Security_Type = direct vs indirect? --

select Security_Type, count(id) Total_Loans from loans group by Security_Type;


-- Medium Questions --

-- Q1. Compare default rates between loan_type (type1 vs type2). Which is riskier? --

select loan_type,concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans group by loan_type;

-- Q2. Compare default rate by loan_purpose (p1–p4). Which purpose defaults the most? --

select loan_purpose,concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
where loan_purpose in ('p1','p2','p3','p4') group by loan_purpose;


select loan_purpose,concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
where loan_purpose is not null
and loan_purpose <> ''
and loan_purpose !='0'
group by loan_purpose;

-- Q3. Compare LTV distribution between default and non-default loans. --

select ltv_range,
sum(case when status = 1 then 1 else 0 end) as "Default", -- Default
sum(case when status = 0 then 1 else 0 end) "Non-Default", -- Non_Default
count(*) as total_loans,
concat(round(
sum(case when status = 1 then 1 else 0 end)/count(*) * 100,
2
), " %") as Default_Rate_percent
from
(select status, (case when LTV <=60 then "<=60"
			when LTV >60 and LTV <=70 then "60-70" 
            when LTV >70 and LTV <=80 then "70-80"
            when LTV >80 and LTV <=90 then "80-90"
            else "90+" end) ltv_range
            from loans where LTV is not null) t
group by ltv_range;
            
-- Q4. Which region has the highest default rate? --

select region,concat(Default_percent, " %") "Default%" from ( 
select region,round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2) as Default_percent from loans group by region order by Default_percent desc limit 1)a;

-- Q5. Analyze the relationship between credit score groups and default rate. --

select
(case when Credit_Score >300 and Credit_Score <=550 then '300-550'
when Credit_Score >550 and Credit_Score <=650 then '550-650'
when Credit_Score >650 and Credit_Score <=750 then '650-750'
else "750+" end
) credit_range,
concat(round(sum(case when status = 1 then 1 else 0 end)/count(id)*100,2)," %") as Default_Percent from loans
group by credit_range;


-- Q6. What is the average interest rate spread for each loan_purpose? --

select loan_purpose, round(avg(Interest_rate_spread),2) Average_spread from loans where 
loan_purpose <> ''
and loan_purpose <> '0'
and Interest_rate_spread != 0
group by loan_purpose;


-- Q7. Does pre-approval (pre vs nopre) reduce default rate? --

select approv_in_adv,concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
where approv_in_adv in ('nopre','pre') group by approv_in_adv;

-- Q8. Find the top 5 most risky customer age groups (age column). --

select age, concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
where age != ''
group by age;


-- Q9. Compare commercial (b/c) vs non-commercial loans (nob/c) for default rate. --

select business_or_commercial, concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
group by business_or_commercial;

-- Q10. Analyze default % for open_credit types (opc vs nopc). --

select open_credit, concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
group by open_credit;

-- Q11. Find if loans with neg_amortization default at a higher rate. --

select Neg_ammortization, concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
where Neg_ammortization in ('not_neg','neg_amm')
group by Neg_ammortization;

-- Q12. Does interest_only (int_only) lead to more defaults? --

select interest_only, concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
group by interest_only;

-- Q13. Compare defaults for occupancy_type (pr, sr, ir). --

select occupancy_type, concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%" from loans
group by occupancy_type;


-- Q14. What is the relationship between upfront charges and default? (Buckets like High / Medium / Low) --

select (case when Upfront_charges <=5000 then "low"
			 when Upfront_charges >5000 and Upfront_charges<=20000 then "Medium"
			 else "High" end) as upfront_charge,
             concat(round((sum(case when status = 1 then 1 else 0 end)/count(id)*100),2)," %") as "Default%"
from loans
group by upfront_charge;

-- Q15. Group by Security_Type and find average credit score. --

select Security_Type, round(avg(Credit_Score),2) Avg_credit_score from loans
where Credit_Score != ''
group by Security_Type;

-- Q16. What is the average LTV of loans grouped by credit bureau (EXP, CIBIL, etc.)? --

select credit_type, round(avg(LTV),2) Avg_ltv from loans
where LTV != ''
group by credit_type;


-- Hard Questions --

-- Q1. Build a risk score grouping using LTV, dtir1, credit score and find default rate for each risk cluster. --

select (case when risk_score <=5 then "Low"
             when risk_score <=8 then "Medium"
             when risk_score <=11 then "High"
             else "Very High" end) Risk_cluster,concat(round(sum(case when status = 1 then 1 else 0 end)/count(*)*100,2),"%") "Default%"  from
(select status,(ltv_range + dtir_range + credit_range) risk_score
from
(select status,(case when LTV <=60 then 1
			 when LTV >60 and LTV <=70 then 2
             when LTV >70 and LTV <=80 then 3
             when LTV >80 and LTV <=90 then 4
             else 5 end) ltv_range,
	   (case when dtir1 <=30 then 1
             when dtir1 >30 and dtir1 <=40 then 2
             when dtir1 >40 and dtir1 <=50 then 3
             when dtir1 >50 and dtir1 <=60 then 4
             else 5 end) dtir_range,
		(case when Credit_Score >=600 and Credit_Score <650 then 4
              when Credit_Score >=650 and Credit_Score <700 then 3
              when Credit_Score >=700 and Credit_Score <750 then 2
              when Credit_Score >=750 then 1 else 5 end) credit_range
			from loans) a) b
            group by risk_cluster;
            
            
            
  SELECT
(
    COUNT(*) * SUM(LTV * Status) - SUM(LTV) * SUM(Status)
) /
SQRT(
    (COUNT(*) * SUM(LTV * LTV) - POW(SUM(LTV), 2)) *
    (COUNT(*) * SUM(Status * Status) - POW(SUM(Status), 2))
) AS corr_ltv_status
FROM loans
where LTV is not null
and LTV >=60 and LTV <=120;


-- Q3. Create a “Borrower Risk Index” using: Credit score, dtir1, open_credit, loan_purpose.** --

select (case when risk_range <=5 then "Low"
             when risk_range <=8 then "Medium" 
             when risk_range <=11 then "High"
             else "Very High" end) Borrower_risk_index, concat(round(sum(case when status = 1  then 1 else 0 end)/count(*)*100,2), "%") "Default%" from (
select status,(credit_range + dtir_range + open_range + purpose_range) risk_range from (
select status,(case when  Credit_Score >=600 and Credit_Score <650 then 4
             when  Credit_Score >=650 and Credit_Score <700 then 3
             when  Credit_Score >=700 and Credit_Score <=750 then 2
             when  Credit_Score >=750 then 1 else 5 end) credit_range,
             (case when dtir1 <=30 then 1
             when dtir1 >30 and dtir1 <=40 then 2
             when dtir1 >40 and dtir1 <=50 then 3
             when dtir1 >50 and dtir1 <=60 then 4
             else 5 end) dtir_range,
             (case when open_credit = 'nopc' then 2 else 1 end) open_range,
             (case when loan_purpose = 'p4' then 1
                   when loan_purpose = 'p3' then 2
                   when loan_purpose = 'p1' then 3
                   when loan_purpose = 'p2' then 4 else 0 end) purpose_range from loans) a) b group by Borrower_risk_index;
             


-- Q4. Determine whether institution-submitted applications have statistically lower default. --

select submission_of_application instituted_submitted_application, concat(round(sum(case when status = 1 then 1 else 0 end)/count(*)*100,2),"%") "Default%"
from loans where submission_of_application != 'NA' group by instituted_submitted_application;


-- Q5. Compare default rate of DIRECT secured vs INDIRECT secured loans by LTV bucket. --

select Security_Type, concat(round(sum(case when status = 1 then 1 else 0 end)/count(*)*100,2),"%") "Default%" from loans
group by Security_Type;

-- Q6. Create LTV buckets (0–60%, 60–80%, 80–90%, 90+%) and analyze default. --

select ltv_range, concat(round(sum(case when status = 1 then 1 else 0 end)/count(*)*100,2),"%") "Default%" from (select status,(case when LTV <=60 then "<=60"
			 when LTV >60 and LTV <=70 then "60-70"
             when LTV >70 and LTV <=80 then "70-80"
             when LTV >80 and LTV <=90 then "80-90"
             else ">90" end) ltv_range
             from loans) a group by ltv_range;

-- Q7. Does longer tenure (term) lead to more defaults? --


select tenure_range, concat(round(sum(case when status = 1 then 1 else 0 end)/count(*)*100,2),"%") "Default%" from
(select status,(case when term <=120 then "Short Tenure"
             when term >120 and term <=180 then "Medium Tenure"
             when term >180 and term <=240 then "Long Tenure"
             else "Very Long Tenure" end) tenure_range from loans) a group by tenure_range;
             
             

-- Q8. Create a matrix of default by age group vs gender. --

select age, 
concat(round(100 * sum(case when status = 1 and Gender  = 'Female' then 1 else 0 end)/
nullif(sum(case when Gender  = 'Female' then 1 else 0 end),0),2),"%") as  Female, 

concat(round(100*sum(case when status = 1 and Gender  = 'Sex Not Available' then 1 else 0 end)/
nullif(sum(case when Gender  = 'Sex Not Available' then 1 else 0 end),0),2),"%") as  "Sex_Not_Available", 

concat(round(100*sum(case when status = 1 and Gender  = 'Joint' then 1 else 0 end)/       -- Very Imp query for learning as it teaches how to create matrix in sql --
nullif(sum(case when Gender  = 'Joint' then 1 else 0 end),0),2),"%") as  Joint, 

concat(round(100*sum(case when status = 1 and Gender  = 'Male' then 1 else 0 end)/
nullif(sum(case when Gender  = 'Male' then 1 else 0 end),0),2),"%") as  Male
from loans where age != '0'
group by age;

-- Q9. Find the top 10 high-risk loan profiles (rows) using combined metrics. --

select distinct(loan_risk_score) from (select (ltv_range + dtir_range + credit_range + tenure_range + purpose_range + open_credit_range + securtiy_range) loan_risk_score  
from (select (case when LTV <=60 then 1
			 when LTV >60 and LTV <=70 then 2
             when LTV >70 and LTV <=80 then 3
             when LTV >80 and LTV <=90 then 4
             else 5 end) ltv_range,
	   (case when dtir1 <=30 then 1
             when dtir1 >30 and dtir1 <=40 then 2
             when dtir1 >40 and dtir1 <=50 then 3
             when dtir1 >50 and dtir1 <=60 then 4
             else 5 end) dtir_range,
		(case when Credit_Score >=600 and Credit_Score <650 then 4
              when Credit_Score >=650 and Credit_Score <700 then 3
              when Credit_Score >=700 and Credit_Score <750 then 2
              when Credit_Score >=750 then 1 else 5 end) credit_range,
		(case when term <=120 then 1
              when term >120 and term <=180 then 2
              when term >180 and term <=240 then 3
              else 4 end) tenure_range,
		(case when loan_purpose = 'p4' then 1
			  when loan_purpose = 'p3' then 2
              when loan_purpose = 'p1' then 3
              when loan_purpose = 'p2' then 4 else 0 end) purpose_range,
		(case when open_credit = 'nopc' then 2 else 1 end) open_credit_range,
        (case when Security_Type = 'Direct' then 1 else 2 end) securtiy_range
from loans) a ) b
order by loan_risk_score desc limit 10; 

-- Q10. Does increasing upfront_charges correlate to higher approval risk? --

select (case when Upfront_charges = 0 then 'No upfront burden' 
             when Upfront_charges > 0 and Upfront_charges <= 3000 then 'Around average'
             when Upfront_charges > 3000 and Upfront_charges <= 10000 then 'Above average'
             when Upfront_charges >10000 and Upfront_charges <= 25000 then 'High'
             else 'Very High' end) upfront_bucket, concat(round(sum(case when status = 1 then 1 else 0 end)/count(*)*100,2),"%") "Default%"
             from loans where Upfront_charges <> ''
             group by upfront_bucket;


-- Q11. Identify the combination of features that leads to the highest risk cluster. --

select Risk_cluster, concat(Defaultp,"%") as "Default%" from (select Risk_cluster,
round(sum(case when status = 1 then 1 else 0 end)/count(*)*100,2) Defaultp from
 (select status, concat(credit_range, " | ", ltv_range, " | ", open_credit, " | ", Security_Type) Risk_cluster from (select  status,(case when Credit_Score <650  then '<650'
			when Credit_Score > 650 and Credit_Score <=700 then '650-700'
            when Credit_Score >700 and Credit_Score <=750 then '700-750'
			else ">750" end) credit_range,
	    (case when LTV <=60 then "<60"
			 when LTV >60 and LTV <=70 then "60-70"
             when LTV >70 and LTV <=80 then "70-80"
             when LTV >80 and LTV <=90 then "80-90"
             else ">90" end) ltv_range,
             open_credit,
             Security_Type
             from loans) a) b group by Risk_cluster having Defaultp not in ('100.00','0.00') order by Defaultp desc) c;
             
             
-- Q12. Using SQL window functions, rank customers based on credit score within region. --

select id,Region,Credit_Score, 
dense_rank() over(partition by Region order by Credit_Score desc) as Region_rank
from loans;
 

-- Q**17. Build a predictive score manually using weighted formula: --
-- Risk Score = (0.4 * LTV) + (0.3 * DTI) – (0.3 * Credit Score Normalized)** --


select ((0.4 * ltv_range) + (0.3 * dtir_range) - (0.3 * credit_range)) predictive_score from (select (case when LTV <=60 then 1
			 when LTV >60 and LTV <=70 then 2
             when LTV >70 and LTV <=80 then 3
             when LTV >80 and LTV <=90 then 4
             else 5 end) ltv_range,
	   (case when dtir1 <=30 then 1
             when dtir1 >30 and dtir1 <=40 then 2
             when dtir1 >40 and dtir1 <=50 then 3
             when dtir1 >50 and dtir1 <=60 then 4
             else 5 end) dtir_range,
		(case when Credit_Score >=600 and Credit_Score <650 then 4
              when Credit_Score >=650 and Credit_Score <700 then 3
              when Credit_Score >=700 and Credit_Score <750 then 2
              when Credit_Score >=750 then 1 else 5 end) credit_range from loans) a;
 
select * from loans;
             


SELECT *,
       (0.4 * LTV)
     + (0.3 * dtir1)
     - (0.3 * ((Credit_Score - min_cs) / (max_cs - min_cs)))
       AS risk_score
FROM (
    SELECT *,
           MIN(Credit_Score) OVER () AS min_cs,
           MAX(Credit_Score) OVER () AS max_cs
    FROM loans
) t;






