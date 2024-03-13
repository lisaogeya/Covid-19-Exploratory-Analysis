Select *
from PortfolioProject1..CovidDeaths$
ORDER BY 3, 4

--Select *
--from PortfolioProject1..CovidVaccination$
--ORDER BY 3, 4

Select Location, date, total_cases,new_cases, total_deaths, population
From CovidDeaths$
order by 1, 2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths$
Where Location like '%kenya%'
order by 1, 2

--Total cases vs Population
--Shows what percentage of the population got covid
Select Location, date, population,  total_cases, (total_cases/population)*100 as CasePercentage
From CovidDeaths$
--Where Location like '%kenya%'
order by location,date

--countries with highest infection rate compared to population
Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths$
--Where Location like '%kenya%'
Group by location, population
order by PercentPopulationInfected desc

--countries with highest deathcount per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
where continent is not null 
Group by location
order by TotalDeathCount desc


--countries with highest deathcount per population in terms of continent
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathCount desc

select continent ,location,  MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths$
where continent is not null and continent = 'Africa'
GROUP BY continent, location
order by TotalDeathCount desc

--Global numbers
Select date, SUM(new_cases) as total_cases
From CovidDeaths$
where continent is not null
Group by date 
order by 1,2

--look at total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by  dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ as dea
Join CovidVaccination$ as vac
  ON  dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
order by 2, 3


--Using CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ as dea
Join CovidVaccination$ as vac
  ON  dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--Using temp table
drop table if exists #PercentPopulationVaccinated 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by  dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ as dea
Join CovidVaccination$ as vac
  ON  dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating views to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location order by  dea.Date) as RollingPeopleVaccinated
From CovidDeaths$ as dea
Join CovidVaccination$ as vac
  ON  dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2, 3