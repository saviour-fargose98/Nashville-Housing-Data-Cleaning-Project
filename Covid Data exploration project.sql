------Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types----------

select * from [Portfolio Project]..[Covid Deaths]
order by 3,4

select * from [Portfolio Project]..[Covid Vaccinations]
order by 3,4

select location,date,total_cases,new_cases,total_deaths,population from [Covid Deaths]
order by 1,2
------------looking at total cases vs total deaths--------------
-- Shows likelihood of dying if you contract covid in your country--------

Select Location, date, total_cases,total_deaths, (cast(total_deaths as float)/cast(total_cases as float)*100) as DeathPercentage
From [Covid Deaths]
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From [Covid Deaths]
--Where location like '%states%'
order by 1,2

------looking at country with highest infection rates compared to the population---------
Select Location, Population, max(total_cases) as highest_infection_count, max((total_cases/population))*100 as PercentPopulationInfected
From [Covid Deaths]
Where continent is not null 
group by location,population
order by PercentPopulationInfected desc

-----countries with highest death count for population
select location, max(cast(total_deaths as int)) total_deaths_count from [Covid Deaths]
Where continent is not null 
group by location
order by total_deaths_count desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid Deaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-----------showing continents with highest death count
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [Covid Deaths]
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [Covid Deaths]
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2

-------looking at total population vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [Covid Deaths] dea
join [Covid Vaccinations] vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3


-- using CTE----------
With Population_vs_vaccination(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [Covid Deaths] dea
join [Covid Vaccinations] vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as percet_population_vaccinated from Population_vs_vaccination

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
create table #Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [Covid Deaths] dea
join [Covid Vaccinations] vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
select *, (RollingPeopleVaccinated/Population)*100 as percet_population_vaccinated from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) as rolling_people_vaccinated
from [Covid Deaths] dea
join [Covid Vaccinations] vac on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

select * from PercentPopulationVaccinated
