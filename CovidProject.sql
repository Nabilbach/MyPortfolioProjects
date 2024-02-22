--Select*
--From ProtfolioProject..CovidDeaths
--Order by 3,4

--Select*
--From ProtfolioProject..CovidVaccination
--Order by 3,4

-- Select data that we are going to be using.

select location, date,total_cases, new_cases, total_deaths,population
from ProtfolioProject..CovidDeaths
Order by 1,2

--- Looking at total cases vs total deaths

select location, date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS DPC
from ProtfolioProject..CovidDeaths
Where location like '%states%'
Order by DPC desc
--- Shows what percentage of population got covid
Select location,date,total_cases,population,(total_cases / population)*100 as PercentPopulationInfected
from ProtfolioProject..CovidDeaths
Where location like '%states%'
order by 1,2

--- Looking at countries with Highest infection rate compared to population
Select location,Max(total_cases) As HIC ,population,Max((total_cases / population))*100
as PercentPopulationInfected
from ProtfolioProject..CovidDeaths
--Where location like '%states%'
Group by  location, population
order by 4 Desc

-- Showing countries with highest deaths count per population
Select location,Max(Cast(total_deaths as int)) as maxTD
from ProtfolioProject..CovidDeaths
Where continent is not null
Group by  location
order by maxTD desc

-- Break things by continent
Select continent,Max(Cast(total_deaths as int)) as maxTD
from ProtfolioProject..CovidDeaths
Where continent is not null
Group by  continent
order by maxTD desc

-- Globale numbers
Select Sum(new_cases) as WorldTotalNewCasesPerDay, sum(cast(new_deaths as int)) as sumDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathperctn
from ProtfolioProject..CovidDeaths
Where continent is not null 
--Group by date
order by 1,2
--- use CTE
with PopvsVac(continent, location, population, date, new_vaccinations, RollingPeopleVaccinated) 
as 
(

--- Looking at Total Population Vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location
,dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	on vac.date = dea.date
	and dea.location = vac.location
where dea.continent is not null
---order by 2,3
)
select* , (RollingPeopleVaccinated/population)*100
from PopvsVac

--- Temp table
Create Table #PPV
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PPV
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location
,dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	on vac.date = dea.date
	and dea.location = vac.location
where dea.continent is not null 
---order by 2,3
select* , (RollingPeopleVaccinated/population)*100
from #PPV

--- Creating view to store data for later visualisations

Create View PPV as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location
,dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 
from ProtfolioProject..CovidDeaths dea
join ProtfolioProject..CovidVaccination vac
	on vac.date = dea.date
	and dea.location = vac.location
where dea.continent is not null 
--order by 2,3

