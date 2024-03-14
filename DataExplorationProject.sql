SELECT*
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4

--Altering column
ALTER TABLE Project1..CovidDeaths
ALTER COLUMN total_cases nvarchar(255);

ALTER TABLE Project1..CovidDeaths
ALTER COLUMN total_deaths nvarchar(255);
-----------------------------------------------------------------------------------
SELECT*
FROM Project1..CovidVaccination
ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM Project1..CovidDeaths
ORDER BY 3,4

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--HOW IS LIKELIHOOD OF DYING IN COVID IN YOUR COUNTRY

SELECT location,date,total_cases,total_deaths, 
CASE 
WHEN TRY_CONVERT(float, total_cases) = 0 THEN NULL -- Handling division by zero or non-numeric values
ELSE TRY_CONVERT(float, total_deaths) / TRY_CONVERT(float, total_cases)*100 
END AS death_rate
FROM Project1..CovidDeaths
WHERE LOCATION LIKE '%nepal%'
ORDER BY 3,4 
    
--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT % OF POPULATION GOT COVID

SELECT location,date,Population,total_cases,
CASE
WHEN TRY_CONVERT(float, population)=0 THEN NULL
ELSE TRY_CONVERT(float, total_cases)/TRY_CONVERT(FLOAT,population)*100
END AS PercentageOfCovidInfect
FROM Project1..CovidDeaths
WHERE LOCATION LIKE '%nepal%'
ORDER BY 3,4

--WHAT COUNTRY HAS THE HIGHEST INFECTION RATE

SELECT location,Population,MAX(total_cases) AS HighestInfectionCount,
CASE
WHEN MAX(TRY_CONVERT (float, population))=0 THEN NULL
ELSE MAX(TRY_CONVERT (float, total_cases)/TRY_CONVERT(FLOAT,population))*100
END AS InfectedPopulation
FROM Project1..CovidDeaths
--WHERE LOCATION LIKE '%dorra%'
GROUP BY location,population
ORDER BY InfectedPopulation desc

--LOOKING AT COUNTRY OF HIGHEST DEATH 

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCounts
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC

--LETS BREAK THINGS DOWN BY CONTINENT

SELECT location,MAX(CAST(total_deaths AS INT)) AS TotalDeathCounts
FROM Project1..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC

--OR

SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCounts
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC

--SHOWING THE CONTINENT WITH HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS HighestDeath
FROM Project1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeath DESC

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases,SUM(new_deaths) as total_deaths, 
CASE 
WHEN SUM(TRY_CONVERT(float, new_cases)) = 0 THEN NULL -- Handling division by zero or non-numeric values
ELSE SUM(TRY_CONVERT(float, new_deaths)) / SUM(TRY_CONVERT(float, new_cases))*100 
END AS DeathPercentage
FROM Project1..CovidDeaths
--WHERE LOCATION LIKE '%nepal%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 2,3

--LOOKIING AT TOTAL POPULATION VS VACCINATION

SELECT dea.continent, Dea.location,Dea.date,Dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, dea.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/population)*100 WE CANT USE CREATED TABLE SOLVE SO WE TRY CTE OR TEMP TABLE
FROM Project1..CovidDeaths Dea
JOIN Project1..CovidVaccination Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date 
WHERE Dea.continent IS NOT NULL
ORDER BY 2,3 

--USE CTE

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, Dea.location,Dea.date,Dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Project1..CovidDeaths Dea
JOIN Project1..CovidVaccination Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date 
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3 
)

SELECT* , (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, Dea.location,Dea.date,Dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Project1..CovidDeaths Dea
JOIN Project1..CovidVaccination Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date 
--WHERE Dea.continent IS NOT NULL
ORDER BY 2,3

SELECT* , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, Dea.location,Dea.date,Dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY Dea.location ORDER BY Dea.location, dea.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM Project1..CovidDeaths Dea
JOIN Project1..CovidVaccination Vac
ON Dea.location=Vac.location
AND Dea.date=Vac.date 
WHERE Dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated
