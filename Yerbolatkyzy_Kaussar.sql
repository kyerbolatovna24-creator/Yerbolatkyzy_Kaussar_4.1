/* =========================================================
   FILM PRODUCTION STUDIO DATABASE
   PostgreSQL
   Student: Kaussar Yerbolatkyzy

   Covers:
   PART 4  - Database Creation / Tables / Constraints
   PART 5  - Test Data
   PART 6  - INSERT / UPDATE / DELETE / SELECT
   PART 7  - 15+ SQL Queries
   PART 8  - Data Analysis
   PART 9  - Views
   PART 10 - Data Integrity
   PART 11 - Normalization
   PART 12 - Modification Scenarios
   PART 13 - Reports
   PART 14 - Final Database Structure
   ========================================================= */


/* =========================================================
   STEP 1. CREATE SCHEMA
   ========================================================= */

DROP SCHEMA IF EXISTS film_studio CASCADE;

CREATE SCHEMA film_studio;

SET search_path TO film_studio;


/* =========================================================
   STEP 2. TABLES
   ========================================================= */


/* ---------------------------------------------------------
   1. PRODUCTION COMPANY
   --------------------------------------------------------- */

CREATE TABLE production_company (
    company_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    company_name VARCHAR(150) NOT NULL UNIQUE,

    country VARCHAR(100) NOT NULL,

    founded_year INT
        CHECK (founded_year >= 1800),

    contact_email VARCHAR(150),

    phone VARCHAR(30)
);


/* ---------------------------------------------------------
   2. FILM
   --------------------------------------------------------- */

