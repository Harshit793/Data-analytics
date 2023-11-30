/* 1. List down the top 5 districts that showed the highest document registration revenue  growth  between FY 2019 and FY 2022? */

WITH CTE AS
(
SELECT  district,ROUND(1.0*SUM(documents_registered_rev)/10000000,2) Tot_rev
FROM dbo.dim_date$ dm_date
INNER JOIN   dbo.fact_stamps$ ft_stamps
ON dm_date.month=ft_stamps.month
INNER JOIN dbo.dim_districts$  dm_dist
ON dm_dist.dist_code= ft_stamps.dist_code
GROUP BY district


),

CTE2 AS
(
SELECT  district,ROUND(1.0*SUM(documents_registered_rev)/10000000,2) Tot_rev_till_2021
FROM dbo.dim_date$ dm_date
INNER JOIN   dbo.fact_stamps$ ft_stamps
ON dm_date.month=ft_stamps.month
INNER JOIN dbo.dim_districts$  dm_dist
ON dm_dist.dist_code= ft_stamps.dist_code
WHERE fiscal_year BETWEEN 2019 AND 2021
GROUP BY district

)

SELECT Top 5 CTE.district,(Round((Tot_rev-Tot_rev_till_2021)/Tot_rev_till_2021,3)*100)  YOY_change FROM CTE 
INNER JOIN   CTE2 
ON CTE.district=CTE2.district
ORDER BY YOY_change  DESC


/*  2. List down the top 5 districts where estamps revenue contributes more to the revenue than documents in year 2022 */

WITH CTE AS
(
SELECT  district,Round((1.0*SUM(documents_registered_rev)/10000000 ),2) Tot_doc_rev_in_cr,
Round((1.0*SUM(estamps_challans_rev)/10000000 ),2)  Tot_estamp_rev_in_cr
FROM dbo.dim_date$ dm_date
INNER JOIN   dbo.fact_stamps$ ft_stamps
ON dm_date.month=ft_stamps.month
INNER JOIN dbo.dim_districts$  dm_dist
ON dm_dist.dist_code= ft_stamps.dist_code
WHERE fiscal_year=2022
GROUP BY district
)

SELECT Top 5 district,Round((Tot_estamp_rev_in_cr-Tot_doc_rev_in_cr),2)Diff_in_cr
FROM CTE
ORDER BY Diff_in_cr Desc



/* 3.  Is there any alteration of e-stamp challan count and docs  registration count pattern since the implementation of e-stamp challan ? */


WITH CTE AS
(
SELECT fiscal_year,Mmm,Round((1.0*SUM(documents_registered_cnt)/100000),2)Tot_docs_registered_in_lacs,
Round((1.0*Sum(estamps_challans_cnt)/100000),2)Tot_estamps_registered_in_lacs
FROM dbo.dim_date$ dm_date
INNER JOIN   dbo.fact_stamps$ ft_stamps
ON dm_date.month=ft_stamps.month
INNER JOIN dbo.dim_districts$  dm_dist
ON dm_dist.dist_code= ft_stamps.dist_code

GROUP BY fiscal_year,Mmm

)

SELECT fiscal_year,Mmm,Tot_docs_registered_in_lacs,Tot_estamps_registered_in_lacs,
ROUND((Tot_estamps_registered_in_lacs-Tot_docs_registered_in_lacs),2)diff_in_lacs
FROM CTE
WHERE Tot_estamps_registered_in_lacs >0
ORDER BY fiscal_year,
CASE
        WHEN Mmm = 'Jan' THEN 10
        WHEN Mmm = 'Feb' THEN 11
        WHEN Mmm = 'Mar' THEN 12
        WHEN Mmm = 'Apr' THEN 1
        WHEN Mmm = 'May' THEN 2
        WHEN Mmm = 'Jun' THEN 3
        WHEN Mmm = 'Jul' THEN 4
        WHEN Mmm = 'Aug' THEN 5
        WHEN Mmm = 'Sep' THEN 6
        WHEN Mmm = 'Oct' THEN 7
        WHEN Mmm= 'Nov' THEN  8
        WHEN Mmm = 'Dec' THEN 9
    END
	






