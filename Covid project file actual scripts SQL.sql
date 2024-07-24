


--select * from PortfolioProject.dbo.covidvaccinations
--order by 3, 4


-- select data that we are going to be using


--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject.dbo.coviddeaths
--order by 1 , 2


-- looking at total cases vs total deaths
-- shows the likelihood of dying if you attract covid in your country


select location, date, total_cases,total_deaths,  CAST(total_deaths AS float) / NULLIF(CAST(total_cases AS float), 0) * 100 AS death_percentage
from PortfolioProject.dbo.coviddeaths
Where location like '%states%'
order by 1 , 2


-- Looking at the total cases vs population


select location, date, total_cases, population,  (CAST(total_cases AS float) / population * 100) AS death_percentage
from PortfolioProject.dbo.coviddeaths
where location like '%india%'
order by 1 , 2


-- looking at countries with highest infection rate compared to population

select location, population, MAX(CAST(total_cases as float)) as HighestInfectionCount , MAX((CAST(total_cases AS float) / population) * 100) AS PercentagePopulationInfected
from PortfolioProject.dbo.coviddeaths
--where location like '%india%'
group by location, population
order by PercentagePopulationInfected desc


-- showing the countries with highest death count per population

select location, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
where continent is not null
group by location
order by TotalDeathCount desc

select * from PortfolioProject.dbo.coviddeaths
where continent is not null
order by 3, 4

-- LET'S BREAK THING DOWN BY CONTINENT

select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.dbo.coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Showing the continents with highest death count per population


-- GLOBAL NUMBERS


SELECT 
    SUM(new_cases) AS TotalCases, 
    SUM(CAST(new_deaths AS int)) AS TotalDeaths,
    SUM(CAST(new_deaths AS int)) * 100.0 / sum(new_cases)  AS deathpercentage
FROM 
    PortfolioProject.dbo.coviddeaths
WHERE 
    continent IS NOT NULL
ORDER BY 
    1, 2




-- looking at total population vs vaccinations

--using CTE for reusing rollingpeoplevaccinated


With PopvsVacc (Continent, location, date, population,New_vaccinations, RollingPeopleVaccinated)
as(
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
 sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccinations vac
on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

Select * , (RollingPeopleVaccinated /population * 100) from PopvsVacc


-- TempTable


DROP TABLE IF EXISTS #PercentPopulationVaccinated 
 
Create Table #PercentPopulationVaccinated(Continent nvarchar(255), 
Location nvarchar(255), Date datetime, Population numeric, New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
 sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccinations vac
on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select * , (RollingPeopleVaccinated /population * 100) from #PercentPopulationVaccinated



--Creating View to store data for later visualizations


Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date ,dea.population, vac.new_vaccinations,
 sum(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) * 100
from PortfolioProject.dbo.coviddeaths dea
join PortfolioProject.dbo.covidvaccinations vac
on dea.location = vac.location AND dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select * from PercentPopulationVaccinated

