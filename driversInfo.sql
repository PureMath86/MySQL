/*
Your company is an authorized Chevrolet dealer, and you have your own database of clients who come over for vehicle inspections. The problem is, right now it is not very convenient to analyze: it contains only the information retrieved during each inspection. You would like to make this database easier to use.
Information about the inspections is given in the table inspections that has the following columns:
inspection_id: unique inspection id;
driver_name: the name of the driver;
date: inspection date (they are guaranteed to be distinct for each driver);
miles_logged: the number of miles the vehicle covered since the previous inspection (or the time of the purchase if it's the first inspection ever).
Your goal is to make a new table with a single summary column containing the following information:
the first row should contain the total number of miles covered by all the drivers combined;
the following rows should contain information about each driver sorted by drivers' names:
the first row should contain driver's name, the total number of inspections and the total number of miles covered;
the following rows should contain information about each inspection: its date and the miles covered since the previous inspection (or the purchase time). The entries should be sorted by inspection dates.
Here's the format in which this information should be given:
summary
 Total miles driven by all drivers combined: <the sum of all driven miles>
 Name: [...]; days on road: [...]; miles driven: [...]
  date: [...]; miles covered: [...]
  date: [...]; miles covered: [...]
  ...
 Name: [...]; days on road: [...]; miles driven: [...]
  ...
Note, that every row should start with a whitespace character, and the rows containing information about the inspections should have one more leading whitespace character each (i.e. they should start with two whitespaces).
Example
For the following table inspections
inspection_id	driver_name	date	miles_logged
1	Gary	2014-03-15	256
2	Dave	2014-01-18	231
3	Dave	2014-01-16	45
4	Gary	2014-02-03	30
5	Dave	2014-01-17	180
the output should be
summary
 Total miles driven by all drivers combined: 742
 Name: Dave; days on road: 3; miles driven: 456
  date: 2014-01-16; miles covered: 45
  date: 2014-01-17; miles covered: 180
  date: 2014-01-18; miles covered: 231
 Name: Gary; days on road: 2; miles driven: 286
  date: 2014-02-03; miles covered: 30
  date: 2014-03-15; miles covered: 256
[time limit] 10000ms (mysql)
*/









/*Please add ; after each select statement*/
CREATE PROCEDURE driversInfo()
    SELECT s summary FROM 
    (SELECT CONCAT(" Total miles driven by all drivers combined: ", sum(miles_logged)) s, '' d, 0 o, 0 t  from inspections
    UNION
    select CONCAT(" Name: ", driver_name, "; days on road: ", COUNT(*), "; miles driven: ", SUM(miles_logged)) s, driver_name d, 1 o, date t from inspections group by driver_name
    UNION
    select CONCAT("  date: ", date, "; miles covered: ", miles_logged) s, driver_name d, 2 o, date t from inspections) f ORDER BY d, o, t;








/*Please add ; after each select statement*/
SET SQL_MODE = 2; /* PIPES_AS_CONCAT */
CREATE PROCEDURE driversInfo()
SELECT 
 IF(d, '  date: ' || d || '; miles covered: ',
  IF(!n, ' Name: ' || n || '; days on road: ' || t || '; miles driven: ',
   ' Total miles driven by all drivers combined: ')) || s summary
FROM (
 SELECT driver_name n, date d, SUM(miles_logged) s, COUNT(*) t
 FROM inspections
 GROUP BY n, d
 WITH ROLLUP
) m
ORDER BY n, d







/*Please add ; after each select statement*/
CREATE PROCEDURE driversInfo()
BEGIN

CREATE TEMPORARY TABLE IF NOT EXISTS summaryTable (
    entryType int,
    driver_name VARCHAR(100) NOT NULL,
    summary VARCHAR(500) NOT NULL,
    dater DATETIME
);

CREATE TEMPORARY TABLE IF NOT EXISTS driverDailyTotals AS 
(select driver_name, date, sum(miles_logged) as dailyMiles from inspections
group by driver_name, date order by date asc);

