select*from CovidDeaths where continent is not null order by 3,4;
select location,date,total_cases,new_cases,total_deaths,population from CovidDeaths where continent is not null order by 1,2;
--Looking at total cases vs total deaths
--shows likelihood of dying if you contact covid in your country
select location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as Death_Percentage from CovidDeaths order by 1,2;

--Total Cases vs Population
--Shows what % of population got covid
select location,date,total_cases,population,(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected from CovidDeaths order by 1,2;

--Looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as HighestInfectionCount,max(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected from CovidDeaths group by location,population order by PercentPopulationInfected DESC;

--Showing Countries with highest death count per population
select location,max(total_deaths) as TotalDeathCount from CovidDeaths where continent is not null group by location order by TotalDeathCount DESC;

--lets break things down by continent
select continent,max(total_deaths) as TotalDeathCount from CovidDeaths where continent is not null group by continent order by TotalDeathCount DESC;

--Showing continents with highest death count per population
select continent,max(total_deaths) as TotalDeathCount from CovidDeaths where continent is not null group by continent order by TotalDeathCount DESC;

--GLOBAL NUMBERS
select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,(cast(sum(new_deaths)as float)/cast(sum(new_cases) as float))*100 as Death_Percentage from CovidDeaths WHERE continent is not null order by 1,2;

--Looking at total populations vs vaccinations
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null 
order by 2,3;

--using cte
with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null 
) select * , (cast(rollingpeoplevaccinated as float)/population)*100 from PopvsVac;

--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date 
select * , (cast(rollingpeoplevaccinated as float)/population)*100 from #PercentPopulationVaccinated;

--Creating View to store data later for visualization
Create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,sum(convert(bigint,vac.new_vaccinations)) over(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated 
from CovidDeaths dea join CovidVaccinations vac on dea.location=vac.location and dea.date=vac.date where dea.continent is not null ;
