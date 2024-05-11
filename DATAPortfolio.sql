--Data in table CovidDeaths
SELECT * 
 FROM 
  CovidDeaths
   ORDER BY 3,4

--Data we are going to using
SELECT Location, date, total_cases, New_cases, total_deaths, population 
 FROM 
  CovidDeaths 
   ORDER BY 1,2

--Total Cases / Total deaths 
SELECT Location, date, total_cases, New_cases, total_deaths, (total_cases/total_deaths)*100 DeathPercentage 
 FROM 
  CovidDeaths
  WHERE
   location LIKE '%india%'
    ORDER BY 1,2

--Show what percentage of population got covid
SELECT Location, date, Population, total_cases, (total_cases/Population)*100 PercentagePopulationInfected 
 FROM 
  CovidDeaths
  --WHERE
  -- location LIKE '%india%'
    ORDER BY 1,2

--Looking for country with higest infection rate
SELECT location,population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/Population)*100) PercentagePopulationInfected
 FROM
  CovidDeaths
   GROUP BY location, population
   ORDER BY PercentagePopulationInfected DESC

--Showing total count of highest Death cases
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM
  CovidDeaths
   Where continent IS NOT Null
    GROUP BY location
     ORDER BY TotalDeathCount DESC

--Breaking down by continents
--TotalDeathCount by continents
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM
  CovidDeaths
   Where continent IS NOT Null
    GROUP BY continent
     ORDER BY TotalDeathCount DESC

--Global Numbers
SELECT date, SUM(New_cases) as total_cases ,SUM(cast(New_deaths as int)) as total_deaths, (SUM(cast(New_deaths as int))/SUM(New_cases))*100 as Deathpercentage
FROM 
  CovidDeaths
  WHERE continent IS NOT Null
   GROUP BY date
    ORDER BY 1,2

--Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(new_vaccinations AS int)) OVER (partition by dea.location by dea.location, dea.date) as RollingpeopleVaccinated,
 (RollingpeopleVaccinated/population)*100
 FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT Null
	ORDER BY 2,3

--Using CTE
WITH PopvsVac (continen, location, date, population, New_vaccinations, RollingpeopleVaccinated)
as
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER By dea.location, dea.date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated/population)*100 
 FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
	WHERE dea.continent IS NOT Null
	--ORDER BY 2,3
	)
	SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM PopvsVac


--Temp Table
DROP TABLE IF EXISTS #percentpopulationVaccinated
CREATE TABLE #percentpopulationVaccinated
(
continent nvarchar(255),
Loaction nvarchar(255),
date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #percentpopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER By dea.location, dea.date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated/population)*100 
 FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
	--WHERE dea.continent IS NOT Null
	--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
	FROM #percentpopulationVaccinated

--CREATINF VIEWS to store date for later visuilizations

CREATE VIEW percentpopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location ORDER By dea.location, dea.date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated/population)*100 
 FROM CovidDeaths as dea
	JOIN CovidVaccinations as vac
	ON dea.location = vac.location AND dea.date = vac.date
	--WHERE dea.continent IS NOT Null
	--ORDER BY 2,3

