
select*
from CovidDeaths
order by 3, 4


select*
from CovidVaccinations
order by 3, 4


select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1, 2

--looking for total case vs total death
--find death percentage
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths
where location like 'Ethiopia'
order by 1, 2


--looking at total case vs population
--perc of ppl got covid
select location, date, total_cases, population,(total_cases/population)*100 as pplwithcovid
from CovidDeaths
where location like 'eth%'
order by 1, 2


--looking for country with highest infection rate compare to population

select location, population,max(total_cases)as highestinfectioncount,max(total_cases/population)*100 as percentpopulationenfected
from CovidDeaths
group by location, population
order by percentpopulationenfected desc


--countries with highest death count per population

select location,max(cast(total_deaths as int)) as highestdeathcount
from CovidDeaths
where continent is not null
group by location
order by highestdeathcount desc


--by countinent

select location,max(cast(total_deaths as int)) as highestdeathcount
from CovidDeaths
where continent is null
group by location
order by highestdeathcount desc

--or total cases and death percentage in the world

select date, SUM(new_cases)as totalcase,sum(cast(new_deaths as int)) as totaldeath, sum(cast(new_deaths as int))/
SUM(new_cases)*100 as deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

--lookin on covidvaccination

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3


--we use CTE to know how many people vaccinated in a given country

with popvsvac(continent,location,date,population,new_vaccinations,rollingpplvaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select*,(rollingpplvaccinated/population)*100
from popvsvac


--temp tables

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

Insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View #PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as rollingpplvaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 2,3



select *
from #PercentPopulationVaccinated


--queries used for tableau project

--1

select SUM(new_cases)as totalcase,sum(cast(new_deaths as int)) as totaldeath, sum(cast(new_deaths as int))/
SUM(new_cases)*100 as deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2

--2

select location,sum(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null and location not in ('World','European union','International')
group by location
order by TotalDeathCount desc

--3

select location, population,max(total_cases)as highestinfectioncount,max(total_cases/population)*100 as percentpopulationenfected
from CovidDeaths
group by location, population
order by percentpopulationenfected desc

--4

select  location, population, Date, max(total_cases)as highestinfectioncount,max(total_cases/population)*100 as percentpopulationenfected
from CovidDeaths
group by location, population, date
order by percentpopulationenfected desc