/*  4. Categorize districts into three segments based on their stamp registration revenue generation during the year 2021 to 2022. */

/* Large-sized cities */


WITH CTE AS
(
SELECT  district,Round((1.0*SUM(estamps_challans_rev)/10000000 ),2)  Tot_estamp_rev_in_cr
FROM dbo.dim_date$ dm_date
INNER JOIN   dbo.fact_stamps$ ft_stamps
ON dm_date.month=ft_stamps.month
INNER JOIN dbo.dim_districts$  dm_dist
ON dm_dist.dist_code= ft_stamps.dist_code
WHERE fiscal_year BETWEEN  2021  AND 2022
GROUP BY district

)

SELECT  district,Tot_estamp_rev_in_cr  FROM CTE 
WHERE Tot_estamp_rev_in_cr >1000
ORDER BY Tot_estamp_rev_in_cr  DESC;




/* Medium  sized cities */


WITH CTE AS
(
SELECT  district,Round((1.0*SUM(estamps_challans_rev)/10000000 ),2)  Tot_estamp_rev_in_cr
FROM dbo.dim_date$ dm_date
INNER JOIN   dbo.fact_stamps$ ft_stamps
ON dm_date.month=ft_stamps.month
INNER JOIN dbo.dim_districts$  dm_dist
ON dm_dist.dist_code= ft_stamps.dist_code
WHERE fiscal_year BETWEEN  2021  AND 2022
GROUP BY district

)

SELECT  district,Tot_estamp_rev_in_cr  FROM CTE 
WHERE Tot_estamp_rev_in_cr BETWEEN 100 AND 1000
ORDER BY Tot_estamp_rev_in_cr  DESC



/* Small  sized cities */


WITH CTE AS
(
SELECT  district,Round((1.0*SUM(estamps_challans_rev)/10000000 ),2)  Tot_estamp_rev_in_cr
FROM dbo.dim_date$ dm_date
INNER JOIN   dbo.fact_stamps$ ft_stamps
ON dm_date.month=ft_stamps.month
INNER JOIN dbo.dim_districts$  dm_dist
ON dm_dist.dist_code= ft_stamps.dist_code
WHERE fiscal_year BETWEEN  2021  AND 2022
GROUP BY district

)

SELECT  district,Tot_estamp_rev_in_cr  FROM CTE 
WHERE Tot_estamp_rev_in_cr < 100
ORDER BY Tot_estamp_rev_in_cr  DESC



/* 5. Investigate whether there is any correlation between vehicle sales and specific months or seasons in different districts. 
Are there any months or seasons that consistently show higher or lower sales rate, and if yes, what could be the driving factors? (Consider Fuel-Type category only) */
 
 WITH CTE AS
 (
 SELECT district, Mmm, Round( (SUM(fuel_type_petrol)/100000),3)+Round((SUM(fuel_type_diesel)/100000),3)
 +Round( (SUM(fuel_type_electric)/100000),3)+Round( (SUM(fuel_type_others)/100000),3) Tot_sales,
 Dense_Rank() OVER( PARTITION BY district ORDER BY Round( (SUM(fuel_type_petrol)/100000),3)+Round((SUM(fuel_type_diesel)/100000),3)
 +Round( (SUM(fuel_type_electric)/100000),3)+Round( (SUM(fuel_type_others)/100000),3)DESC
 )Rnk
 FROM  dbo.dim_date$ dt
 INNER JOIN   dbo.fact_transport$  tr
 ON dt.month=tr.month
 INNER JOIN   dbo.dim_districts$  dis
 ON tr.dist_code=dis.dist_code
 GROUP BY district,Mmm
)

 SELECT  district ,Mmm,Tot_sales
 FROM CTE 
 WHERE Rnk=1
 ORDER BY district,Tot_sales DESC



 /* 6.How does the distribution of vehicles vary by vehicle class (MotorCycle, MotorCar, AutoRickshaw, Agriculture) across different districts?  */

