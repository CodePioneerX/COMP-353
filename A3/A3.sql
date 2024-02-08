
/*
Exercise #1

Airport (airportCode, city, state)
FlightLeg (legNum, flightID)
Flights (flightID, flightName)
FlightAgents (agentID, flightID, Fare)
Orders (orderID, agentID, flightID, num_of_tickets)
Details (airportCode, legNum, bookedDate, duration)
Agents (agentID, agentName)
*/

/* 1. Agents Tom and Jerry takes care of which flights? */

SELECT Flights.flightName
FROM Flights, Agents, FlightAgents
WHERE FlightAgents.agentID = Agents.agentID 
AND FlightAgents.flightID = Flights.flightID
AND (Agents.agentName = ‘Tom’ OR Agents.agentName = ‘Jerry’);

/*
The SQL query is designed to find out which flights are taken care of by the agents named Tom and Jerry
The query assumes that the table named FlightAgents serves as a mapping table connecting agents to the flights they handle. It is assumed that FlightAgents contains foreign keys agentID and flightID that reference the agentID and flightID in the Agents and Flights tables, respectively.
The result of the query includes two columns: agentName (the name of the agent) and flightName (the name of the flight), allowing you to see which agents (Tom and Jerry) handle which flights.
*/


/* 2. Which flight has the longest duration? */

SELECT DISTINCT Flights.flightName, MAX(Details.duration)
FROM FlightLeg, Flights, Details
WHERE FlightLeg.flightID = Flights.flightID
AND FlightLeg.legNum = Details.legNum
ORDER BY Details.duration DESC
LIMIT 1;

/*
The SQL query aims to identify the flight with the longest duration among all flights.
The query assumes that the Flights table contains information about flights, including flight names and flight IDs.
The query assumes that the Details table contains information about flight durations and is related to flight legs through the legNum column.
The query joins the tables FlightLeg, Flights, and Details based on their respective keys (flightID and legNum) to calculate the maximum duration for each flight.
The query is ordered by Details.duration in descending order
Finally, the LIMIT 1 clause is applied to retrieve only the top row, which corresponds to the flight with the longest duration.
*/


/* 3. Which agents can take care of all the flights mentioned in the inventory? */

SELECT Agents.agentID, Agents.agentName
FROM Agents, Flights
GROUP BY Agents.agentID, Agents.agentName
HAVING COUNT(DISTINCT Flights.flightID) = (SELECT COUNT(*) FROM Flights);

/*
The query groups results by the agents' agentID and `agentName to count the number of distinct flights they take care of.
The HAVING clause is used to filter the grouped results, checking whether the count of distinct flights assigned to each agent is equal to the total count of flights in the inventory. Agents who take care of all the flights are selected.
*/


/* 4. Determine for each flight agent, the number of flights booked, present in the inventory? */

SELECT Agents.agentName, COUNT(FlightAgents.flightID), COUNT(FlightLeg.flightID)
FROM Agents, FlightAgents, FlightLeg
WHERE FlightAgents.flightID = FlightLeg.flightID 
AND Agents.agentID = FlightAgents.agentID
GROUP BY Agents.agentName;

/*
Agent-Flight Relationship: The FlightAgents table is assumed to contain data that links agents to the flights they have booked.
Inventory of Flights: The query assumes that the FlightLeg table represents a complete inventory of flights that are booked.
The results are grouped by agentName, implying that the query will count the flights for each individual agent.
*/


/* 5. For which flights, there have been more than 100 tickets ordered? */

SELECT Orders.flightID, Flights.flightName, SUM(Orders.num_of_tickets)
FROM Orders, Flights 
WHERE Orders.flightID = Flights.flightID
GROUP BY Orders.flightID, Flight.flightName
HAVING SUM(Orders.num_of_tickets) > 100;

/*
Flight-Order Relationship: The Orders table is assumed to contain data that associates orders with specific flights using the flightID column.
The query uses the SUM(Orders.num_of_tickets) function to calculate the total number of tickets ordered for each flight.
The results are grouped by both flightID and flightName to show the flight information alongside the total tickets ordered.
The HAVING clause is used to filter the results and include only those flights for which the sum of ordered tickets is greater than 100.
*/


/* 6. Which flights booked Air Canada or booked a flight managed by Tom? */

SELECT DISTINCT Airport.city
FROM Airport, Flights, FlightAgents, Agents, Orders
WHERE Flights.flightID = FlightAgents.flightID
AND Agents.agentID = FlightAgents.agentID
AND Agents.agentID = Orders.agentID
AND Flights.flightID = Orders.flightID
AND (Agents.agentName = ‘Tom’ OR Flights.flightName = ‘Air Canada’);

