-- Select Data that we are going to be using
SELECT * 
FROM ProtfolioProject..CovidDealths
WHERE continent is not NULL

--Looking at Total Cases vs Total Dealths
--Shows likeihood of dying if you contract covid in your country

SELECT Location, date, Total_cases, New_cases, total_deaths, population
FROM ProtfolioProject..CovidDealths
order by 1,2
 

SELECT Location, date, Total_cases, New_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM ProtfolioProject..CovidDealths
order by 1,2

SELECT Location, date, Total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM ProtfolioProject..CovidDealths
WHERE location like '%states%'
order by 1,2

--Looking at Total Cases vs Populations
--Shows what perecentage of populations got Covid

SELECT Location, date, population, Total_cases,(total_cases/population)* 100 as PercentageofPopulationInfected
FROM ProtfolioProject..CovidDealths
WHERE location like '%states%'
order by 1,2

--Looking at county with the highest infection rate compared to Population

SELECT Location, population, MAX(Total_cases) as HighestInfectionCount, MAX((total_cases/population))* 100 as PercentageofPopulationInfected
FROM ProtfolioProject..CovidDealths
--WHERE location like '%states%'
GROUP by location, population
order by PercentageofPopulationInfected desc

--Showing the countries with the highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) as TotalDealthCount
FROM ProtfolioProject..CovidDealths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP by location
order by TotalDealthCount desc

--Let's Break things down by continent


--Showing contintents with the highest dealth counter per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDealthCount
FROM ProtfolioProject..CovidDealths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP by continent
order by TotalDealthCount desc

--Gobal numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProtfolioProject..CovidDealths
--Where location like '%states%'
where continent is not null
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDealths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USE CTE
With PopvsVac (Contintent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDealths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentageofpeopleVaccinated
FROM PopvsVac

--TEMP TABLE

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDealths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProtfolioProject..CovidDealths dea
Join ProtfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated