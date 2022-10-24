SELECT *
FROM SQL_DB1.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM SQL_DB1.dbo.CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQL_DB1.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at Total Cases vs Total Deaths
-- Shows the probability of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM SQL_DB1.dbo.CovidDeaths
WHERE location='Spain'
ORDER BY 1,2


-- Looking at the Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 AS infection_percentage
FROM SQL_DB1.dbo.CovidDeaths
WHERE location='Spain'
ORDER BY 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS infection_percentage
FROM SQL_DB1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC


-- Showing Countries with Highest Death Count per Population

SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PopulationMortalityPercentage
FROM SQL_DB1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY 4 DESC

-- Let's do it by continent now

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount, MAX((total_deaths/population))*100 AS PopulationMortalityPercentage
FROM SQL_DB1.dbo.CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY 2 DESC


-- Global Numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM SQL_DB1.dbo.CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS death_percentage
FROM SQL_DB1.dbo.CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM SQL_DB1.dbo.CovidDeaths dea
JOIN SQL_DB1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM SQL_DB1.dbo.CovidDeaths dea
JOIN SQL_DB1.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageVaccinated
FROM PopvsVac