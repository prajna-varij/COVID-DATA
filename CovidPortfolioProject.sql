Select * From PortfolioProject..['covid-vaccine']
Where continent is not null
order by 3,4

--Select * From PortfolioProject..['covid-deaths']

--order by 3,4

-- Selecting the Data

Select Location, date,total_cases,new_cases,total_deaths,population
From PortfolioProject..['covid-deaths']
order by 1,2

-- Total cases vs Total deaths

Select Location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths']
--Covid Deaths percentage in India
Where location like '%India%'
order by 1,2


-- Total cases vs Population
-- Percentage of Covid Effected Population
Select Location, date,population,total_cases,(total_cases/Population)*100 as CovidPercentage
From PortfolioProject..['covid-deaths']
Where location like '%India%'
order by 1,2


-- Countries with highest infection rate vs Population
Select Location,MAX(total_cases) as HighestperCountry,Population, MAX((total_deaths/total_cases))*100 as InfectedPop
From PortfolioProject..['covid-deaths']
--Where location like '%India%'
Group by Location,Population
order by InfectedPop desc

-- Countries with highest Death count as per population

Select Location,MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..['covid-deaths']
Where continent is not null
--Where location like '%India%'
Group by Location
order by TotalDeaths desc

-- Continents with highest death count 
Select continent,MAX(cast(total_deaths as int)) as TotalDeaths
From PortfolioProject..['covid-deaths']
Where continent is not null
--Where location like '%India%'
Group by continent
order by TotalDeaths desc


-- Global

Select date,SUM(new_cases) as tota_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..['covid-deaths']
--Covid Deaths percentage in India
--Where location like '%India%'
where continent is not null
Group by date
order by  1,2

-- Vaccinations

Select *
From PortfolioProject..['covid-deaths'] dea
Join PortfolioProject..['covid-vaccine'] vac
	On dea.location = vac.location
	and dea.date = vac.date
-- Population vs Vaccinations
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
From PortfolioProject..['covid-deaths'] dea
Join PortfolioProject..['covid-vaccine'] vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
order by 1,2,3

-- USE CTE

With PopulationvsVaccination (Continent ,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as 
(
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths'] dea
Join PortfolioProject..['covid-vaccine'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
From PopulationvsVaccination

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths'] dea
Join PortfolioProject..['covid-vaccine'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * ,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- DATA VISUALISATIONS

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..['covid-deaths'] dea
Join PortfolioProject..['covid-vaccine'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

Select *
From PercentPopulationVaccinated

