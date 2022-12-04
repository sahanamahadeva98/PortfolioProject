use ProjectPortfolio;
select * from CovidDeaths
where continent is not null
--order by 3,4;

--select * from CovidVaccinations 
--order by 3,4;

--select the data required
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths 
where continent is not null
order by 1,2;

--Looking at total cases vs total deaths
--shows the likelihood of dying in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from CovidDeaths 
where location like '%india%' and continent is not null
order by 1,2;

--Looking at Total Cases vs Population
--Shows what percentage of Population got Covid

select location, date, total_cases, population,(total_cases/population)*100 as infected_percentage
from CovidDeaths 
where continent is not null
order by 1,2;


--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highest_infection_count,
max((total_cases/population)*100) as infected_population_percentage
from CovidDeaths 
where continent is not null
group by population,location
order by infected_population_percentage desc;


--Showing death count by continent
select continent,max(cast(total_deaths as int)) as total_death_count
from CovidDeaths 
where continent is not null 
group by continent
order by total_death_count desc;


--Showing countries with highest death coount per population
select location,max(cast(total_deaths as int)) as total_death_count
from CovidDeaths 
where continent is null 
group by location
order by total_death_count desc;

 -- showing continent with highest death count
 select continent,max(cast(total_deaths as int)) as total_death_count
from CovidDeaths 
where continent is not null 
group by continent
order by total_death_count desc;


--GLOBAL NUMBERS
select date, sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)* 100 as death_percentage
from CovidDeaths 
--where location like '%india%' and 
where continent is not null
group by date
order by 1,2;

--total death percentage across the world
select sum(cast(new_cases as int)) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)* 100 as death_percentage
from CovidDeaths 
where continent is not null
order by 1,2;


--Joining 2 tables based on date and location
select * 
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date;

--Looking at Total population vs Vaccination  --74959
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) 
over (partition by dea.location order by dea.location, dea.date) as rolling_people_vaccinated
from dbo.CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

--USE CTE 
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) 
OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

SET ANSI_WARNINGS On
GO

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
New_vaccinations bigint,
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

Select *, (convert(float,RollingPeopleVaccinated)/Population)*100
From #PercentPopulationVaccinated
order by 2

--creating view to store for later visualization
create view percentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from percentPopulationVaccinated