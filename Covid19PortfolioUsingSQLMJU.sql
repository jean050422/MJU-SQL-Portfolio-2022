-- SELECT THE TABLE

SELECT * FROM "CovidDeaths"

-- DATA OVERVIEW | PAGE 5 ON PORTFOLIO
-- GET THE START DATE AND END DATE OF COVID ON FILE

SELECT MIN(date)
FROM "CovidDeaths"

SELECT MAX(date)
FROM "CovidDeaths"

-- DATA OVERVIEW | PAGE 6 ON PORTFOLIO --
-- CHECK THE UNIQUENESS OF PRIMARY KEY (ISO_CODE) --
-- WE CAN SEE THAT THE ISO_CODE IS UNIQUE TO THE LOCATION --

SELECT DISTINCT(iso_code),continent,location
FROM "CovidDeaths"
ORDER BY 2

-- DATA OVERVIEW | PAGE 7 ON PORTFOLIO
-- CHECK THE WAY OF RECORDING OF NUMERICAL DATA
-- IN THIS CASE, TOTAL CASES AND TOTAL DEATHS ARE RECORDED IN CUMULATIVE ORDER
-- POPULATION IS UNIQUE FOR EACH LOCATION
-- THEREFORE WE CAN USE MAX FOR COMPUTATION OF PERCENTAGE OF TOTAL_CASES AND TOTAL_DEATHS COLUMNS

SELECT iso_code, continent, date, location, total_cases, total_deaths,
	MAX(population) as MaxPopulation
FROM "CovidDeaths"
GROUP BY iso_code, continent, date, location, total_cases, total_deaths
ORDER BY continent

-- COVID DEATH COUNTS PER CONTINENT | PAGE 8 ON PORTFOLIO -- 

SELECT continent, SUM(population) as SumPopulation, SUM(total_cases) as SumCases, 
	SUM(total_deaths) as TotalDeaths
FROM "CovidDeaths"
WHERE continent iS NOT NULL
GROUP BY continent
ORDER BY 4 DESC

-- COVID DEATH COUNT PER LOCATION | PAGE 9 ON PORTFOLIO--

SELECT iso_code, continent, location, MAX(population) as MaxPopulation, MAX(total_cases) as MaxTotalCases, 
	ROUND(MAX(total_cases)/MAX(population),2) *100 as TotalInfected,
	MAX(total_deaths) as TotalDeaths
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY iso_code, continent, location
HAVING MAX(total_deaths) IS NOT NULL
ORDER BY 7 DESC 
LIMIT 10

-- COVID DEATH PERCENTAGE PER CONTINENT | PAGE 10 ON PORTFOLIO

WITH DeathPerContinent as 
(
SELECT iso_code, continent, location, MAX(population) as MaxPopulation, MAX(total_cases) as MaxTotalCases, 
	ROUND(MAX(total_cases)/MAX(population),2) *100 as TotalInfected,
	MAX(total_deaths) as TotalDeaths, 
	ROUND(MAX(total_deaths)/MAX(total_cases),2) * 100 as DeathPercentage
FROM "CovidDeaths"
GROUP BY iso_code, continent, location
HAVING ROUND(MAX(total_deaths)/MAX(total_cases),2) * 100 IS NOT NULL
ORDER BY 2, 8 DESC
) 
SELECT continent, SUM(MaxPopulation) AS TotalPopulation, SUM(maxtotalcases) AS TotalCases, SUM(totalinfected) AS TotalInfected, SUM(totaldeaths) AS TotalDeaths,
	ROUND(SUM(totalinfected)/SUM(maxtotalcases),6)*100 AS PercentInfected, 
	ROUND(SUM(totaldeaths)/SUM(maxtotalcases),6)*100 AS PercentDeath
FROM DeathPerContinent
WHERE CONTINENT IS NOT NULL
GROUP BY continent
ORDER BY 7 DESC

-- COVID DEATH PERCENTAGE RANK PER LOCATION | PAGE 11 ON PORTFOLIO

SELECT iso_code, continent, location, 
	ROUND(MAX(total_deaths)/MAX(total_cases),2)*100 AS DeathPercentage, 
	RANK() OVER(ORDER BY MAX(total_deaths)/MAX(total_cases) DESC) AS DeathRank
FROM "CovidDeaths"
GROUP BY iso_code, continent, location
HAVING ROUND(MAX(total_deaths)/MAX(total_cases),2) * 100 IS NOT NULL
LIMIT 10

-- PHILIPPINE COVID DEATH COUNT RANK | PAGE 12 ON PORTFOLIO

WITH DeathCountRank AS
(
SELECT iso_code, continent, location, 
	MAX(total_deaths) as MaxDeathCount,
	RANK() OVER(ORDER BY MAX(total_deaths) DESC) AS DeathCountRank
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY iso_code, continent, location
HAVING MAX(total_deaths) IS NOT NULL
)
SELECT * FROM DeathCountRank
WHERE location = 'Philippines'

-- PHILIPPINE COVID DEATH PERCENTAGE RANK | PAGE 13 ON PORTFOLIO

WITH DeathRank AS
(
SELECT iso_code, continent, location, 
	ROUND(MAX(total_deaths)/MAX(total_cases),2)*100 AS DeathPercentage, 
	RANK() OVER(ORDER BY MAX(total_deaths)/MAX(total_cases) DESC) AS DeathRank
FROM "CovidDeaths"
GROUP BY iso_code, continent, location
HAVING ROUND(MAX(total_deaths)/MAX(total_cases),2) * 100 IS NOT NULL
)
SELECT * FROM DeathRank
WHERE location = 'Philippines'

-- EXTRA --
-- COVID DEATH PERCENTAGE PER LOCATION

SELECT iso_code, continent, location, MAX(population) as MaxPopulation, MAX(total_cases) as MaxTotalCases, 
	ROUND(MAX(total_cases)/MAX(population),2) *100 as TotalInfected,
	MAX(total_deaths) as TotalDeaths, 
	ROUND(MAX(total_deaths)/MAX(total_cases),2) * 100 as DeathPercentage
FROM "CovidDeaths"
WHERE continent IS NOT NULL
GROUP BY iso_code, continent, location
HAVING ROUND(MAX(total_deaths)/MAX(total_cases),2) * 100 IS NOT NULL
ORDER BY 8 DESC 
LIMIT 10

-- GET THE START AND END DATE

SELECT MIN(date)
FROM "CovidDeaths"

SELECT MAX(date)
FROM "CovidDeaths"

-- COUNTRIES THAT HAVE ZERO CASES

WITH CountriesAffected AS
(
SELECT iso_code, location, MAX(total_cases) AS MaxCase
FROM "CovidDeaths"
GROUP BY iso_code, location
ORDER BY 3 DESC
)
SELECT count(DISTINCT(location)) AS NotAffectedVsAffected FROM CountriesAffected WHERE MaxCase IS NULL
UNION ALL
SELECT count(DISTINCT(location)) FROM CountriesAffected WHERE MaxCase IS NOT NULL