SELECT Round((1.0*Sum(vehicleClass_MotorCycle))/ (SUM(vehicleClass_MotorCycle)+Sum(vehicleClass_MotorCar)+Sum(vehicleClass_AutoRickshaw)+
Sum(vehicleClass_Agriculture)),2)Motorcycle ,Round((1.0*Sum(vehicleClass_MotorCar))/ (SUM(vehicleClass_MotorCycle)+Sum(vehicleClass_MotorCar)
+Sum(vehicleClass_AutoRickshaw)+Sum(vehicleClass_Agriculture)),2)Motorcar,Round((1.0*Sum(vehicleClass_AutoRickshaw))/ (SUM(vehicleClass_MotorCycle)
+Sum(vehicleClass_MotorCar)+Sum(vehicleClass_AutoRickshaw)+Sum(vehicleClass_Agriculture)),2)AutoRickshaw,Round((1.0*Sum(vehicleClass_Agriculture))/ 
(SUM(vehicleClass_MotorCycle)+Sum(vehicleClass_MotorCar)+Sum(vehicleClass_AutoRickshaw)+Sum(vehicleClass_Agriculture)),2)Agriculture
FROM  dbo.fact_transport$ tr


/* Are there any districts with a predominant preference for a specific vehicle class? Consider FY 2022 for analysis. */


SELECT Top 1 district,Format(Round(1.0*Sum(vehicleClass_MotorCycle)/100000,2),'#,0.00L')Motorcycle_sales  FROM dbo.fact_transport$ tr
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
INNER JOIN dbo.dim_date$ dt
ON tr.month=dt.month
WHERE fiscal_year=2022
GROUP BY district
ORDER BY Motorcycle_sales DESC


SELECT Top 1 district,Format(Round(1.0*Sum(vehicleClass_MotorCar)/1000,2),'#,0.00K') Motorcar_sales  FROM dbo.fact_transport$ tr
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
INNER JOIN dbo.dim_date$ dt
ON tr.month=dt.month
WHERE fiscal_year=2022
GROUP BY district
ORDER BY Motorcar_sales DESC



SELECT Top 1 district,Format(Round(1.0*Sum(vehicleClass_AutoRickshaw)/1000,2),'#,0.00K') Autorickshaw_sales  FROM dbo.fact_transport$ tr
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
INNER JOIN dbo.dim_date$ dt
ON tr.month=dt.month
WHERE fiscal_year=2022
GROUP BY district
ORDER BY Autorickshaw_sales DESC



SELECT Top 1 district,Format(Round(1.0*Sum(vehicleClass_Agriculture)/1000,2),'#,0.00K') Agriculture_sales  FROM dbo.fact_transport$ tr
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
INNER JOIN dbo.dim_date$ dt
ON tr.month=dt.month
WHERE fiscal_year=2022
GROUP BY district
ORDER BY Agriculture_sales DESC;




/*  7.List down the top 3 and bottom 3 districts that have shown the highest and lowest vehicle sales growth during FY 2022 compared to FY 2021? 
(Consider and compare categories: Petrol, Diesel and Electric)  */

/* Top_three_sales_petrol */

WITH prev_sales AS
(
SELECT district,Sum(fuel_type_petrol)Prev_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2021
GROUP BY district
),

 Current_sales AS
(
SELECT district,Sum(fuel_type_petrol)Current_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2022
GROUP BY district
)

 SELECT Top 3  pv.district,Round((1.0*cu.Current_sales-pv.Prev_sales)/Prev_sales ,4)*100 sales_growth FROM Prev_sales pv
INNER JOIN  Current_sales cu
ON  pv.district=cu.district
ORDER BY sales_growth  DESC  


