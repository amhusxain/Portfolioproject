select *
from PortfolioProject .. CovidDeaths$
where continent is not null
order by 3 , 4

--select *
--from PortfolioProject .. CovidDeaths$
--order by 3 , 4

--select data that we are going to use

select location , date , total_cases , new_cases , total_deaths , population
from PortfolioProject .. CovidDeaths$
order by 1,2

-- Looking at the total cases vs total deaths

alter table ..CovidDeaths$
alter column total_deaths float

alter table ..CovidDeaths$
alter column total_cases float

select location , date , total_cases , total_deaths , (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject .. CovidDeaths$
where location like 'india'
order by 1,2

 -- Looking at the total cases vs population
 -- Shows what % of population got covid
 select location , date , total_cases , population , (total_cases/population)*100 as PercentagePolpulationInfected
from PortfolioProject .. CovidDeaths$
where location like 'india'
order by 1,2

-- Looking at countries with the heghest infection rate
 select location , population ,max(total_cases) as HighestInfectionCount  , max(total_cases/population)*100 as PercentagePolpulationInfected
from PortfolioProject .. CovidDeaths$
where continent is not null
--where location like 'india'
group by location , population
order by PercentagePolpulationInfected desc

--Showing the countries with highest deathCount Per Population

 select location ,max(total_deaths) as TotalDeathCount 
from PortfolioProject .. CovidDeaths$
--where location like 'india'
where continent is not null
group by location 
order by TotalDeathCount desc

--LET"S THINGS DOWN BY CONTINENT

 select continent ,max(total_deaths) as TotalDeathCount 
from PortfolioProject .. CovidDeaths$
--where location like 'india'
where continent is not null
group by continent 
order by TotalDeathCount desc

--Showing the Continent With the Highest Deaths Count

 select continent ,max(total_deaths) as TotalDeathCount 
from PortfolioProject .. CovidDeaths$
--where continent like 'North America'
where continent is not null
group by continent 
order by TotalDeathCount desc

--GLOBAL NUMBERS

 select SUM(new_cases) as TotalCases , SUM(new_deaths) as TotalDeaths , SUM(new_deaths)/SUM(new_cases)*100 as DeathsPercentage-- , population , (total_cases/population)*100 as PercentagePolpulationInfected
from PortfolioProject .. CovidDeaths$
--where location like 'india'
--where continent is  null or
where new_cases > 0
--group by date
order by 1 , 2



-- COVID VACCINATIONS
--Looking at total population vs Vaccinations
alter table ..Covidvaccination
alter column new_vaccinations bigint



select  death.continent , death.location  , death.date , death.population, vac.new_vaccinations
, SUM(vac.new_vaccinations ) over(partition by death.location order by death.location , death.date)  as rollingPeopleVaccinated
from PortfolioProject ..CovidDeaths$ as death
join PortfolioProject ..Covidvaccination as vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
order by 2,3


-- USE CTE
with PopvsVac (continent , location , date , population,new_vaccinations, RollingPeopleVaccinated ) as
(
select  death.continent , death.location  , death.date , death.population, vac.new_vaccinations
, SUM(vac.new_vaccinations ) over(partition by death.location order by death.location , death.date)  as rollingPeopleVaccinated
from PortfolioProject ..CovidDeaths$ as death
join PortfolioProject ..Covidvaccination as vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

-- Temp table
drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(Continent nvarchar(255),
location nvarchar(255),
Date  datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into  #PercentagePopulationVaccinated
select  death.continent , death.location  , death.date , death.population, vac.new_vaccinations
, SUM(vac.new_vaccinations ) over(partition by death.location order by death.location , death.date)  as rollingPeopleVaccinated
from PortfolioProject ..CovidDeaths$ as death
join PortfolioProject ..Covidvaccination as vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated

-- creating view to store data for later visualization


CREATE VIEW PercentPopulationVaccinated as 
select  death.continent , death.location  , death.date , death.population, vac.new_vaccinations
, SUM(vac.new_vaccinations ) over(partition by death.location order by death.location , death.date)  as rollingPeopleVaccinated
from PortfolioProject ..CovidDeaths$ as death
join PortfolioProject ..Covidvaccination as vac
on death.location = vac.location
and death.date = vac.date
where death.continent is not null
--order by 2,3


SELECT* 
FROM PercentPopulationVaccinated