CREATE TEMPORARY TABLE IF NOT EXISTS driverTotals AS 
(select driver_name, count(*) as daysOnRoad, sum(miles_logged) as totalMiles from inspections
group by driver_name);

CREATE TEMPORARY TABLE IF NOT EXISTS driverList AS 
(select driver_name from inspections
group by driver_name);

select sum(miles_logged) into @milesTotal from inspections; 

insert into summaryTable values (0,"",CONCAT(" Total miles driven by all drivers combined: ", @milesTotal),null);

insert into summaryTable
select 1 as entryType, driverList.driver_name, CONCAT(" Name: ",driverList.driver_name,"; days on road: ", daysOnRoad, "; miles driven: ", totalMiles) as entry,null from driverList inner join driverTotals ON driverList.driver_name = driverTotals.driver_name;


insert into summaryTable
select 2 as entryType, driverList.driver_name, CONCAT("  date: ", driverDailyTotals.date, "; miles covered: ",driverDailyTotals.dailyMiles) as entry, driverDailyTotals.date from driverList inner join driverDailyTotals ON driverList.driver_name = driverDailyTotals.driver_name order by date asc;

select summary from summaryTable order by driver_name, entryType, dater;

drop table if exists driverTotals;
drop table if exists driverList;
drop table if exists summaryTable;
drop table if exists driverDailyTotals;

END











/*Please add ; after each select statement*/
CREATE PROCEDURE driversInfo()
BEGIN
    Declare Total_Miles_Logged Int Default 0;
    Declare Driver_Miles_Logged Int Default 0;
    Declare Driver_Days_Logged Int Default 0;
    Declare Last_Driver_Name Varchar(45) Default '';
    Declare Current_Sequence Int Default 0;
    
    Declare Current_Driver_Name Varchar(45) Default '';
    Declare Inspection_Date Date;
    Declare Current_Miles_Logged Int(11) Default 0;
    Declare Current_Summary Varchar(250);

    Declare done Int Default False;
    Declare cursor_inspections Cursor For Select driver_name, date, miles_logged From inspections Order By driver_name desc, date desc;
    Declare Continue Handler For Not Found Set done = True;

    Drop Temporary Table If Exists myOutput;
    Create Temporary Table myOutput ( sequence Int primary key, summary varchar(250) );

    Open cursor_inspections;
    read_loop: Loop
        Fetch cursor_inspections Into Current_Driver_Name, Inspection_Date, Current_Miles_Logged;

        If Current_Sequence = 0 Then
            Set Last_Driver_Name = Current_Driver_Name;
        End If;

        If done Or Current_Driver_Name != Last_Driver_Name Then
            Set Current_Sequence = Current_Sequence + 1;
            Set Current_Summary = Concat(' Name: ', Last_Driver_Name, '; days on road: ', Driver_Days_Logged, '; miles driven: ', Driver_Miles_Logged);
            Insert into myOutput values(Current_Sequence, Current_Summary);

            Set Driver_Miles_Logged = 0;
            Set Driver_Days_Logged = 0;
            Set Last_Driver_Name = Current_Driver_Name;
        End If;
        If done Then
            Leave read_loop;
        End If;
        
        Set Current_Sequence = Current_Sequence + 1;
        Set Current_Summary = Concat('  date: ', Date_Format(Inspection_Date, Get_Format(Date,'ISO')), '; miles covered: ', Current_Miles_Logged);

        Insert into myOutput values(Current_Sequence, Current_Summary); 
        Set Driver_Days_Logged = Driver_Days_Logged + 1;
        Set Driver_Miles_Logged = Driver_Miles_Logged + Current_Miles_Logged;
        Set Total_Miles_Logged = Total_Miles_Logged + Current_Miles_Logged;        
	End Loop;
    Close cursor_inspections;

    Set Current_Sequence = Current_Sequence + 1;
    Set Current_Summary = Concat(' Total miles driven by all drivers combined: ', Total_Miles_Logged);
    Insert into myOutput values(Current_Sequence, Current_Summary);

    Select summary from myOutput order by sequence desc;
END