/* Bottom_three_sales_petrol */

WITH prev_sales AS
(
SELECT district,  Sum(fuel_type_petrol)Prev_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2021
GROUP BY district
),

 Current_sales AS
(
SELECT district,Sum(fuel_type_petrol)Current_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2022
GROUP BY district
)


SELECT  pv.district,Round((1.0*( Current_sales-Prev_sales)/Prev_sales),4)*100 sales_growth FROM Prev_sales pv
INNER JOIN  Current_sales cu
ON  pv.district=cu.district
ORDER BY   sales_growth  DESC
OFFSET ( SELECT COUNT(*)-3  FROM Prev_sales) ROWS
FETCH NEXT 3 ROWS ONLY





/* Top_three_sales_diesel  */

WITH prev_sales AS
(
SELECT district,Sum(fuel_type_diesel)Prev_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2021
GROUP BY district
),


 Current_sales AS
(
SELECT district,Sum(fuel_type_diesel)Current_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2022
GROUP BY district
)


 SELECT Top 3  pv.district,Round((1.0*cu.Current_sales-pv.Prev_sales)/Prev_sales ,4)*100 sales_growth FROM Prev_sales pv
INNER JOIN  Current_sales cu
ON  pv.district=cu.district
ORDER BY sales_growth  DESC  


/* Bottom_three_sales_diesel */

WITH prev_sales AS
(
SELECT district,  Sum(fuel_type_diesel)Prev_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2021
GROUP BY district
),

 Current_sales AS
(
SELECT district,Sum(fuel_type_diesel)Current_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2022
GROUP BY district
)


SELECT  pv.district,Round((1.0*( Current_sales-Prev_sales)/Prev_sales),4)*100 sales_growth FROM Prev_sales pv
INNER JOIN  Current_sales cu
ON  pv.district=cu.district
ORDER BY   sales_growth  DESC
OFFSET ( SELECT COUNT(*)-3  FROM Prev_sales) ROWS
FETCH NEXT 3 ROWS ONLY



/* Top_three_sales_electric  */

WITH prev_sales AS
(
SELECT district,Sum(fuel_type_electric)Prev_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2021
GROUP BY district
),


 Current_sales AS
(
SELECT district,Sum(fuel_type_electric)Current_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2022
GROUP BY district
)


 SELECT Top 3  pv.district,Round((1.0*cu.Current_sales-pv.Prev_sales)/Prev_sales ,4)*100 sales_growth FROM Prev_sales pv
INNER JOIN  Current_sales cu
ON  pv.district=cu.district
ORDER BY sales_growth  DESC  



/* Bottom_three_sales_electric */

WITH prev_sales AS
(
SELECT district,Sum(fuel_type_electric)Prev_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2021
GROUP BY district
),

 Current_sales AS
(
SELECT district,Sum(fuel_type_electric)Current_sales FROM  dbo.dim_date$ dt
INNER JOIN  dbo.fact_transport$   tr
ON dt.month=tr.month
INNER JOIN dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
WHERE fiscal_year=2022
GROUP BY district
)


SELECT  pv.district,Round((1.0*( Current_sales-Prev_sales)/Prev_sales),4)*100 sales_growth FROM Prev_sales pv
INNER JOIN  Current_sales cu
ON  pv.district=cu.district
ORDER BY   sales_growth  DESC
OFFSET ( SELECT COUNT(*)-3  FROM Prev_sales) ROWS
FETCH NEXT 3 ROWS ONLY




/* 8. List down the top 5 sectors that have witnessed the most significant investments in FY 2022.  */

SELECT Top 5 Sector,Sum([investment in cr])Tot_investment_cr  FROM dbo.['Ft_ts _Ipass$'] PASS
INNER JOIN dbo.dim_date$  dt
ON  pass.month=dt.month
WHERE fiscal_year=2022
GROUP BY sector
ORDER BY Tot_investment_cr  DESC



