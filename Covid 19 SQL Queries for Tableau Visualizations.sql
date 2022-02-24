/*
COVID-19 SQL Queries used for Tableau Visualizations

*/

-- Query -1
-- GLOBAL NUMBERS


Select SUM(new_cases) as 'Total Infected People', SUM(cast(new_deaths as int)) as 'Total Death', SUM(cast(new_deaths as int))/SUM(New_Cases) * 100 AS 'Death Percentage'
From CovidDeaths
where continent is not null

-- Query - 2
-- Calculating Continent wise Total Death Count
-- European Union is part of Europe


SELECT location, SUM(CAST(new_deaths AS int)) AS 'TotalDeathCount'
FROM CovidDeaths
WHERE continent IS  NULL -- Continent wise total death count
AND location NOT IN ('World', 'European Union', 'International' , 'High income', 'Low income',
'Lower middle income' , 'Upper middle income')
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Query - 3
-- Countries with Highest Infection Percentage compared to Population

SELECT location, population, MAX(total_cases) AS 'TotalInfectedPopulation', MAX(total_cases/population) * 100 AS 'InfectedPopulationPercentage' 
FROM CovidDeaths
GROUP BY location,population
ORDER BY InfectedPopulationPercentage DESC


-- Query - 4
-- Countries with Highest Infection Percentage compared to Population

SELECT location,date, population, MAX(total_cases) AS 'TotalInfectedPopulation', MAX(total_cases/population) * 100 AS 'InfectedPopulationPercentage' 
FROM CovidDeaths
GROUP BY location,population, date
ORDER BY InfectedPopulationPercentage DESC



