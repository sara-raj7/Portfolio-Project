-- This Project is on Covid data from 01-01-2020 to 30-04-2021
-- Looking at the data of two tables

SELECT *
FROM PortfolioProject.DBO.COVIDDEATHS
ORDER BY 3,4

SELECT *
FROM PORTFOLIOPROJECT.DBO.COVIDVACCINATIONS
ORDER BY 3,4

--SELECTING THE DATA WE NEED FOR DATA EXPLORATION

Select location, date, total_cases, total_deaths ,population
From portfolioProject..CovidDeaths
Order by 1,2

--looking at total deaths vs total cases
-- the amount of people dead from the total cases (in %)
-- death rate in india

Select location, date, total_cases, total_deaths , (total_deaths/total_cases) *100 as DeathPercentage
From portfolioProject..CovidDeaths
where location = 'india'
Order by 2

-- looking at highest percentage of DeathPercentage in india

Select max( (total_deaths/total_cases) *100 ) as DeathPercentage 
From portfolioProject..CovidDeaths
where location = 'india'

-- looking at total cases vs total population
-- the amount of people affected with corona out of total population(in %)

Select location, date, total_cases, population ,(total_cases/population) *100 as InfectedPopulationPercentage
From portfolioProject..CovidDeaths
where location like '%states%'
Order by 2

-- looking at the countries with Highest Infected rate over their population

Select location,population , max(total_cases) as total_cases ,max((total_cases/population) *100 )as InfectedPopulationPercentage
From portfolioProject..CovidDeaths
where continent is not null
group by location, population
Order by InfectedPopulationPercentage desc

--looking at the total deaths of each country

Select location, max(cast(total_deaths as int)) as Deaths
From PortfolioProject..CovidDeaths
where continent is not null
group by location
order by Deaths desc

--let's break down the data to continents

Select continent, max(cast(total_deaths as int)) as Deaths
From PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by Deaths desc

-- Looking at Cases vs Deaths on each day 

Select date, sum(new_cases) cases, sum(cast(new_deaths as int)) deaths, sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc

-- Looking at Total Population vs Vaccinations

Select dea.location, dea.population, sum(cast(vac.new_vaccinations as int)) Vaccinated , 
sum(cast(vac.new_vaccinations as int))/dea.population * 100 PerPopulationVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
group by dea.location , dea.population
order by 3 desc

---- Using CTE 

With POPvsVAC (location, population, Vaccinated, PerPopulationVaccinated)
as
(
Select dea.location, dea.population, sum(cast(vac.new_vaccinations as int)) Vaccinated , 
sum(cast(vac.new_vaccinations as int))/dea.population * 100 PerPopulationVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
group by dea.location , dea.population
--order by 3 desc
)

Select *
From POPvsVAC


-- Looking at Total Cases vs Hospital Admitted Patients
-- Using Temp Tables

Drop table if exists #CasesVsHos
create table #CasesVsHos
(location varchar(50),
new_cases nvarchar(255),
hosp_patients nvarchar(255))

insert into #CasesVsHos
Select dea.location, SUM(cast(dea.new_cases as int)) Total_cases, SUM(cast(dea.hosp_patients as int)) Hospital_Admitted
From PortfolioProject..CovidDeaths dea
where dea.continent is not null
group by dea.location

select * from #CasesVsHos
order by hosp_patients desc

-- Looking at Total Deaths vs Smokers

Select dea.location, dea.population, SUM(cast(dea.new_deaths as int)) Total_Deaths,
( SUM(cast(vac.male_smokers as numeric))+ SUM(cast(vac.female_smokers as numeric ))) Smokers,
(SUM(cast(dea.new_deaths as int))/( SUM(cast(vac.male_smokers as numeric))+ SUM(cast(vac.female_smokers as numeric )))) * 100 SmokersDeathPercentage
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null and dea.new_deaths is not null and vac.male_smokers is not null and
vac.female_smokers is not null
group by dea.location , dea.population
order by 1

--Global Numbers
-- Total Cases and Deaths 

Select sum(new_cases) cases, sum(cast(new_deaths as int)) deaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null

-- Creating views

Create view PercentPeopleVaccinated as
Select dea.location, dea.population, sum(cast(vac.new_vaccinations as int)) Vaccinated , 
sum(cast(vac.new_vaccinations as int))/dea.population * 100 PerPopulationVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac on
dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
group by dea.location , dea.population

Select *
From PercentPeopleVaccinated 







