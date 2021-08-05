select *
from Portfolio_project.dbo.covid_death
where continent is null
order by 1,2

select location,date,total_cases,new_cases,total_deaths,population
from Portfolio_project.dbo.covid_death
order by 1,2

--observe total case vs total deaths (cal.Death Percentage)
--Rough idea to know what % is chance of death in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
from Portfolio_project.dbo.covid_death
where location like '%india' 
order by 1,2

--Observe total_cases Vs population (cal. People infected percentage)

select location,date,population,total_cases,(total_cases/population)*100 as Infected_percentage
from Portfolio_project.dbo.covid_death
--where location like '%india' 
order by 1,2

--observe country with highest Infection rate with population

select location,population,max(total_cases) as Highest_infection_count,max((total_cases/population))*100 as Infected_percentage
from Portfolio_project.dbo.covid_death
--where location like '%india' 
group by location,population
order by Infected_percentage desc

--observe country with highest death count per popluation

select location,max(cast(total_deaths as int)) as Highest_Death_count
from Portfolio_project.dbo.covid_death
--where location like '%china'
where continent is not null
group by location
order by Highest_Death_count desc

--observe continent with highest death count per population

select continent,max(cast(total_deaths as int)) as Highest_Death_count
from Portfolio_project.dbo.covid_death
--where location like '%china'
where continent is not null
group by continent
order by Highest_Death_count desc

--Global Data of new cases and according death all around the world due to covid

select date,sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from Portfolio_project.dbo.covid_death
where continent is not null
group by date
order by 1,2

--Total Global Data of new cases and according death all around the world due to covid

select sum(new_cases) as Total_cases,sum(cast(new_deaths as int)) as Total_death,sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
from Portfolio_project.dbo.covid_death
where continent is not null
order by 1,2


--Joining Covid Death and Covid Vaccination Table 

--Observe Total population Vs Vaccination
 
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location,death.date) as Rolling_Total_vaccination
from Portfolio_project..covid_death as death
join Portfolio_project..covid_vaccination as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
order by 2,3

--Using CTE(common table expression)

with PopvsVac(continent,location,date,population,new_vaccinations,Rolling_Total_vaccination)
as 
(
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location,death.date) as Rolling_Total_vaccination
from Portfolio_project..covid_death as death
join Portfolio_project..covid_vaccination as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
--order by 2,3
)
select *,(Rolling_Total_vaccination/population)*100 as Percentage_Vaccinated
from PopvsVac


--Creating Temp Table

drop table if exists #Percentage_Vaccinated
create table #Percentage_Vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_Total_vaccination numeric
)

insert into #Percentage_Vaccinated
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location,death.date) as Rolling_Total_vaccination
from Portfolio_project..covid_death as death
join Portfolio_project..covid_vaccination as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null and death.location like '%india%'
order by 2,3

select *,(Rolling_Total_vaccination/population)*100 as Percentage_Vaccinated
from #Percentage_Vaccinated


--Creating View for later Visualization

create view PercentageVaccinated as 
select death.continent,death.location,death.date,death.population,vaccine.new_vaccinations
,sum(cast(vaccine.new_vaccinations as int)) over (partition by death.location order by death.location,death.date) as Rolling_Total_vaccination
from Portfolio_project..covid_death as death
join Portfolio_project..covid_vaccination as vaccine
	on death.location = vaccine.location
	and death.date = vaccine.date
where death.continent is not null 
--order by 2,3

select *
from PercentageVaccinated