CREATE TABLE film (
    film_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    company_id INT NOT NULL,

    title VARCHAR(200) NOT NULL,

    genre VARCHAR(100) NOT NULL,

    release_year INT
        CHECK (release_year >= 1888),

    planned_budget NUMERIC(14,2) NOT NULL
        CHECK (planned_budget >= 0),

    production_status VARCHAR(30) NOT NULL
        DEFAULT 'Planned'
        CHECK (
            production_status IN
            ('Planned', 'Pre-Production',
             'In Production', 'Completed', 'Cancelled')
        ),

    runtime_minutes INT
        CHECK (runtime_minutes > 0),

    CONSTRAINT fk_film_company
        FOREIGN KEY (company_id)
        REFERENCES production_company(company_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);


/* ---------------------------------------------------------
   3. PERSON
   --------------------------------------------------------- */

CREATE TABLE person (
    person_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    first_name VARCHAR(100) NOT NULL,

    last_name VARCHAR(100) NOT NULL,

    date_of_birth DATE,

    phone VARCHAR(30),

    email VARCHAR(150) UNIQUE,

    nationality VARCHAR(100)
);


/* ---------------------------------------------------------
   4. PRODUCTION PROJECT
   --------------------------------------------------------- */

CREATE TABLE production_project (
    project_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    film_id INT NOT NULL UNIQUE,

    project_name VARCHAR(200) NOT NULL,

    start_date DATE,

    end_date DATE,

    project_status VARCHAR(30) NOT NULL
        DEFAULT 'Planned'
        CHECK (
            project_status IN
            ('Planned', 'Pre-Production',
             'Active', 'Completed', 'Cancelled')
        ),

    allocated_budget NUMERIC(14,2) NOT NULL
        CHECK (allocated_budget >= 0),

    CONSTRAINT chk_project_dates
        CHECK (
            end_date IS NULL
            OR start_date IS NULL
            OR end_date >= start_date
        ),

    CONSTRAINT fk_project_film
        FOREIGN KEY (film_id)
        REFERENCES film(film_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


/* ---------------------------------------------------------
   5. FILM CREW
   --------------------------------------------------------- */

CREATE TABLE film_crew (
    crew_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    film_id INT NOT NULL,

    person_id INT NOT NULL,

    position VARCHAR(100) NOT NULL,

    start_date DATE,

    end_date DATE,

    CONSTRAINT uq_film_crew
        UNIQUE (film_id, person_id, position),

    CONSTRAINT chk_crew_dates
        CHECK (
            end_date IS NULL
            OR start_date IS NULL
            OR end_date >= start_date
        ),

    CONSTRAINT fk_crew_film
        FOREIGN KEY (film_id)
        REFERENCES film(film_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_crew_person
        FOREIGN KEY (person_id)
        REFERENCES person(person_id)
        ON DELETE RESTRICT
);


/* ---------------------------------------------------------
   6. CHARACTER ROLE
   --------------------------------------------------------- */

CREATE TABLE character_role (
    character_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    film_id INT NOT NULL,

    character_name VARCHAR(150) NOT NULL,

    description TEXT,

    CONSTRAINT uq_character
        UNIQUE (film_id, character_name),

    CONSTRAINT fk_character_film
        FOREIGN KEY (film_id)
        REFERENCES film(film_id)
        ON DELETE CASCADE
);


/* ---------------------------------------------------------
   7. CAST ASSIGNMENT
   --------------------------------------------------------- */

CREATE TABLE cast_assignment (
    cast_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    character_id INT NOT NULL,

    actor_id INT NOT NULL,

    salary NUMERIC(12,2)
        CHECK (salary >= 0),

    CONSTRAINT uq_cast_assignment
        UNIQUE (character_id, actor_id),

    CONSTRAINT fk_cast_character
        FOREIGN KEY (character_id)
        REFERENCES character_role(character_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_cast_actor
        FOREIGN KEY (actor_id)
        REFERENCES person(person_id)
        ON DELETE RESTRICT
);


/* ---------------------------------------------------------
   8. LOCATION
   --------------------------------------------------------- */

CREATE TABLE location (
    location_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    location_name VARCHAR(200) NOT NULL,

    city VARCHAR(100) NOT NULL,

    country VARCHAR(100) NOT NULL,

    location_type VARCHAR(100) NOT NULL,

    daily_rental_cost NUMERIC(10,2)
        CHECK (daily_rental_cost >= 0)
);


/* ---------------------------------------------------------
   9. SCENE
   --------------------------------------------------------- */

CREATE TABLE scene (
    scene_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    film_id INT NOT NULL,

    location_id INT,

    scene_number INT NOT NULL
        CHECK (scene_number > 0),

    description TEXT,

    estimated_duration INT
        CHECK (estimated_duration > 0),

    CONSTRAINT uq_scene_number
        UNIQUE (film_id, scene_number),

    CONSTRAINT fk_scene_film
        FOREIGN KEY (film_id)
        REFERENCES film(film_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_scene_location
        FOREIGN KEY (location_id)
        REFERENCES location(location_id)
        ON DELETE SET NULL
);


/* ---------------------------------------------------------
   10. SHOOTING SCHEDULE
   --------------------------------------------------------- */

CREATE TABLE shooting_schedule (
    schedule_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    film_id INT NOT NULL,

    scene_id INT,

    location_id INT,

    shooting_date DATE NOT NULL,

    start_time TIME NOT NULL,

    end_time TIME NOT NULL,

    session_status VARCHAR(30) NOT NULL
        DEFAULT 'Planned'
        CHECK (
            session_status IN
            ('Planned', 'Completed', 'Cancelled')
        ),

    CONSTRAINT chk_schedule_time
        CHECK (end_time > start_time),

    CONSTRAINT fk_schedule_film
        FOREIGN KEY (film_id)
        REFERENCES film(film_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_schedule_scene
        FOREIGN KEY (scene_id)
        REFERENCES scene(scene_id)
        ON DELETE SET NULL,

    CONSTRAINT fk_schedule_location
        FOREIGN KEY (location_id)
        REFERENCES location(location_id)
        ON DELETE SET NULL
);


/* ---------------------------------------------------------
   11. CONTRACT
   --------------------------------------------------------- */

CREATE TABLE contract (
    contract_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    project_id INT NOT NULL,

    person_id INT NOT NULL,

    contract_type VARCHAR(100) NOT NULL,

    start_date DATE NOT NULL,

    end_date DATE,

    contract_value NUMERIC(14,2) NOT NULL
        CHECK (contract_value >= 0),

    CONSTRAINT chk_contract_dates
        CHECK (
            end_date IS NULL
            OR end_date >= start_date
        ),

    CONSTRAINT fk_contract_project
        FOREIGN KEY (project_id)
        REFERENCES production_project(project_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_contract_person
        FOREIGN KEY (person_id)
        REFERENCES person(person_id)
        ON DELETE RESTRICT
);


/* ---------------------------------------------------------
   12. EXPENSE
   --------------------------------------------------------- */

CREATE TABLE expense (
    expense_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    project_id INT NOT NULL,

    expense_category VARCHAR(100) NOT NULL,

    expense_date DATE NOT NULL,

    description TEXT,

    amount NUMERIC(14,2) NOT NULL
        CHECK (amount > 0),

    CONSTRAINT fk_expense_project
        FOREIGN KEY (project_id)
        REFERENCES production_project(project_id)
        ON DELETE CASCADE
);


/* ---------------------------------------------------------
   13. FILM RELEASE
   --------------------------------------------------------- */

CREATE TABLE film_release (
    release_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    film_id INT NOT NULL,

    release_country VARCHAR(100) NOT NULL,

    release_date DATE NOT NULL,

    distribution_type VARCHAR(100) NOT NULL,

    box_office_revenue NUMERIC(14,2)
        DEFAULT 0
        CHECK (box_office_revenue >= 0),

    CONSTRAINT uq_film_release
        UNIQUE (
            film_id,
            release_country,
            distribution_type
        ),

    CONSTRAINT fk_release_film
        FOREIGN KEY (film_id)
        REFERENCES film(film_id)
        ON DELETE CASCADE
);


/* =========================================================
   STEP 3. INSERT DATA
   ========================================================= */


/* ---------------------------------------------------------
   PRODUCTION COMPANY - 10 RECORDS
   --------------------------------------------------------- */

INSERT INTO production_company
(company_name, country, founded_year, contact_email, phone)
VALUES
('Steppe Films', 'Kazakhstan', 2015,
 'info@steppefilms.kz', '+7-700-111-2201'),

('Nomad Pictures', 'Kazakhstan', 2018,
 'info@nomadpictures.kz', '+7-701-111-2202'),

('Golden Eagle Studios', 'Kazakhstan', 2012,
 'contact@goldeneagle.kz', '+7-702-111-2203'),

('Alatau Cinema', 'Kazakhstan', 2020,
 'office@alatau.kz', '+7-703-111-2204'),

('Silk Road Productions', 'Uzbekistan', 2010,
 'info@silkroadprod.uz', '+998-71-111-2205'),

('Blue Horizon Films', 'United Kingdom', 2008,
 'info@bluehorizon.co.uk', '+44-20-1111-2206'),

('Global Cinema Group', 'United States', 2005,
 'office@globalcinema.com', '+1-212-111-2207'),

('Northern Star Studio', 'Canada', 2011,
 'contact@northernstar.ca', '+1-416-111-2208'),

('East Wind Pictures', 'South Korea', 2014,
 'info@eastwind.kr', '+82-2-1111-2209'),

('Caspian Motion', 'Azerbaijan', 2017,
 'office@caspianmotion.az', '+994-12-111-2210');


/* ---------------------------------------------------------
   FILM - 10 RECORDS
   --------------------------------------------------------- */

INSERT INTO film
(company_id, title, genre, release_year,
 planned_budget, production_status, runtime_minutes)
VALUES
(1, 'The Last Steppe', 'Drama', 2026,
 2500000, 'In Production', 120),

(2, 'Golden Horizon', 'Adventure', 2027,
 5000000, 'Pre-Production', 135),

(3, 'City Lights', 'Romance', 2026,
 1800000, 'Completed', 110),

(4, 'Echoes of Alatau', 'Historical', 2027,
 3200000, 'In Production', 128),

(5, 'Silk Road Journey', 'Adventure', 2026,
 4100000, 'Completed', 142),

(6, 'Northern Dreams', 'Drama', 2027,
 6200000, 'Pre-Production', 130),

(7, 'The Hidden Code', 'Thriller', 2026,
 7300000, 'In Production', 118),

(8, 'Beyond the Mountains', 'Adventure', 2028,
 8500000, 'Planned', 150),

(9, 'Seoul Connection', 'Crime', 2027,
 6800000, 'Pre-Production', 125),

(10, 'Caspian Winds', 'Drama', 2026,
 2900000, 'Completed', 105);


/* ---------------------------------------------------------
   PERSON - 10 RECORDS
   --------------------------------------------------------- */

INSERT INTO person
(first_name, last_name, date_of_birth,
 phone, email, nationality)
VALUES
('Aruzhan', 'Saparova', '1995-04-12',
 '+7-700-100-0001', 'aruzhan.saparova@mail.com', 'Kazakhstan'),

('Dias', 'Nurgaliyev', '1990-08-20',
 '+7-700-100-0002', 'dias.nurgaliyev@mail.com', 'Kazakhstan'),

('Madina', 'Kassenova', '1998-02-15',
 '+7-700-100-0003', 'madina.kassenova@mail.com', 'Kazakhstan'),

('Alexander', 'Brown', '1985-11-10',
 '+1-555-100-0004', 'alex.brown@mail.com', 'United States'),

('Aigerim', 'Tulegenova', '1992-06-18',
 '+7-700-100-0005', 'aigerim.tulegenova@mail.com', 'Kazakhstan'),

('Timur', 'Bekov', '1988-03-22',
 '+7-700-100-0006', 'timur.bekov@mail.com', 'Kazakhstan'),

('Laura', 'Wilson', '1991-09-05',
 '+44-20-1000-0007', 'laura.wilson@mail.com', 'United Kingdom'),

('Daniel', 'Martin', '1987-12-14',
 '+1-416-100-0008', 'daniel.martin@mail.com', 'Canada'),

('Sofia', 'Kim', '1996-01-30',
 '+82-2-1000-0009', 'sofia.kim@mail.com', 'South Korea'),

('Nurlan', 'Akhmetov', '1984-05-27',
 '+7-700-100-0010', 'nurlan.akhmetov@mail.com', 'Kazakhstan');


/* ---------------------------------------------------------
   PRODUCTION PROJECT - 10 RECORDS
   --------------------------------------------------------- */

INSERT INTO production_project
(film_id, project_name, start_date, end_date,
 project_status, allocated_budget)
VALUES
(1, 'The Last Steppe Production',
 '2026-01-10', NULL, 'Active', 2500000),

(2, 'Golden Horizon Production',
 '2026-09-01', NULL, 'Pre-Production', 5000000),

(3, 'City Lights Production',
 '2025-03-01', '2026-01-20',
 'Completed', 1800000),

(4, 'Echoes of Alatau Production',
 '2026-04-01', NULL, 'Active', 3200000),

(5, 'Silk Road Journey Production',
 '2025-01-15', '2026-03-10',
 'Completed', 4100000),

(6, 'Northern Dreams Production',
 '2026-11-01', NULL, 'Pre-Production', 6200000),

(7, 'The Hidden Code Production',
 '2026-02-01', NULL, 'Active', 7300000),

(8, 'Beyond the Mountains Production',
 '2027-02-01', NULL, 'Planned', 8500000),

(9, 'Seoul Connection Production',
 '2026-12-01', NULL, 'Pre-Production', 6800000),

(10, 'Caspian Winds Production',
 '2025-05-01', '2026-02-15',
 'Completed', 2900000);


/* ---------------------------------------------------------
   LOCATION - 10 RECORDS
   --------------------------------------------------------- */

INSERT INTO location
(location_name, city, country,
 location_type, daily_rental_cost)
VALUES
('Steppe Village', 'Almaty', 'Kazakhstan',
 'Outdoor', 5000),

('Old City Street', 'Astana', 'Kazakhstan',
 'Urban', 3500),

('Mountain Camp', 'Almaty', 'Kazakhstan',
 'Mountain', 7000),

('Caspian Coast', 'Aktau', 'Kazakhstan',
 'Coastal', 6000),

('Historical Fortress', 'Turkistan', 'Kazakhstan',
 'Historical', 4500),

('Desert Valley', 'Kyzylorda', 'Kazakhstan',
 'Desert', 4000),

('Central Studio', 'Almaty', 'Kazakhstan',
 'Studio', 9000),

('City Square', 'Tashkent', 'Uzbekistan',
 'Urban', 5500),

('Northern Forest', 'Toronto', 'Canada',
 'Forest', 8000),

('Harbor District', 'Busan', 'South Korea',
 'Coastal', 7500);


/* ---------------------------------------------------------
   CHARACTER ROLE - 20 RECORDS
   --------------------------------------------------------- */

INSERT INTO character_role
(film_id, character_name, description)
VALUES
(1, 'Ayan', 'Young historian and main protagonist'),
(1, 'Marat', 'Ayan''s childhood friend'),

(2, 'Dana', 'Explorer leading the expedition'),
(2, 'Arman', 'Experienced mountain guide'),

(3, 'Amina', 'Young architect in the city'),
(3, 'Dias', 'Photographer and Amina''s friend'),

(4, 'Zhanar', 'Historian researching Alatau history'),
(4, 'Serik', 'Local museum director'),

(5, 'Karim', 'Traveler following the Silk Road'),
(5, 'Leyla', 'Archaeologist and researcher'),

(6, 'Emily', 'Artist starting a new life'),
(6, 'James', 'Documentary filmmaker'),

(7, 'Victor', 'Cybersecurity specialist'),
(7, 'Elena', 'Investigative journalist'),

(8, 'Askar', 'Mountain climber'),
(8, 'Mira', 'Wildlife researcher'),

(9, 'Jin', 'Detective investigating a case'),
(9, 'Sora', 'Technology entrepreneur'),

(10, 'Adil', 'Fisherman from the Caspian coast'),
(10, 'Aruzhan', 'Marine researcher');


/* ---------------------------------------------------------
   SCENE - 30 RECORDS
   --------------------------------------------------------- */

INSERT INTO scene
(film_id, location_id, scene_number,
 description, estimated_duration)
VALUES
(1,1,1,'Opening scene in the steppe',10),
(1,2,2,'Ayan arrives in the city',8),
(1,5,3,'Historical discovery',12),

(2,3,1,'Expedition begins',15),
(2,6,2,'Desert crossing',11),
(2,5,3,'Ancient map is discovered',14),

(3,2,1,'Amina walks through the city',9),
(3,7,2,'Meeting at the studio',12),
(3,8,3,'Evening conversation',10),

(4,5,1,'Museum introduction',11),
(4,3,2,'Journey to the mountains',13),
(4,7,3,'Research at the studio',9),

(5,8,1,'Journey begins',14),
(5,5,2,'Historical monument',12),
(5,6,3,'Desert journey',15),

(6,9,1,'Arrival in the north',10),
(6,7,2,'Artist enters the studio',13),
(6,9,3,'Forest documentary',16),

(7,2,1,'The investigation begins',9),
(7,7,2,'Computer laboratory',12),
(7,4,3,'Meeting near the coast',11),

(8,3,1,'Mountain expedition',15),
(8,9,2,'Wildlife research',14),
(8,3,3,'Climbing preparation',10),

(9,10,1,'Harbor investigation',12),
(9,7,2,'Technology company meeting',10),
(9,10,3,'Night investigation',13),

(10,4,1,'Caspian coast morning',9),
(10,4,2,'Fishing boat scene',11),
(10,7,3,'Marine research laboratory',12);


/* ---------------------------------------------------------
   FILM CREW - 20 RECORDS
   --------------------------------------------------------- */

INSERT INTO film_crew
(film_id, person_id, position, start_date, end_date)
VALUES
(1,1,'Director','2026-01-10',NULL),
(1,2,'Producer','2026-01-10',NULL),

(2,3,'Director','2026-09-01',NULL),
(2,4,'Producer','2026-09-01',NULL),

(3,5,'Director','2025-03-01','2026-01-20'),
(3,6,'Producer','2025-03-01','2026-01-20'),

(4,1,'Director','2026-04-01',NULL),
(4,7,'Cinematographer','2026-04-01',NULL),

(5,8,'Director','2025-01-15','2026-03-10'),
(5,9,'Producer','2025-01-15','2026-03-10'),

(6,7,'Director','2026-11-01',NULL),
(6,8,'Producer','2026-11-01',NULL),

(7,4,'Director','2026-02-01',NULL),
(7,10,'Producer','2026-02-01',NULL),

(8,2,'Director','2027-02-01',NULL),
(8,6,'Producer','2027-02-01',NULL),

(9,9,'Director','2026-12-01',NULL),
(9,10,'Producer','2026-12-01',NULL),

(10,5,'Director','2025-05-01','2026-02-15'),
(10,3,'Cinematographer','2025-05-01','2026-02-15');


/* ---------------------------------------------------------
   CAST ASSIGNMENT - 20 RECORDS
   --------------------------------------------------------- */

INSERT INTO cast_assignment
(character_id, actor_id, salary)
VALUES
(1,3,150000),
(2,5,100000),

(3,1,180000),
(4,2,120000),

(5,3,130000),
(6,6,110000),

(7,5,170000),
(8,10,95000),

(9,8,190000),
(10,9,125000),

(11,7,160000),
(12,4,120000),

(13,4,210000),
(14,5,140000),

(15,6,220000),
(16,7,145000),

(17,9,200000),
(18,10,130000),

(19,1,175000),
(20,3,115000);


/* ---------------------------------------------------------
   SHOOTING SCHEDULE - 25 RECORDS
   --------------------------------------------------------- */

INSERT INTO shooting_schedule
(film_id, scene_id, location_id,
 shooting_date, start_time, end_time, session_status)
VALUES
(1,1,1,'2026-10-01','08:00','16:00','Completed'),
(1,2,2,'2026-10-03','09:00','17:00','Planned'),
(1,3,5,'2026-10-05','08:30','15:30','Planned'),

(2,4,3,'2026-10-10','07:00','15:00','Planned'),
(2,5,6,'2026-10-12','08:00','16:00','Planned'),
(2,6,5,'2026-10-15','09:00','17:00','Planned'),

(3,7,2,'2025-05-10','10:00','18:00','Completed'),
(3,8,7,'2025-06-02','09:00','17:00','Completed'),

(4,10,5,'2026-06-10','08:00','16:00','Completed'),
(4,11,3,'2026-06-12','07:30','15:30','Planned'),

(5,13,8,'2025-03-01','09:00','17:00','Completed'),
(5,14,5,'2025-03-05','08:00','16:00','Completed'),

(6,16,9,'2027-01-10','09:00','17:00','Planned'),
(6,17,7,'2027-01-12','10:00','18:00','Planned'),

(7,19,2,'2026-05-10','09:00','17:00','Completed'),
(7,20,7,'2026-05-12','08:00','16:00','Completed'),
(7,21,4,'2026-05-15','07:30','15:30','Planned'),

(8,22,3,'2027-03-10','07:00','15:00','Planned'),
(8,23,9,'2027-03-12','08:00','16:00','Planned'),

(9,25,10,'2027-01-05','18:00','23:00','Planned'),
(9,26,7,'2027-01-07','09:00','17:00','Planned'),
(9,27,10,'2027-01-10','18:00','23:00','Planned'),

(10,28,4,'2025-07-01','08:00','16:00','Completed'),
(10,29,4,'2025-07-03','08:00','16:00','Completed'),
(10,30,7,'2025-07-05','09:00','17:00','Completed');


/* ---------------------------------------------------------
   CONTRACT - 20 RECORDS
   --------------------------------------------------------- */

INSERT INTO contract
(project_id, person_id, contract_type,
 start_date, end_date, contract_value)
VALUES
(1,1,'Director Contract','2026-01-10','2026-12-30',300000),
(1,2,'Producer Contract','2026-01-10','2026-12-30',250000),

(2,3,'Director Contract','2026-09-01','2027-06-30',350000),
(2,4,'Producer Contract','2026-09-01','2027-06-30',280000),

(3,5,'Director Contract','2025-03-01','2026-01-20',260000),
(3,6,'Producer Contract','2025-03-01','2026-01-20',220000),

(4,1,'Director Contract','2026-04-01','2027-02-28',310000),
(4,7,'Cinematographer Contract','2026-04-01','2027-02-28',190000),

(5,8,'Director Contract','2025-01-15','2026-03-10',330000),
(5,9,'Producer Contract','2025-01-15','2026-03-10',260000),

(6,7,'Director Contract','2026-11-01','2027-08-30',370000),
(6,8,'Producer Contract','2026-11-01','2027-08-30',300000),

(7,4,'Director Contract','2026-02-01','2026-12-30',400000),
(7,10,'Producer Contract','2026-02-01','2026-12-30',320000),

(8,2,'Director Contract','2027-02-01','2027-12-30',420000),
(8,6,'Producer Contract','2027-02-01','2027-12-30',340000),

(9,9,'Director Contract','2026-12-01','2027-10-30',390000),
(9,10,'Producer Contract','2026-12-01','2027-10-30',310000),

(10,5,'Director Contract','2025-05-01','2026-02-15',280000),
(10,3,'Cinematographer Contract','2025-05-01','2026-02-15',180000);


/* ---------------------------------------------------------
   EXPENSE - 30 RECORDS
   --------------------------------------------------------- */

INSERT INTO expense
(project_id, expense_category, expense_date,
 description, amount)
VALUES
(1,'Equipment','2026-02-01','Camera equipment rental',25000),
(1,'Transportation','2026-02-10','Crew transportation',8000),
(1,'Catering','2026-02-15','Production catering',5000),

(2,'Location','2026-09-10','Mountain location rental',14000),
(2,'Equipment','2026-09-15','Lighting equipment',22000),
(2,'Transportation','2026-09-20','Transport services',9000),

(3,'Equipment','2025-05-05','Studio equipment',18000),
(3,'Catering','2025-05-10','Catering services',4500),
(3,'Marketing','2025-12-01','Film promotion',25000),

(4,'Location','2026-06-10','Historical location rental',12000),
(4,'Equipment','2026-06-15','Camera equipment',27000),
(4,'Insurance','2026-07-01','Production insurance',18000),

(5,'Transportation','2025-02-01','Travel expenses',16000),
(5,'Accommodation','2025-02-05','Crew accommodation',22000),
(5,'Equipment','2025-03-01','Special equipment',31000),

(6,'Location','2027-01-10','Forest location rental',20000),
(6,'Catering','2027-01-12','Production meals',7000),
(6,'Transportation','2027-01-15','Transport services',12000),

(7,'Equipment','2026-05-10','Security equipment',35000),
(7,'Technology','2026-05-12','Computer equipment',28000),
(7,'Insurance','2026-05-20','Insurance services',19000),

(8,'Location','2027-03-10','Mountain location rental',21000),
(8,'Equipment','2027-03-12','Climbing equipment',17000),
(8,'Transportation','2027-03-15','Expedition transport',13000),

(9,'Location','2027-01-05','Harbor location rental',18000),
(9,'Technology','2027-01-07','Production technology',26000),
(9,'Security','2027-01-10','Security services',15000),

(10,'Location','2025-07-01','Caspian coast rental',11000),
(10,'Transportation','2025-07-03','Boat transportation',9000),
(10,'Equipment','2025-07-05','Marine equipment',23000);


/* ---------------------------------------------------------
   FILM RELEASE - 15 RECORDS
   --------------------------------------------------------- */

INSERT INTO film_release
(film_id, release_country, release_date,
 distribution_type, box_office_revenue)
VALUES
(1,'Kazakhstan','2026-12-20','Cinema',0),
(1,'Kyrgyzstan','2027-01-15','Cinema',0),

(2,'Kazakhstan','2027-12-01','Cinema',0),
(2,'Uzbekistan','2027-12-15','Cinema',0),

(3,'Kazakhstan','2026-02-01','Cinema',350000),
(3,'Kyrgyzstan','2026-02-15','Streaming',120000),

(4,'Kazakhstan','2027-05-20','Cinema',0),

(5,'Uzbekistan','2026-04-10','Cinema',520000),
(5,'Kazakhstan','2026-04-20','Cinema',610000),

(6,'Canada','2027-12-10','Cinema',0),

(7,'United States','2026-11-15','Cinema',950000),
(7,'United Kingdom','2026-12-01','Streaming',420000),

(9,'South Korea','2027-11-10','Cinema',0),

(10,'Kazakhstan','2026-03-01','Cinema',480000);


/* =========================================================
   STEP 4. DATA MANIPULATION
   ========================================================= */


/* INSERT */

INSERT INTO person
(first_name, last_name, date_of_birth,
 phone, email, nationality)
VALUES
('Murat', 'Iskakov', '1993-07-19',
 '+7-700-555-1234',
 'murat.iskakov@mail.com',
 'Kazakhstan');


/* UPDATE */

UPDATE person
SET phone = '+7-700-555-5678'
WHERE person_id = 11;


/* DELETE */

DELETE FROM person
WHERE person_id = 11;


/* =========================================================
   STEP 5. 15+ SQL QUERIES
   ========================================================= */


/* QUERY 1
   Select all films
*/

SELECT *
FROM film;


/* QUERY 2
   Select specific columns
*/

SELECT
    title,
    genre,
    planned_budget
FROM film;


/* QUERY 3
   WHERE
*/

SELECT
    title,
    planned_budget
FROM film
WHERE planned_budget > 4000000;


/* QUERY 4
   ORDER BY
*/

SELECT
    title,
    planned_budget
FROM film
ORDER BY planned_budget DESC;


/* QUERY 5
   LIKE
*/

SELECT
    title,
    genre
FROM film
WHERE title LIKE '%City%';


/* QUERY 6
   BETWEEN
*/

SELECT
    title,
    planned_budget
FROM film
WHERE planned_budget BETWEEN 2000000 AND 6000000;


/* QUERY 7
   IN
*/

SELECT
    title,
    genre,
    production_status
FROM film
WHERE production_status IN
('Completed', 'In Production');


/* QUERY 8
   COUNT
*/

SELECT
    COUNT(*) AS total_films
FROM film;


/* QUERY 9
   SUM
*/

SELECT
    SUM(planned_budget) AS total_planned_budget
FROM film;


/* QUERY 10
   AVG
*/

SELECT
    AVG(planned_budget) AS average_film_budget
FROM film;


/* QUERY 11
   MIN and MAX
*/

SELECT
    MIN(planned_budget) AS minimum_budget,
    MAX(planned_budget) AS maximum_budget
FROM film;


/* QUERY 12
   GROUP BY
*/

SELECT
    production_status,
    COUNT(*) AS film_count
FROM film
GROUP BY production_status;


/* QUERY 13
   HAVING
*/

SELECT
    company_id,
    COUNT(*) AS film_count
FROM film
GROUP BY company_id
HAVING COUNT(*) >= 1;


/* QUERY 14
   INNER JOIN
*/

SELECT
    f.title,
    pc.company_name
FROM film f
INNER JOIN production_company pc
    ON f.company_id = pc.company_id;


/* QUERY 15
   LEFT JOIN
*/

SELECT
    pc.company_name,
    f.title
FROM production_company pc
LEFT JOIN film f
    ON pc.company_id = f.company_id
ORDER BY pc.company_name;


/* QUERY 16
   MULTIPLE-TABLE JOIN
*/

SELECT
    f.title,
    p.first_name || ' ' || p.last_name AS actor_name,
    cr.character_name,
    ca.salary
FROM film f
JOIN character_role cr
    ON f.film_id = cr.film_id
JOIN cast_assignment ca
    ON cr.character_id = ca.character_id
JOIN person p
    ON ca.actor_id = p.person_id;


/* QUERY 17
   SUBQUERY
*/

SELECT
    title,
    planned_budget
FROM film
WHERE planned_budget >
(
    SELECT AVG(planned_budget)
    FROM film
);


/* QUERY 18
   COMPLEX ANALYTICAL QUERY
*/

SELECT
    f.title,
    f.planned_budget,
    COALESCE(SUM(e.amount), 0) AS actual_expenses,
    f.planned_budget
        - COALESCE(SUM(e.amount), 0)
        AS remaining_budget,
    COUNT(DISTINCT s.scene_id) AS scene_count
FROM film f
JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
LEFT JOIN scene s
    ON f.film_id = s.film_id
GROUP BY
    f.film_id,
    f.title,
    f.planned_budget
ORDER BY remaining_budget DESC;


/* =========================================================
   STEP 6. DATA ANALYSIS - 5 QUESTIONS
   ========================================================= */


/* ANALYSIS 1
   Which production companies have the highest number of films?
*/

SELECT
    pc.company_name,
    COUNT(f.film_id) AS number_of_films
FROM production_company pc
LEFT JOIN film f
    ON pc.company_id = f.company_id
GROUP BY pc.company_id, pc.company_name
ORDER BY number_of_films DESC;


/* ANALYSIS 2
   What is the average budget of films by genre?
*/

SELECT
    genre,
    AVG(planned_budget) AS average_budget
FROM film
GROUP BY genre
ORDER BY average_budget DESC;


/* ANALYSIS 3
   Which films have the highest actual production expenses?
*/

SELECT
    f.title,
    COALESCE(SUM(e.amount), 0) AS total_expenses
FROM film f
JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY f.film_id, f.title
ORDER BY total_expenses DESC;


/* ANALYSIS 4
   Which locations are used most frequently?
*/

SELECT
    l.location_name,
    COUNT(s.scene_id) AS scene_usage
FROM location l
LEFT JOIN scene s
    ON l.location_id = s.location_id
GROUP BY l.location_id, l.location_name
ORDER BY scene_usage DESC;


/* ANALYSIS 5
   Which actors participate in the largest number of films?
*/

SELECT
    p.first_name || ' ' || p.last_name AS actor_name,
    COUNT(DISTINCT cr.film_id) AS films_count
FROM person p
JOIN cast_assignment ca
    ON p.person_id = ca.actor_id
JOIN character_role cr
    ON ca.character_id = cr.character_id
GROUP BY p.person_id, p.first_name, p.last_name
ORDER BY films_count DESC;


/* =========================================================
   STEP 7. VIEWS
   ========================================================= */


/* VIEW 1
   Film Budget Report
*/

CREATE OR REPLACE VIEW film_budget_report AS
SELECT
    f.film_id,
    f.title,
    f.planned_budget,
    COALESCE(SUM(e.amount), 0) AS actual_expenses,
    f.planned_budget
        - COALESCE(SUM(e.amount), 0)
        AS remaining_budget
FROM film f
JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY
    f.film_id,
    f.title,
    f.planned_budget;


/* VIEW 2
   Film Cast Report
*/

CREATE OR REPLACE VIEW film_cast_report AS
SELECT
    f.title,
    cr.character_name,
    p.first_name || ' ' || p.last_name AS actor_name,
    ca.salary
FROM cast_assignment ca
JOIN character_role cr
    ON ca.character_id = cr.character_id
JOIN film f
    ON cr.film_id = f.film_id
JOIN person p
    ON ca.actor_id = p.person_id;


/* Test views */

SELECT *
FROM film_budget_report
ORDER BY remaining_budget DESC;


SELECT *
FROM film_cast_report
ORDER BY title;


/* =========================================================
   STEP 8. DATA INTEGRITY
   ========================================================= */


/* TEST 1
   Invalid foreign key.
   This operation MUST be rejected.
*/

DO $$
BEGIN
    BEGIN
        INSERT INTO film
        (
            company_id,
            title,
            genre,
            planned_budget
        )
        VALUES
        (
            9999,
            'Invalid Company Film',
            'Drama',
            100000
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE
            'Integrity Test 1 PASSED:
             invalid company_id was rejected.';
    END;
END $$;


/* TEST 2
   Invalid negative budget.
   This operation MUST be rejected.
*/

DO $$
BEGIN
    BEGIN
        INSERT INTO film
        (
            company_id,
            title,
            genre,
            planned_budget
        )
        VALUES
        (
            1,
            'Negative Budget Film',
            'Drama',
            -50000
        );

    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE
            'Integrity Test 2 PASSED:
             negative budget was rejected.';
    END;
END $$;


/* TEST 3
   Duplicate company name.
   This operation MUST be rejected.
*/

DO $$
BEGIN
    BEGIN
        INSERT INTO production_company
        (
            company_name,
            country,
            founded_year
        )
        VALUES
        (
            'Steppe Films',
            'Kazakhstan',
            2015
        );

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE
            'Integrity Test 3 PASSED:
             duplicate company was rejected.';
    END;
END $$;


/* =========================================================
   STEP 9. MODIFICATION SCENARIOS
   ========================================================= */


/* SCENARIO 1
   A new employee joins the production.
*/

INSERT INTO person
(first_name, last_name, date_of_birth,
 phone, email, nationality)
VALUES
('Kanat', 'Serikov', '1994-10-11',
 '+7-701-555-1111',
 'kanat.serikov@mail.com',
 'Kazakhstan')
RETURNING person_id;


/* SCENARIO 2
   A new crew member is assigned to a film.
*/

INSERT INTO film_crew
(film_id, person_id, position, start_date)
VALUES
(1, 12, 'Production Assistant', '2026-10-01')
RETURNING crew_id;


/* SCENARIO 3
   A production expense is corrected.
*/

UPDATE expense
SET amount = 30000
WHERE expense_id = 1
RETURNING expense_id, amount;


/* SCENARIO 4
   A shooting session status is changed.
*/

UPDATE shooting_schedule
SET session_status = 'Completed'
WHERE schedule_id = 2
RETURNING schedule_id, session_status;


/* SCENARIO 5
   A new film release is registered.
*/

INSERT INTO film_release
(
    film_id,
    release_country,
    release_date,
    distribution_type,
    box_office_revenue
)
VALUES
(
    1,
    'Uzbekistan',
    '2027-02-01',
    'Cinema',
    0
)
RETURNING release_id;


/* =========================================================
   STEP 10. REPORTS
   ========================================================= */


/* REPORT 1
   FINANCIAL REPORT
*/

SELECT
    f.title,
    f.planned_budget,
    COALESCE(SUM(e.amount), 0) AS actual_expenses,
    f.planned_budget
        - COALESCE(SUM(e.amount), 0)
        AS remaining_budget
FROM film f
JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY
    f.film_id,
    f.title,
    f.planned_budget
ORDER BY actual_expenses DESC;


/* REPORT 2
   CAST REPORT
*/

SELECT
    f.title,
    cr.character_name,
    p.first_name || ' ' || p.last_name AS actor,
    ca.salary
FROM film f
JOIN character_role cr
    ON f.film_id = cr.film_id
JOIN cast_assignment ca
    ON cr.character_id = ca.character_id
JOIN person p
    ON ca.actor_id = p.person_id
ORDER BY
    f.title,
    actor;


/* REPORT 3
   PRODUCTION ACTIVITY REPORT
*/

SELECT
    f.title,

    COUNT(DISTINCT s.scene_id)
        AS scene_count,

    COUNT(DISTINCT fc.person_id)
        AS crew_count,

    COUNT(DISTINCT ss.schedule_id)
        AS shooting_sessions

FROM film f

LEFT JOIN scene s
    ON f.film_id = s.film_id

LEFT JOIN film_crew fc
    ON f.film_id = fc.film_id

LEFT JOIN shooting_schedule ss
    ON f.film_id = ss.film_id

GROUP BY
    f.film_id,
    f.title

ORDER BY
    shooting_sessions DESC;


/* =========================================================
   STEP 11. FINAL DATABASE STRUCTURE
   ========================================================= */


/* List of tables */

SELECT
    table_name
FROM information_schema.tables
WHERE table_schema = 'film_studio'
ORDER BY table_name;


/* Number of records in major tables */

SELECT
    'production_company' AS table_name,
    COUNT(*) AS record_count
FROM production_company

UNION ALL

SELECT
    'film',
    COUNT(*)
FROM film

UNION ALL

SELECT
    'person',
    COUNT(*)
FROM person

UNION ALL

SELECT
    'production_project',
    COUNT(*)
FROM production_project

UNION ALL

SELECT
    'film_crew',
    COUNT(*)
FROM film_crew

UNION ALL

SELECT
    'character_role',
    COUNT(*)
FROM character_role

UNION ALL

SELECT
    'cast_assignment',
    COUNT(*)
FROM cast_assignment

UNION ALL

SELECT
    'location',
    COUNT(*)
FROM location

UNION ALL

SELECT
    'scene',
    COUNT(*)
FROM scene

UNION ALL

SELECT
    'shooting_schedule',
    COUNT(*)
FROM shooting_schedule

UNION ALL

SELECT
    'contract',
    COUNT(*)
FROM contract

UNION ALL

SELECT
    'expense',
    COUNT(*)
FROM expense

UNION ALL

SELECT
    'film_release',
    COUNT(*)
FROM film_release

ORDER BY table_name;


/* =========================================================
   FINAL CHECK
   ========================================================= */

SELECT
    current_database() AS database_name,
    current_schema() AS current_schema;
/* =========================================================
   PART 7. 15 SQL QUERIES
   ========================================================= */

SET search_path TO film_studio;


/* Q1. Select all films */
SELECT *
FROM film;


/* Q2. Select selected film columns */
SELECT title, genre, release_year, planned_budget
FROM film;


/* Q3. WHERE - films currently in production */
SELECT film_id, title, production_status
FROM film
WHERE production_status = 'In Production';


/* Q4. ORDER BY - films by planned budget */
SELECT title, planned_budget
FROM film
ORDER BY planned_budget DESC;


/* Q5. LIKE - titles containing "The" */
SELECT film_id, title
FROM film
WHERE title LIKE '%The%';


/* Q6. BETWEEN - films with budget between 2 and 6 million */
SELECT title, planned_budget
FROM film
WHERE planned_budget BETWEEN 2000000 AND 6000000;


/* Q7. IN - selected genres */
SELECT title, genre
FROM film
WHERE genre IN ('Drama', 'Adventure', 'Thriller');


/* Q8. Aggregate functions */
SELECT
    COUNT(*) AS film_count,
    SUM(planned_budget) AS total_budget,
    AVG(planned_budget) AS average_budget,
    MIN(planned_budget) AS minimum_budget,
    MAX(planned_budget) AS maximum_budget
FROM film;


/* Q9. GROUP BY - number of films by company */
SELECT
    pc.company_name,
    COUNT(f.film_id) AS film_count
FROM production_company pc
LEFT JOIN film f
    ON pc.company_id = f.company_id
GROUP BY pc.company_id, pc.company_name
ORDER BY film_count DESC;


/* Q10. HAVING - projects with expenses above 20,000 */
SELECT
    pp.project_name,
    SUM(e.amount) AS total_expenses
FROM production_project pp
JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY pp.project_id, pp.project_name
HAVING SUM(e.amount) > 20000
ORDER BY total_expenses DESC;


/* Q11. INNER JOIN - films and production companies */
SELECT
    f.title,
    f.genre,
    pc.company_name,
    pc.country
FROM film f
INNER JOIN production_company pc
    ON f.company_id = pc.company_id
ORDER BY f.title;


/* Q12. LEFT JOIN - films and production projects */
SELECT
    f.title,
    f.production_status,
    pp.project_name,
    pp.project_status
FROM film f
LEFT JOIN production_project pp
    ON f.film_id = pp.film_id
ORDER BY f.title;


/* Q13. Multiple-table JOIN */
SELECT
    f.title,
    pc.company_name,
    pp.project_name,
    COALESCE(SUM(e.amount), 0) AS total_expenses
FROM film f
JOIN production_company pc
    ON f.company_id = pc.company_id
JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY
    f.film_id,
    f.title,
    pc.company_name,
    pp.project_name
ORDER BY total_expenses DESC;


/* Q14. Subquery - films above average budget */
SELECT
    title,
    planned_budget
FROM film
WHERE planned_budget >
      (SELECT AVG(planned_budget) FROM film)
ORDER BY planned_budget DESC;


/* Q15. Complex analytical query */
SELECT
    f.title,
    f.planned_budget,
    COALESCE(SUM(e.amount), 0) AS actual_expenses,
    f.planned_budget - COALESCE(SUM(e.amount), 0)
        AS remaining_budget,
    ROUND(
        COALESCE(SUM(e.amount), 0)
        / NULLIF(f.planned_budget, 0) * 100,
        2
    ) AS expense_percentage
FROM film f
LEFT JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY
    f.film_id,
    f.title,
    f.planned_budget
ORDER BY expense_percentage DESC;


/* =========================================================
   PART 8. 5 ANALYTICAL QUESTIONS
   ========================================================= */


/* A1. Which films have the highest actual expenses? */
SELECT
    f.title,
    COALESCE(SUM(e.amount), 0) AS actual_expenses
FROM film f
LEFT JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY f.film_id, f.title
ORDER BY actual_expenses DESC;


/* A2. Which films have expenses above the average
      actual expense? */
SELECT
    f.title,
    SUM(e.amount) AS actual_expenses
FROM film f
JOIN production_project pp
    ON f.film_id = pp.film_id
JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY f.film_id, f.title
HAVING SUM(e.amount) >
(
    SELECT AVG(total_expenses)
    FROM
    (
        SELECT SUM(e2.amount) AS total_expenses
        FROM production_project pp2
        JOIN expense e2
            ON pp2.project_id = e2.project_id
        GROUP BY pp2.project_id
    ) AS expense_summary
)
ORDER BY actual_expenses DESC;


/* A3. Which locations are used most often? */
SELECT
    l.location_name,
    l.city,
    l.country,
    COUNT(s.scene_id) AS scene_count
FROM location l
LEFT JOIN scene s
    ON l.location_id = s.location_id
GROUP BY
    l.location_id,
    l.location_name,
    l.city,
    l.country
ORDER BY scene_count DESC;


/* A4. Which actors participate in the largest number
      of character assignments? */
SELECT
    p.first_name,
    p.last_name,
    COUNT(ca.cast_id) AS character_count
FROM person p
JOIN cast_assignment ca
    ON p.person_id = ca.actor_id
GROUP BY p.person_id, p.first_name, p.last_name
ORDER BY character_count DESC;


/* A5. Which films have the largest remaining budget? */
SELECT
    f.title,
    f.planned_budget,
    COALESCE(SUM(e.amount), 0) AS actual_expenses,
    f.planned_budget - COALESCE(SUM(e.amount), 0)
        AS remaining_budget
FROM film f
LEFT JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY f.film_id, f.title, f.planned_budget
ORDER BY remaining_budget DESC;


/* =========================================================
   PART 9. TWO VIEWS
   ========================================================= */

/* Delete old versions */
DROP VIEW IF EXISTS film_budget_report CASCADE;
DROP VIEW IF EXISTS film_cast_report CASCADE;


/* VIEW 1. Film budget report */
CREATE VIEW film_budget_report AS
SELECT
    f.film_id,
    f.title,
    f.planned_budget,
    COALESCE(SUM(e.amount), 0) AS actual_expenses,
    f.planned_budget - COALESCE(SUM(e.amount), 0)
        AS remaining_budget
FROM film f
LEFT JOIN production_project pp
    ON f.film_id = pp.film_id
LEFT JOIN expense e
    ON pp.project_id = e.project_id
GROUP BY
    f.film_id,
    f.title,
    f.planned_budget;


/* VIEW 2. Film cast report */
CREATE VIEW film_cast_report AS
SELECT
    f.film_id,
    f.title,
    COUNT(DISTINCT cr.character_id) AS character_count,
    COUNT(DISTINCT ca.actor_id) AS actor_count,
    COALESCE(SUM(ca.salary), 0) AS total_cast_salary
FROM film f
LEFT JOIN character_role cr
    ON f.film_id = cr.film_id
LEFT JOIN cast_assignment ca
    ON cr.character_id = ca.character_id
GROUP BY
    f.film_id,
    f.title;


/* Test VIEW 1 */
SELECT *
FROM film_budget_report
ORDER BY remaining_budget DESC;


/* Test VIEW 2 */
SELECT *
FROM film_cast_report
ORDER BY actor_count DESC;


/* =========================================================
   PART 10. DATA INTEGRITY TESTS
   ========================================================= */


/* TEST 1. Invalid foreign key */
DO $$
BEGIN
    BEGIN
        INSERT INTO film
        (
            company_id,
            title,
            genre,
            release_year,
            planned_budget,
            production_status,
            runtime_minutes
        )
        VALUES
        (
            99999,
            'Invalid FK Film',
            'Drama',
            2026,
            100000,
            'Planned',
            100
        );

    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE
            'TEST 1 PASSED: Invalid company_id was rejected.';
    END;
END $$;


/* TEST 2. Invalid negative budget */
DO $$
BEGIN
    BEGIN
        INSERT INTO film
        (
            company_id,
            title,
            genre,
            release_year,
            planned_budget,
            production_status,
            runtime_minutes
        )
        VALUES
        (
            1,
            'Negative Budget Film',
            'Drama',
            2026,
            -5000,
            'Planned',
            100
        );

    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE
            'TEST 2 PASSED: Negative budget was rejected.';
    END;
END $$;


/* TEST 3. Duplicate company name */
DO $$
BEGIN
    BEGIN
        INSERT INTO production_company
        (
            company_name,
            country,
            founded_year
        )
        VALUES
        (
            'Steppe Films',
            'Kazakhstan',
            2025
        );

    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE
            'TEST 3 PASSED: Duplicate company name was rejected.';
    END;
END $$;


/* =========================================================
   PART 11. NORMALIZATION
   ========================================================= */

/*
1NF:
Each field contains one atomic value.
Repeating groups are separated into different records.

2NF:
All non-key attributes depend on the whole primary key.
Many-to-many relationships are separated into junction tables.

Example:
film_crew(film_id, person_id, position)

3NF:
Non-key attributes depend only on the primary key.
Company information is stored in production_company,
person information is stored in person,
and film information is stored in film.
*/


/* =========================================================
   PART 12. FIVE MODIFICATION SCENARIOS
   ========================================================= */


/* Scenario 1. Add a new person */

BEGIN;

INSERT INTO person
(
    first_name,
    last_name,
    date_of_birth,
    phone,
    email,
    nationality
)
VALUES
(
    'Test',
    'Person',
    '1995-01-01',
    '+7-700-000-0000',
    'test.person@example.com',
    'Kazakhstan'
);

ROLLBACK;


/* Scenario 2. Update a person's phone */

BEGIN;

UPDATE person
SET phone = '+7-701-999-9999'
WHERE person_id = 1;

ROLLBACK;


/* Scenario 3. Add a new crew member */

BEGIN;

INSERT INTO film_crew
(
    film_id,
    person_id,
    position,
    start_date
)
VALUES
(
    1,
    10,
    'Production Assistant',
    CURRENT_DATE
);

ROLLBACK;


/* Scenario 4. Update shooting schedule status */

BEGIN;

UPDATE shooting_schedule
SET session_status = 'Completed'
WHERE schedule_id = 2;

ROLLBACK;


/* Scenario 5. Add a new film release */

BEGIN;

INSERT INTO film_release
(
    film_id,
    release_country,
    release_date,
    distribution_type,
    box_office_revenue
)
VALUES
(
    1,
    'Testland',
    '2027-02-01',
    'Cinema',
    0
);

ROLLBACK;



/* =========================================================
   PART 13. THREE REPORTS
   ========================================================= */


/* REPORT 1. Financial Report
   Shows planned budget, actual expenses
   and remaining budget for each film.
*/

SELECT
    title,
    planned_budget,
    actual_expenses,
    remaining_budget
FROM film_budget_report
ORDER BY remaining_budget DESC;


/* REPORT 2. Cast Report
   Shows number of characters, actors
   and total cast salary for each film.
*/

SELECT
    title,
    character_count,
    actor_count,
    total_cast_salary
FROM film_cast_report
ORDER BY total_cast_salary DESC;


/* REPORT 3. Production Activity Report
   Shows scenes, shooting sessions
   and crew members for each film.
*/

SELECT
    f.title,
    COUNT(DISTINCT s.scene_id) AS scene_count,
    COUNT(DISTINCT ss.schedule_id) AS shooting_sessions,
    COUNT(DISTINCT fc.crew_id) AS crew_members
FROM film f

LEFT JOIN scene s
    ON f.film_id = s.film_id

LEFT JOIN shooting_schedule ss
    ON f.film_id = ss.film_id

LEFT JOIN film_crew fc
    ON f.film_id = fc.film_id

GROUP BY
    f.film_id,
    f.title

ORDER BY
    shooting_sessions DESC;


/* =========================================================
   END OF PART 13
   ========================================================= */


/* =========================================================
   PART 14. FINAL DATABASE STRUCTURE / RECORD COUNTS
   ========================================================= */


/* Record count for all 13 tables */

SELECT
    'production_company' AS table_name,
    COUNT(*) AS record_count
FROM production_company

UNION ALL

SELECT
    'film',
    COUNT(*)
FROM film

UNION ALL

SELECT
    'person',
    COUNT(*)
FROM person

UNION ALL

SELECT
    'production_project',
    COUNT(*)
FROM production_project

UNION ALL

SELECT
    'film_crew',
    COUNT(*)
FROM film_crew

UNION ALL

SELECT
    'character_role',
    COUNT(*)
FROM character_role

UNION ALL

SELECT
    'cast_assignment',
    COUNT(*)
FROM cast_assignment

UNION ALL

SELECT
    'location',
    COUNT(*)
FROM location

UNION ALL

SELECT
    'scene',
    COUNT(*)
FROM scene

UNION ALL

SELECT
    'shooting_schedule',
    COUNT(*)
FROM shooting_schedule

UNION ALL

SELECT
    'contract',
    COUNT(*)
FROM contract

UNION ALL

SELECT
    'expense',
    COUNT(*)
FROM expense

UNION ALL

SELECT
    'film_release',
    COUNT(*)
FROM film_release

ORDER BY
    table_name;


/* =========================================================
   END OF PART 14
   ========================================================= */