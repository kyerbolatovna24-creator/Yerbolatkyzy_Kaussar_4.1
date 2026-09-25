# Yerbolatkyzy_Kaussar_4.1
PART 1. REQUIREMENTS ANALYSIS
1.1. Description of the System
Purpose of the System

The purpose of the Film Production Studio Database System is to manage and organize information related to film production. The system stores information about films, production companies, actors, crew members, characters, filming locations, scenes, shooting schedules, contracts, expenses, and film releases.

The database helps a film production studio organize its production activities and provides quick access to important information.

System Users

The system can be used by:

Producers

Film directors

Casting managers

Production managers

Accountants

Human resources employees

Location managers

Studio administrators

Information That Must Be Stored

The database must store the following types of information:

Information about production companies

Information about films

Information about actors and other personnel

Information about film characters

Information about crew members and their positions

Information about production projects

Information about filming locations

Information about film scenes

Information about shooting schedules

Information about contracts

Information about production expenses

Information about film releases

Operations That Users Should Be Able to Perform

Users should be able to:

Add new films to the database

Add new actors and crew members

Update film information

Assign actors to characters

Assign crew members to films

Add filming locations

Create and update scenes

Create shooting schedules

Add and update contracts

Record production expenses

Record film releases

Search for films and personnel

Delete selected records when necessary

Generate production and financial reports

Information Available for Analysis

The database should provide information that can be used for analysis, including:

The number of films produced by each company

Film budgets

Total production expenses

Average film budget

The number of scenes in each film

The number of employees working on each film

The most frequently used filming locations

Actor participation in films

Production activity

Film release information

Comparison between planned budgets and actual expenses

1.2. Main Entities

The database will contain the following main entities:

No.	Entity	Purpose
1	Production_Company	Stores information about companies that produce films.
2	Film	Stores basic information about each film.
3	Person	Stores information about actors, directors, producers, and other personnel.
4	Production_Project	Stores information about individual production projects and their budgets and statuses.
5	Film_Crew	Connects personnel with films and stores their positions.
6	Character_Role	Stores information about characters appearing in films.
7	Cast_Assignment	Connects actors with characters and films.
8	Location	Stores information about filming locations.
9	Scene	Stores information about individual scenes of a film.
10	Shooting_Schedule	Stores information about planned and completed shooting sessions.
11	Contract	Stores contracts between personnel and production projects.
12	Expense	Stores financial expenses related to film production.
13	Film_Release	Stores information about film releases in different countries and through different distribution channels.
Entity Descriptions

1. Production_Company

This entity stores information about production companies, including their names, countries, founding years, and contact information.

2. Film

This entity stores information about films, including title, genre, release year, planned budget, production status, and runtime.

3. Person

This entity stores information about people who participate in film production, such as actors, directors, producers, cinematographers, and other staff.

4. Production_Project

This entity stores information about individual production projects, including project name, start date, end date, status, and allocated budget.

5. Film_Crew

This entity connects people with films and stores their positions, such as director, producer, cinematographer, or production designer.

6. Character_Role

This entity stores information about fictional characters appearing in films.

7. Cast_Assignment

This entity connects actors with the characters they play and stores information about their salaries.

8. Location

This entity stores information about places where films are produced, including cities, countries, location types, and daily rental costs.

9. Scene

This entity stores information about individual film scenes, including scene number, description, location, and estimated duration.

10. Shooting_Schedule

This entity stores information about scheduled filming sessions, including dates, starting and ending times, and session status.

11. Contract

This entity stores contracts between production personnel and films, including contract type, dates, and contract value.

12. Expense

This entity stores financial expenses related to film production, such as equipment rental, transportation, catering, locations, security, and insurance.

13. Film_Release

This entity stores information about film releases, including release country, release date, distribution type, and box-office revenue.
