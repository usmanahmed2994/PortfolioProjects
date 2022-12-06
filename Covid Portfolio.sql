create database PortfolioProject;

select* from coviddeaths
order by 3,4;

select * from covidvaccinations
order by 3, 4;

-- select data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
order by 1,2;

-- looking at the total cases vs total_deaths
-- shows likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
from coviddeaths
where location like '%states%'
order by 1,2;

-- looking at the total cases vs population
-- show what percentage of the population got covid
select location, date, population,total_cases, (total_cases/population) * 100 as percent_of_population_affected
from coviddeaths
-- where location like '%states%'
order by 1,2;

-- looking at countries with highest infection rate vs population
select location, population, max(total_cases) as highest_infection_count, 
max((total_cases/population)) * 100 as PercentPopulationInfected
from coviddeaths
-- where location like '%states%'
group by 1, 2
order by PercentPopulationInfected desc;

-- Breaking things down by continent

-- showing the countries with the highest death count per population
select continent, max(total_deaths) as highest_deaths_count
from coviddeaths
where continent is not null
group by 1
order by 2 desc;

-- showing the continent with the highest death count
select continent, max(total_deaths) as highest_death_count
from coviddeaths
where continent is not null
group by 1
order by 2 desc;

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, 
sum(new_deaths)/sum(new_cases) * 100 as DeathPercentage
from coviddeaths
where continent is not null
-- group by 1
order by 1,2;


-- Looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3;

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- using cte/temp tables
with PopvsVac (Continent, Location, Date, Population, NewVaccinations, rollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null 
)
select *, (rollingPeopleVaccinated/population) * 100 
from PopvsVac;

-- Temp tables
drop table if exists PercentPopulationVaccinated;
create temporary table PercentPopulationVaccinated
(Continent varchar(255), 
Location varchar(255), 
Date datetime, 
Population numeric, 
NewVaccinations numeric, 
rollingPeopleVaccinated numeric);

insert into PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date;
-- where dea.continent is not null ;
select *, (rollingPeopleVaccinated/Population) * 100
from PercentPeopleVaccinated;

-- creating views to store data for later
create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date) as rollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;

