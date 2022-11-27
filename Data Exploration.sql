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
where continent is not null 
group by location
order by total_death_count desc;