Film Production Studio Database

Student: Kaussar Yerbolatkyzy
DBMS: PostgreSQL
Database: film_studio_db
Schema: film_studio

Final structure

The database contains 13 related tables:

production_company

film

person

production_project

film_crew

character_role

cast_assignment

location

scene

shooting_schedule

contract

expense

film_release

Main relationships

production_company 1 film

film 1:1 production_project

film 1 film_crew

person 1 film_crew

film 1 character_role

character_role 1 cast_assignment

person 1 cast_assignment

film 1 scene

location 1 scene

film 1 shooting_schedule

production_project 1 contract

production_project 1 expense

film 1 film_release

Many-to-many relationships are resolved through film_crew and cast_assignment.

Constraints

The database uses:

PRIMARY KEY

FOREIGN KEY

NOT NULL

UNIQUE

DEFAULT

CHECK

Views

film_budget_report

film_cast_report

Reports

Financial Report

Cast Report

Production Activity Report

Normalization

The design satisfies 1NF, 2NF and 3NF by using atomic fields, separate entity tables, associative tables for many-to-many relationships, and removal of repeated/transitive data.

DBeaver

Run the SQL script in the film_studio_db database. Then refresh:

film_studio_db → Schemas → film_studio → Tables

The final ER diagram should be generated from these 13 tables.
