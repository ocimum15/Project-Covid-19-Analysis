-- Inspecting Data --
select * from PortfolioProject..CovidDeaths
order by 3,4;

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


-- Total Cases vs Total Deaths --
-- Shows likelihood of dying if you contract covid in your country --

-- converting varchar data type to bigint --
alter table PortfolioProject..CovidDeaths
alter column total_cases bigint;
alter table PortfolioProject..CovidDeaths
alter column total_deaths bigint;

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
order by 1,2;

-- Analyze total cases and total deaths year wise --

select location,year(date) as year, sum(try_convert(bigint,new_cases)) as total_cases,
sum(try_convert(bigint,new_deaths)) as total_deaths
--,(sum(try_convert(bigint,new_deaths))/sum(try_convert(bigint,new_cases)))*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, year(date)
order by location, year(date);

-- Total Cases vs Population --
-- Shows what percentage of population infected with Covid --

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;

-- Countries with Highest Infection Rate per Population --

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  (Max(total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc;

Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  (Max(total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
Group by Location, Population, date
order by PercentPopulationInfected desc;

-- Countries with Highest Death Rate per Population --

Select Location,population, MAX(Total_deaths) as TotalDeathCount, (Max(total_deaths)/population)*100 as PercentPopulationDeath
From PortfolioProject..CovidDeaths
--Where location = 'India'
where continent is not null
Group by Location, population
order by PercentPopulationDeath desc;

-- Continents with Highest Death Count per Population --

Select continent,SUM(cast(new_deaths as bigint)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'India'
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- GLOBAL COUNTS TILL NOW --
-- How many cases came till now and what % of total cases has turned into deaths? --

Select SUM(try_convert(bigint,new_cases)) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(try_convert(bigint,new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2;
--- It shows almost 99% people got recovered from Covid19 --

-- Total Population vs Vaccinations --

select * from PortfolioProject..CovidVaccinations;
--where location = 'india'
--and year(date) = 2023;

-- What % of population has recieved at least one Covid Vaccine ? --

Select death.location,death.population as population,
MAX(CONVERT(bigint,vac.people_vaccinated)) as People_vaccinated_atleastonce,
(MAX(CONVERT(bigint,vac.people_vaccinated))/ death.population)*100 as '%People_vaccinated_atleastonce'
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
group by death.location, death.population
order by 1;

-- What % of population has recieved 2nd Dose of Covid Vaccine ? --

Select death.location,death.population as population,
MAX(CONVERT(bigint,vac.people_fully_vaccinated)) as People_vaccinated_2ndDose,
(MAX(CONVERT(bigint,vac.people_fully_vaccinated))/ death.population)*100 as '%People_vaccinated_2ndDose'
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
group by death.location, death.population
order by 1;


--Select death.location,death.date,death.population,death.total_deaths,vac.total_vaccinations,
--vac.people_vaccinated,vac.people_fully_vaccinated,
--vac.total_boosters
--From PortfolioProject..CovidDeaths death
--Join PortfolioProject..CovidVaccinations vac
--	On death.location = vac.location
--	and death.date = vac.date
--where death.continent is not null 
--and death.location = 'japan'
----group by death.location,death.date,death.population
--order by 2 desc;


-- What is the total no. of vaccinations given in different countries per year? --

select * from PortfolioProject..CovidVaccinations;

 with cte as (Select dea.location, year(dea.date) as year,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location, year(dea.date) Order by dea.location, year(dea.date),dea.date) as total_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 1,2,3)
select location,year, max(total_vaccinations) as total_vacc from cte
group by location,year
order by 1,2;

-- What % of world population get vaccinated? --

with cte2 as (select vac.location, dea.population, max(cast(vac.people_vaccinated as bigint)) as people_vaccinated,
max(cast(vac.people_fully_vaccinated as bigint)) as people_fully_vaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea on
dea.location = vac.location and dea.date =vac.date
where vac.continent is not null
group by vac.location, dea.population)
--order by 1)
select sum(population) as world_population, sum(cast(people_vaccinated as bigint)) as tot_people_vacc,
sum(cast(people_fully_vaccinated as bigint)) as tot_people_fully_vacc,
(sum(cast(people_vaccinated as bigint))/sum(population))*100 as '%tot_people_vacc',
(sum(cast(people_fully_vaccinated as bigint))/sum(population))*100 as '%tot_people_fully_vacc'
from cte2;

-- Analyse what percent of population got vaccinated as per GDP per capita criteria --

select location from PortfolioProject..CovidVaccinations
where gdp_per_capita < 1200                                       -- low income countries --
group by location;

select location from PortfolioProject..CovidVaccinations
where gdp_per_capita > 13000                                      -- high income countries --
group by location;

 
 with cte3 as (select vac.location, dea.population, max(cast(vac.people_vaccinated as bigint)) as people_vaccinated,
max(cast(vac.people_fully_vaccinated as bigint)) as people_fully_vaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea on
dea.location = vac.location and dea.date =vac.date
where vac.continent is not null
and vac.gdp_per_capita < 1200
group by vac.location, dea.population),

cte5 as (select sum(population) as low_income_countries_population, sum(cast(people_vaccinated as bigint)) as tot_people_vacc,
sum(cast(people_fully_vaccinated as bigint)) as tot_people_fully_vacc,
(sum(cast(people_vaccinated as bigint))/sum(population))*100 as '%people_vacc_LIC',
(sum(cast(people_fully_vaccinated as bigint))/sum(population))*100 as '%people_fully_vacc_LIC'
from cte3),

cte4 as (select vac.location, dea.population, max(cast(vac.people_vaccinated as bigint)) as people_vaccinated,
max(cast(vac.people_fully_vaccinated as bigint)) as people_fully_vaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea on
dea.location = vac.location and dea.date =vac.date
where vac.continent is not null
and vac.gdp_per_capita > 13000
group by vac.location, dea.population),

cte6 as (select sum(population) as high_income_countries_population, sum(cast(people_vaccinated as bigint)) as tot_people_vacc,
sum(cast(people_fully_vaccinated as bigint)) as tot_people_fully_vacc,
(sum(cast(people_vaccinated as bigint))/sum(population))*100 as '%people_vacc_HIC',
(sum(cast(people_fully_vaccinated as bigint))/sum(population))*100 as '%people_fully_vacc_HIC'
from cte4)
select * from cte5 
cross join cte6;

-- Creating View to store data for later visualizations--

create view peop_vacc as
Select death.location,death.population as population,
MAX(CONVERT(bigint,vac.people_vaccinated)) as People_vaccinated_atleastonce,
(MAX(CONVERT(bigint,vac.people_vaccinated))/ death.population)*100 as '%People_vaccinated_atleastonce'
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
group by death.location, death.population
--order by 1;

create view peop_fully_vacc as
Select death.location,death.population as population,
MAX(CONVERT(bigint,vac.people_fully_vaccinated)) as People_vaccinated_2ndDose,
(MAX(CONVERT(bigint,vac.people_fully_vaccinated))/ death.population)*100 as '%People_vaccinated_2ndDose'
From PortfolioProject..CovidDeaths death
Join PortfolioProject..CovidVaccinations vac
	On death.location = vac.location
	and death.date = vac.date
where death.continent is not null 
group by death.location, death.population
--order by 1;

drop view peop_vacc_atleastonce;
create view tot_vacc as
with cte as (Select dea.location, year(dea.date) as year,dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location, year(dea.date) Order by dea.location, year(dea.date),dea.date) as total_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null)
--order by 1,2,3)
select location,year, max(total_vaccinations) as total_vacc from cte
group by location,year
--order by 1,2;

create view global_count as
Select SUM(try_convert(bigint,new_cases)) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(try_convert(bigint,new_cases))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
--order by 1;

create view continent_death_count as
Select continent,MAX(Total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location = 'India'
where continent is not null
Group by continent
--order by TotalDeathCount desc;

create view countries_death_rate as
Select Location,population, MAX(Total_deaths) as TotalDeathCount, (Max(total_deaths)/population)*100 as PercentPopulationDeath
From PortfolioProject..CovidDeaths
--Where location = 'India'
where continent is not null
Group by Location, population
--order by TotalDeathCount desc;

create view countries_infected_rate as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  (Max(total_cases)/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
Group by Location, Population
--order by PercentPopulationInfected desc;

create view yearly_counts as
select location,year(date) as year, sum(try_convert(bigint,new_cases)) as total_cases,
sum(try_convert(bigint,new_deaths)) as total_deaths
--,(sum(try_convert(bigint,new_deaths))/sum(try_convert(bigint,new_cases)))*100 as Death_Percentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, year(date)
--order by location, year(date);