/*  9.List down the top 3 districts that have attracted the most significant sector investments during FY 2019 to 2022?
What factors could have led to the substantial investments in these particular districts?  */

SELECT Top 3 district,SUM([investment in cr] )Tot_investment_cr FROM dbo.['Ft_ts _Ipass$']    pass
INNER JOIN dbo.dim_districts$ dist
ON  dist.dist_code=pass.dist_code
INNER JOIN  dbo.dim_date$ dt
ON pass.month=dt.month
GROUP BY district
ORDER BY Tot_investment_cr DESC



/* 10. Is there any relationship between district investments,vehicles sales and stamps revenue within the same district between FY 2021
and 2022? */

SELECT Top 5  district,ROUND(sum([investment in cr] ),2)Tot_investment_cr FROM  dbo.['Ft_ts _Ipass$']     pass
INNER JOIN  dbo.dim_districts$ ds
ON ds.dist_code=pass.dist_code
INNER JOIN  dbo.dim_date$ dt
ON pass.month=dt.month
WHERE fiscal_year  BETWEEN 2021 AND 2022
GROUP BY district
ORDER BY Tot_investment_cr  DESC

SELECT Top 5 district,ROUND(sum(estamps_challans_rev)/10000000,2)Tot_revenue_cr FROM  dbo.fact_stamps$ st
INNER JOIN  dbo.dim_districts$ ds
ON st.dist_code=ds.dist_code
INNER JOIN  dbo.dim_date$ dt
ON st.month=dt.month
WHERE fiscal_year  BETWEEN 2021 AND 2022
GROUP BY district
ORDER BY Tot_revenue_cr  DESC


SELECT TOP 5  district,Round((sum(vehicleClass_Motorcycle)+sum(vehicleClass_MotorCar)+sum(vehicleClass_AutoRickshaw)+sum(VehicleClass_Agriculture)
+sum(vehicleClass_others))/100000,2)Tot_sales_lacs FROM  dbo.fact_transport$  tr
INNER JOIN  dbo.dim_districts$ dist
ON tr.dist_code=dist.dist_code
INNER JOIN  dbo.dim_date$ dt
ON dt.month=tr.month
WHERE fiscal_year  BETWEEN 2021 AND 2022
GROUP BY district
ORDER BY  Tot_sales_lacs DESC



/* 11. Are there any particular sectors that have shown substantial investment in multiple districts between FY 2021 and 2022?  */


SELECT Top 5 sector,sum([investment in cr])Tot_investment  FROM  dbo.['Ft_ts _Ipass$']    pass
INNER JOIN dbo.dim_districts$  ds
ON pass.dist_code=ds.dist_code
INNER JOIN  dbo.dim_date$ dt
ON pass.month=dt.month
WHERE fiscal_year BETWEEN 2021 AND 2022 
AND  district IN
(
SELECT district FROM ( SELECT Top 5 district ,sum([investment in cr]) Tot_invest FROM  dbo.['Ft_ts _Ipass$']   pass
INNER JOIN dbo.dim_districts$  ds
ON pass.dist_code=ds.dist_code
INNER JOIN  dbo.dim_date$ dt
ON pass.month=dt.month
WHERE fiscal_year =2021
GROUP BY district
ORDER BY Tot_invest DESC
) tb
)
GROUP BY sector
ORDER BY Tot_investment DESC;






/* 12. Can we identify any seasonal patterns or cyclicality in the
investment trends for specific sectors? Do certain sectors
experience higher investments during particular months?  */


WITH CTE AS
(
SELECT sector,Mmm,rank() OVER(PARTITION BY  sector ORDER BY sum([investment in cr]) DESC )rnk FROM dbo.['Ft_ts _Ipass$'] pass
INNER JOIN dbo.dim_date$ dt
ON pass.month=dt.month
GROUP BY Mmm,sector

)

SELECT sector,Mmm  FROM CTE 
WHERE rnk=1
ORDER BY sector