/*
The Flights table is assumed to contain data that associates flights with orders using the flightID column.
The FlightAgents table is assumed to contain data linking flights with agents using the agentID and flightID columns.
The query checks for flights managed by "Tom" by filtering based on the agent's name (Agents.agentName = 'Tom').
The query checks for flights booked with "Air Canada" by filtering based on the flight's name (Flights.flightName = 'Air Canada').
*/


/* 7. Which flights booked flights for a duration of at least 10 days? */

SELECT Airport.airportCode, Airport.city, Airport.state
FROM Airport, Flights, FlightLeg, Details
WHERE Flights.flightID = FlightLeg.flightID
AND FlightLeg.legNum = Details.legNum
AND Details.duration >= 10;

/*
The Details table is assumed to contain information about the duration of each flight's leg, and this duration is measured in days.
Join the Flights, FlightLeg, and Details tables based on shared keys (flightID and legNum).
The query filters the results to include only flights with a duration of at least 10 days (Details.duration >= 10).
The query intends to retrieve flight names and durations
*/


/* 8. Which flights were booked exactly twice to any flight(s)? Do not use aggregate function count for this query. */

SELECT DISTINCT Flights.flightName
FROM Flights
JOIN Orders O1 ON Flights.flightID = O1.flightID
JOIN Orders O2 ON Flights.flightID = O2.flightID
WHERE O1.orderID <> O2.orderID;

/*
The Orders table is assumed to contain data that associates orders with specific flights using the flightID.
The query uses a self-join on the Flights table to compare each flight with other flights.
The condition O1.orderID <> O2.orderID is used to exclude self-matching, ensuring that the same order is not counted twice for the same flight.
The results are grouped by Flights.flightName, which is the flight name.
*/


/*
Exercise #2

Emp (eid: integer, ename: string, age: integer, salary: real)
Works (eid: integer, did: integer, pct_time: integer)
Dept (did: integer, dname: string, budget: real, managerid: integer)
*/


/* 1. Print the names and ages of each employee who works in both the Hardware department and the Software department. */

SELECT E.ename, E.age 
FROM Emp E, Works W1, Works W2, Dept D1, Dept D2 
WHERE E.eid = W1.eid
AND W1.did = D1.did
AND D1.dname = ‘Hardware’
AND E.eid = W2.eid
AND W2.did = D2.did
AND D2.dname = ‘Software’;


/* 2. For each department with more than 20 full-time-equivalent employees (i.e., where the part-time and full-time employees add up to at least that many full-time employees), print the “did” together with the number of employees that work in that department. */

SELECT W.did, COUNT (W.eid)
FROM Works W
GROUP BY W.did
HAVING 2000 <  ( SELECT SUM (W1.pct_time) 
    FROM Works W1 
    WHERE W1.did = W.did );


/* 3. Print the name of each employee whose salary exceeds the budget of all of the departments that he or she works in. */

SELECT E.ename
FROM Emp E
WHERE E.salary > ALL ( SELECT D.budget
  					   FROM Dept D, Works W
  					   WHERE E.eid = W.eid
  					   AND  D.did = W.did);


/* 4. Find the “managerids” of managers who manage only departments with budgets greater than $1 million. */

SELECT DISTINCT D.managerid
FROM Dept D
WHERE 1000000 < ALL ( SELECT D2.budget
        FROM Dept D2
        WHERE D2.managerid = D.managerid );


/* 5. Find the “enames” of managers who manage the departments with the largest budgets. */

SELECT E.ename
FROM Emp E
WHERE E.eid IN ( SELECT D.managerid
FROM Dept D
WHERE D.budget = ( SELECT MAX (D2.budget) FROM Dept D2 ) );


/* 6. If a manager manages more than one department, he or she controls the sum of all the budgets for those departments. Find the “managerids” of managers who control more than $5 million. */

SELECT D.managerid
FROM Dept D
WHERE 5000000 < ( SELECT SUM (D2.budget) 
        FROM Dept D2
        WHERE D2.managerid = D.managerid );
	
	
/* 7. Find the “managerids” of managers who control the largest amounts. */

CREATE VIEW Manager AS 
SELECT DISTINCT D.managerid, SUM(D.budget) AS tempBudget FROM Dept D 
GROUP BY D.managerid;

SELECT DISTINCT managerid 
FROM Manager 
WHERE tempBudget = ( SELECT MAX(tempBudget) FROM Manager );


/* 8. Find the “enames” of managers who manage only departments with budgets larger than $1 million, but at least one department with a budget less than $5 million. */

SELECT E.ename 
FROM Emp E, Dept D 
WHERE E.eid = D.managerid
GROUP BY E.eid, E.ename 
HAVING EVERY(D.budget > 1000000) AND ANY(D.budget < 5000000);