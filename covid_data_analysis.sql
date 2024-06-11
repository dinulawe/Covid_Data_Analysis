-- Altering the two table to have the "date" data type as datetime

alter table CovidData.covidvaccinations
modify date date;

alter table CovidData.coviddeaths
modify date date;


-- Looking at Total Cases vs Total Deaths

-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From CovidData.coviddeaths
where location like '%states%'
order by 1,2;


-- Looking for Total Cases vs Population

-- Shows what percentage of population got covid
Select location, date, total_cases,population_density,(total_deaths/population)*100 as PercentOfPopulationInfected
From CovidData.coviddeaths
where location like '%states%'
order by 1,2;


-- Looking at countries with highest infection rate compare to population
Select location,population, MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PercentOfPopulationInfected
From CovidData.coviddeaths
Group by location, population
order by PercentOfPopulationInfected desc;


-- Showing Countres with Highest Death count per population

Select location, MAX(cast(total_deaths as DECIMAL)) as TotalDeathCount
From CovidData.coviddeaths
-- Makes sure that the data returned does not have the total continent death count
Where continent != ""
Group by location 
order by TotalDeathCount desc;


-- Showing Continents with Highest Death count per population

-- ** Did not include Canada in North America
Select continent, MAX(cast(total_deaths as DECIMAL)) as TotalDeathCount
From CovidData.coviddeaths
-- Makes sure that the data returned does not have the total continent death count
Where continent != ""
Group by continent
order by TotalDeathCount desc;


-- GLOBAL NUMBERS
Select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as DECIMAL)) as TotalDeaths, SUM(CAST(new_deaths as DECIMAL))/ SUM(new_cases) * 100 as DeathPercentage
From CovidData.coviddeaths
where continent != ""
-- Group By date
order by 1,2;

-- Using CTE 
With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
-- Looking at the total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as DECIMAL)) OVER (partition by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData.coviddeaths dea
Join CovidData.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent != ""
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac;

-- Create View to Store Data for Later Visualtion
Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as DECIMAL)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidData.coviddeaths dea
Join CovidData.covidvaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
where dea.continent != "";
-- order by 2,3

Select *
From PercentPopulationVaccinated;



-- Queries for Tableau

-- 1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as decimal)) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(New_Cases)*100 as DeathPercentage
From CovidData.coviddeaths
where continent != "" 
order by 1,2;

-- 2
Select continent, SUM(cast(new_deaths as decimal)) as TotalDeathCount
From CovidData.coviddeaths
Where continent != "" 
-- and continent not in ('World', 'European Union', 'International')
Group by continent
order by TotalDeathCount desc;

-- 3
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidData.coviddeaths
Group by Location, Population
order by PercentPopulationInfected desc;

-- 4
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidData.coviddeaths
Group by Location, Population, date
order by PercentPopulationInfected desc




