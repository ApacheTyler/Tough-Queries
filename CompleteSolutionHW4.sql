--Tyler Freeman
--Database 2 HW4"Tough Queries"
--Robert Phillips
--02/07/14

--------------------------------------------------------------------------------
--1) REM - Query 1: NFL PLAYERS WITH SAME COLLEGE
WITH sameCollegePlayers AS(
--QUERY finds team(s) who have most player from one college                          
  SELECT team, college, max(colcnt) FROM 
          (SELECT team, college, count(college) as colcnt FROM nfl.players 
           GROUP BY team, college)--Finds count of colleges on each team
    WHERE colcnt =
          (SELECT MAX(colcnt) FROM --Finds max of the college count on each team
                (SELECT team, college, count(college) as colcnt FROM nfl.players
                 GROUP BY team, college))
  GROUP BY team, college
  ORDER BY team
  )
  
SELECT * FROM nfl.players
  INNER JOIN 
              sameCollegePlayers
  ON players.team = sameCollegePlayers.team 
     AND
     players.college = sameCollegePlayers.college
ORDER BY players.team;

--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--REM - QUERY 2 Find the golfers with highest drive from each country

WITH highestAvgDriveByCountry AS
  (
  SELECT country, MAX(topDrive) as topGolferAvg FROM
  (SELECT country, name, age, MAX(avgdrive) as topDrive  FROM PGA.golfers
  GROUP BY country, name, age
  ORDER BY country)
  GROUP BY country
  )
SELECT golfers.country, golfers.name, golfers.age,golfers.avgdrive  FROM PGA.golfers
  INNER JOIN 
    highestAvgDriveByCountry
  ON avgdrive = highestAvgDriveByCountry.topGolferAvg
     AND golfers.country = highestAvgDriveByCountry.country;

--------------------------------------------------------------------------------





--------------------------------------------------------------------------------
--REM - QUERY 3 Find the golfers with higher earnings than avg for country

WITH avgEarningsPerCountry AS
(
  SELECT country, AVG(earnings) as cntyAvgEarnings FROM pga.golfers
    GROUP BY country
)
SELECT golfers.country, golfers.name, golfers.earnings, 
       cntyAvgEarnings, (golfers.earnings - cntyAvgEarnings) as glfrCntryDiff
       FROM pga.golfers
          INNER JOIN avgEarningsPerCountry
             ON golfers.country = avgEarningsPerCountry.country
       WHERE (golfers.earnings - cntyAvgEarnings) > 0
ORDER BY golfers.earnings DESC;

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--REM - QUERY 4 Find the top five agents

SELECT * FROM (
    SELECT agents.agentid, agents.lname, agents.fname, 
           COUNT(listingnum) AS NumOfListings, SUM(Price) AS totalListValue 
    FROM MLS.agents
      LEFT OUTER JOIN MLS.homes
        ON agents.agentid = homes.agentid
      GROUP BY agents.agentid, lname, fname
    ORDER BY totalListValue DESC
    )
  WHERE ROWNUM <= 5 AND totalListValue IS NOT NULL;
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--REM Query 5: Look for corruption, recalculate GPA
WITH studentPerformanceInCourse AS
(--Gets course info with grade student achieved and credits class was worth
SELECT enrollments.sid, sections.term, sections.indexnum, enrollments.grade, courses.courseNum, courses.credits
  FROM university.enrollments 
    INNER JOIN UNIVERSITY.sections
      ON enrollments.term = sections.term AND enrollments.indexnum = sections.indexnum
    INNER JOIN UNIVERSITY.courses 
      ON sections.coursenum = courses.coursenum
ORDER BY sid, grade, indexnum
),
dataForGpaCalculation AS
( --Gets grade points earned for each class a student enrolled in
SELECT studentPerformanceInCourse.sid, studentPerformanceInCourse.term, 
       studentPerformanceInCourse.indexnum, studentPerformanceInCourse.grade, 
       studentPerformanceInCourse.courseNum, studentPerformanceInCourse.credits, 
       gradevalues.gradevalue, 
       (studentPerformanceInCourse.credits * gradevalues.gradevalue) as GradePointsEarned
  FROM studentPerformanceInCourse 
    INNER JOIN university.gradevalues
      ON studentPerformanceInCourse.grade = gradevalues.grade
ORDER BY studentPerformanceInCourse.sid
),
sumOfCreditsTaken AS
(--Gets sum of credits student has for all enrollments
SELECT sid, sum(credits) AS sumOfCredits FROM dataForGpaCalculation
GROUP BY sid
),
sumOfGPearned AS
(--Gets total grade points earned for all enrollments
SELECT sid, sum(GradePointsEarned) as sumOfGraP FROM dataForGpaCalculation
GROUP BY sid
)
SELECT students.sid, students.last, students.first, 
       students.gpa, (sumOfGraP/sumOfCredits) AS recalculatedGPA
  FROM sumOfCreditsTaken 
    INNER JOIN sumOfGPearned
      ON sumOfCreditsTaken.sid = sumOfGPearned.sid
    INNER JOIN university.students
      ON students.sid = sumOfCreditsTaken.sid
ORDER BY sid;
--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--REM Query 6: Cumulitive volume for each day of month

SELECT tradedate, SUM(volume) OVER (ORDER BY tradedate) AS DailyTot
  FROM stockmarket.dailyactivity
  WHERE ticker='CTIS';

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--REM Query 7: Cumulitive volume for each day of month for each stock
SELECT ticker, tradedate,  
       SUM(volume) OVER (PARTITION BY ticker 
                         ORDER BY tradedate) AS CumuTot
  FROM stockmarket.dailyactivity
ORDER BY ticker, tradedate;

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--REM Query 8: Find opening, closing, and difference in price for each day for
--             DCC stock
SELECT tradedate,
       LAG(close, 1) OVER (ORDER BY tradedate) AS openingPrice,
       close AS closingPrice,
       (close - LAG(close,1) OVER (ORDER BY tradedate)) AS priceChange
  FROM STOCKMARKET.dailyactivity
  WHERE ticker = 'DCC';
  
--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--REM Query 9 : Find day when stock was highest than in any other three day 
--              period
WITH threeDayAnly AS 
(
SELECT tradedate, volume, ticker,
       SUM(volume) OVER (ORDER BY tradedate ROWS 2 PRECEDING) as ThreeDayTot
  FROM stockmarket.dailyactivity
  WHERE ticker = 'XEM'
ORDER BY ThreeDayTot DESC
)
SELECT tradedate FROM threeDayAnly
WHERE ThreeDayTot = (SELECT MAX(ThreeDayTot) FROM threeDayAnly);


--------------------------------------------------------------------------------




--------------------------------------------------------------------------------
--REM Query 10


--------------------------------------------------------------------------------

