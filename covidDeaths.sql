Use alextheanalyst;
alter table coviddeaths modify column total_deaths int;
alter table coviddeaths modify column new_deaths int;
alter table coviddeaths modify column new_deaths_per_million int;
alter table coviddeaths modify column icu_patients int;
alter table coviddeaths modify column icu_patients_per_million int;
alter table coviddeaths modify column hosp_patients int;
alter table coviddeaths modify column hosp_patients_per_million int;
alter table coviddeaths modify column weekly_icu_admissions int;
alter table coviddeaths modify column weekly_icu_admissions_per_million int;
alter table coviddeaths modify column weekly_hosp_admissions int;
alter table coviddeaths modify column weekly_hosp_admissions_per_million int;



-- select data we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not Null;

-- total cases vs total deaths, day wise & country wise
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as pct_deaths
from coviddeaths
where continent is not Null
order by location;

-- find out total covid cases vis a vis population of a particular country
select location, date, total_cases, population, round((total_cases/population)*100,2) as pct_cases
from coviddeaths
where location = "India";

-- Find out countries with Highest Cases compared to population
select location, max(total_cases), max(population), round(max(total_cases)/max(population)*100,2) as pct_cases
from coviddeaths
where continent is not Null
group by location
order by pct_cases desc;

-- Find out countries with Highest Death count per population
select location, max(total_deaths) 
from coviddeaths
where continent is not Null
group by location
order by max(total_deaths) desc;

-- Find out continents with Highest Death count per population
select continent, max(total_deaths)
from coviddeaths
where continent is not Null
group by continent
order by max(total_deaths) desc;

-- Find out total new cases and total new deaths
select sum(new_cases), sum(new_deaths) , round(sum(new_deaths)/sum(new_cases)*100,2) as pct
from coviddeaths
where continent is not Null
order by pct desc;


-- Let us join the tables coviddeaths and covidvaccinations
-- But before doing that let's change the data type for columns in covicvaccinations wherever it is necessary
alter table covidvaccinations modify column new_tests int;
alter table covidvaccinations modify column total_tests int;
alter table covidvaccinations modify column total_tests_per_thousand int;
alter table covidvaccinations modify column new_tests_per_thousand int;
alter table covidvaccinations modify column new_tests_smoothed int;
alter table covidvaccinations modify column new_tests_smoothed_per_thousand int;
alter table covidvaccinations modify column positive_rate int;
alter table covidvaccinations modify column tests_per_case int;
alter table covidvaccinations modify column total_vaccinations int;
alter table covidvaccinations modify column people_vaccinated int;
alter table covidvaccinations modify column people_fully_vaccinated int;
alter table covidvaccinations modify column new_vaccinations int;
alter table covidvaccinations modify column new_vaccinations_smoothed int;
alter table covidvaccinations modify column total_vaccinations_per_hundred int;
alter table covidvaccinations modify column people_vaccinated_per_hundred int;
alter table covidvaccinations modify column people_fully_vaccinated_per_hundred int;
alter table covidvaccinations modify column new_vaccinations_smoothed_per_million int;
alter table covidvaccinations modify column extreme_poverty int;
alter table covidvaccinations modify column female_smokers int;
alter table covidvaccinations modify column male_smokers int;


-- Find out total population vs Vaccinations
With PopvsVacc (continent, location, date, population, new_vaccinations, cumulative_vaccinations)
as
(select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as cumulative_vaccinations
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and
cd.date = cv.date
where cd.continent is not null)
Select *, round((cumulative_vaccinations/population)*100,2) as pct_cumulative_vaccinations
from PopvsVacc;


-- Create a temporary table

Drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(continent varchar (50),
location varchar (50),
date datetime,
population int,
new_vaccinations int,
cummulative_vaccinations int)
Insert into PercentPopulationVaccinated 
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as cumulative_vaccinations
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and
cd.date = cv.date
where cd.continent is not null
Select *, round((cumulative_vaccinations/population)*100,2) as pct_cumulative_vaccinations
from PercentPopulationVaccinated;

-- Creating View to store data for visualisation
Create View PercentPopulationVaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations,
sum(cv.new_vaccinations) over (partition by cd.location order by cd.location, cd.date) as cumulative_vaccinations
from coviddeaths cd
join covidvaccinations cv
on cd.location = cv.location
and
cd.date = cv.date
where cd.continent is not null;

Select *
from PercentPopulationVaccinated;