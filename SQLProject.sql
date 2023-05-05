/*
COVID-19 DATA EXPLOARATION
*/


SELECT *
FROM PortrfolioProject..CovidDeaths
where continent is NOT NULL
order by 3,4


--Select data to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortrfolioProject..CovidDeaths
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Likelihood of dying if you contract covid in Nigeria 

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortrfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1, 2

--Looking at Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasesPercentage
FROM PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
order by 1, 2

--Looking at countries with  the Highest Infection Rate

SELECT continent, population, MAX(total_cases) as HighestInfectionCount,
MAX(total_deaths/population)*100 as PercentOfInfectedPopulation
FROM PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
Group by continent,population 
order by PercentOfInfectedPopulation desc

--showing countries with Highest Death Count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is NOT NULL
Group by Location 
order by TotalDeathCount desc

-- LET'S BREAK IT DOWN BY CONTINENT
--showing the continent with the highest death counts

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not NULL
Group by continent 
order by TotalDeathCount desc

--Breaking Global numbers

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by date
order by 1, 2

--TOTAL DEATHS IN THE WHOLE WORLD
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
order by 1, 2

--JOINING DEATHS AND VACCINATION TABLE

select *
from PortrfolioProject..CovidDeaths as dea
join PortrfolioProject..CovidVaccinations as vac
	on dea.location =vac.location
	and dea.date =vac.date

--Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortrfolioProject..CovidDeaths as dea
join PortrfolioProject..CovidVaccinations as vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

--USE CTE to perform calculation on Partition By 

with PopvsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortrfolioProject..CovidDeaths as dea
join PortrfolioProject..CovidVaccinations as vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Using Temp table to perfom calculation on Partition By

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortrfolioProject..CovidDeaths as dea
join PortrfolioProject..CovidVaccinations as vac
	on dea.location =vac.location
	and dea.date =vac.date
--where dea.continent is not null
--order by 2,3
select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


--Creating view to store data for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortrfolioProject..CovidDeaths as dea
join PortrfolioProject..CovidVaccinations as vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

create view PopvsVac as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) 
OVER (Partition by dea.location order by dea.location, dea.date) 
as RollingPeopleVaccinated
from PortrfolioProject..CovidDeaths as dea
join PortrfolioProject..CovidVaccinations as vac
	on dea.location =vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3

select *
from PopvsVac

create view TotalDeaths as
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
--group by date
--order by 1, 2

select *
from TotalDeaths

create view GlobalDeathsPerDay as
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totaldeaths, 
(SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortrfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null
group by date
--order by 1, 2

select *
from GlobalDeathsPerDay