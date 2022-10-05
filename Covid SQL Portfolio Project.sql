--SELECT *
--FROM CovidDeaths$
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths$
ORDER BY 1,2


--Total cases vs total deaths
--Shows likelihood of death if you contract covid in your country (United States)
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths$
Where continent is not null
WHERE location LIKE '%states%'
ORDER BY 1,2


--Viewing total cases vs Population
--Highlights percentage of population that contracted covid (United States)
SELECT location, date,Population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM CovidDeaths$
Where continent is not null
WHERE location LIKE '%states%'
ORDER BY 1,2


-- Viewing countries with highest infection rate compared to population
SELECT location,Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths$
Where continent is not null
GROUP BY Population, Location
ORDER BY PercentPopulationInfected DESC


--Viewing countries with the highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
Where continent is not null
GROUP BY  Location
ORDER BY TotalDeathCount DESC


--Viewing continent with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM CovidDeaths$
Where continent is not null
GROUP BY  continent
ORDER BY TotalDeathCount DESC


--Global Numbers
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM CovidDeaths$
Where continent is not null
ORDER BY 1,2


--Combining CovidDeaths table with CovidVaccinations table
SELECT*
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
on dea.location = vac.location
AND dea.date = vac.date


--Viewing total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
on dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER  BY 2,3


--Temp Table
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
FROM CovidDeaths$ dea
JOIN CovidVaccinations$ vac
on dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

SELECT*, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

