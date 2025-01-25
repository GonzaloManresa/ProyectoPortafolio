SELECT  * 
FROM ProyectoPortafolio.coviddeath
WHERE continent IS NOT NULL 
order by 3,4 desc
;

-- Select Data that we are going to be using
select location, date,  total_cases, new_cases, total_deaths, population
from coviddeath
order by 1,2;

-- How many people was infected?
select location, population,  MAX(total_cases) as Infections, MAX(total_cases/population)*100 as PercentPopulationInfected
from coviddeath
group by location, population
order by PercentPopulationInfected desc;

-- How many people dead by country?
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathsCount	
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount  DESC;

-- How many people dead by continent?
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathsCount	
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY  TotalDeathsCount DESC;

-- Correct answer of: How many people dead by continent?
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathsCount	
FROM coviddeath
WHERE continent IS  NULL
GROUP BY location
ORDER BY  TotalDeathsCount DESC;

-- How many people deaded by 'x' continent?
SELECT location, MAX(CAST(total_deaths AS UNSIGNED)) AS TotalDeathsCount	
FROM coviddeath
WHERE continent = 'Africa' -- I can change the name of the continent
GROUP BY location
ORDER BY  TotalDeathsCount DESC;

-- GLOBAL NUMBERS!
select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from coviddeath
WHERE continent is not null 
GROUP BY date
order by 1,2 ;

select SUM(new_cases) as TotalCases,SUM(new_deaths) as TotalDeaths, round((SUM(new_deaths)/ SUM(new_cases))*100,3) as DeathsPercentage
from coviddeath
WHERE continent is not null 
-- GROUP BY date
order by DeathsPercentage DESC;

-- Looking for Vaccination Information
SELECT continent, location, date, total_cases, new_cases, new_deaths, total_tests, total_vaccinations
FROM ProyectoPortafolio.covidvaccination
where continent IS NOT NULL
order by date asc

-- Looking Total Population VS Total Vaccination
With PopvsVac( continent,location,fecha,population,new_vaccinations,RollingPeopleVaccination)
as
(
SELECT dea.continent, dea.location, STR_TO_DATE(dea.date, '%d/%m/%y') AS fecha, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY  STR_TO_DATE(dea.date, '%d/%m/%y')) as RollingPeopleVaccination
FROM ProyectoPortafolio.coviddeath dea
JOIN ProyectoPortafolio.covidvaccination vac
	ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent != ''  
-- ORDER BY 2,3 asc
)

-- USE CTE
SELECT *, (RollingPeopleVaccination/population)*100
FROM PopvsVac




-- Format changes
UPDATE covidvaccination
SET date = STR_TO_DATE(date, '%d/%m/%y')
WHERE date REGEXP '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2}$';

UPDATE coviddeath
SET 
    ProyectoPortafolio.coviddeath.continent = ProyectoPortafolio.covidvaccination.continent

UPDATE covidvaccination
SET 
    continent = NULLIF(total_deaths, '');
SET SQL_SAFE_UPDATES = 0;

ALTER TABLE coviddeath
MODIFY COLUMN continent text DEFAULT NULL;
