
----totalDeath Vs TotalCases 
--Select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
--From CovidDeaths
--where location like '%United States%'
--order by  1,2 

-----

--Select location, date, population , total_cases ,(cast(total_cases as float)/cast(population as float))*100 as CasesPercentage
--From CovidDeaths
--where location like '%United States%'
--order by  1,2 

-----

--Select location, population , MAX(total_cases) AS HighestTotalCases, Max(total_cases/population)*100 as PercentPopulationinfected
--From CovidDeaths
--where location like '%state%'
--GROUP BY location, population
--order by PercentPopulationinfected desc

----

Select continent, MAX(cast (total_deaths as int)) AS Highesttotal_deaths
From CovidDeaths
where continent is not null
GROUP BY continent
order by  Highesttotal_deaths desc
----

select  date, sum(new_cases) as total_cases , sum(new_deaths) as total_deaths ,SUM(NULLIF(new_deaths,0))/SUM(NULLIF(new_cases,0))*100 as presantge
from CovidDeaths
where continent is not null
group by date
order by 1,2 

SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date ) as rollingpeoplevaccinated 
--(rollingpeoplevaccinated/dea.population)*100 as persantge
FROM CovidDeaths dea 
join CovidVaccinations vac 
on dea.location =vac.location
and dea.date = vac.date 
where dea.continent is not null 
order by 2,3 


-- use CTE 
With PopvsVac (continent , location , Date ,population, new_vaccinations, rollingpeoplevaccinated )
as  
(
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date ) as rollingpeoplevaccinated 
--(rollingpeoplevaccinated/dea.population)*100 as persantge
FROM CovidDeaths dea 
join CovidVaccinations vac 
on dea.location =vac.location
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3 
)
select * , (rollingpeoplevaccinated/population)*100
from PopvsVac
order by 2,3 


---------- 
drop table if exists #PercentPopulationVaccinated 
Create table #PercentPopulationVaccinated 
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime , 
Population numeric , 
New_Vacctination numeric,
RollingPeopleVaccinated numeric
) 

Insert into #PercentPopulationVaccinated  
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date ) as rollingpeoplevaccinated 
--(rollingpeoplevaccinated/dea.population)*100 as persantge
FROM CovidDeaths dea 
join CovidVaccinations vac 
on dea.location =vac.location
and dea.date = vac.date 
--where dea.continent is not null 
--order by 2,3	

select * , (rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated  


create view PercentPopulationVaccinated   as 
SELECT dea.continent , dea.location , dea.date , dea.population , vac.new_vaccinations ,
sum(cast (vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location , dea.date )
as rollingpeoplevaccinated 
--(rollingpeoplevaccinated/dea.population)*100 as persantge
FROM CovidDeaths dea 
join CovidVaccinations vac 
on dea.location =vac.location
and dea.date = vac.date 
where dea.continent is not null 
--order by 2,3	
