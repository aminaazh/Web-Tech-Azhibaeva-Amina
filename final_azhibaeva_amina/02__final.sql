-- ============================================================
-- Final Project — Amina Azhibaeva — Veterinary Clinic
-- Database: vet_clinic_db / Schema: vet_clinic
-- ============================================================


-- ============================================================
-- DATABASE + SCHEMA
-- ============================================================

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'vet_clinic_db') THEN
        EXECUTE 'CREATE DATABASE vet_clinic_db';
    END IF;
END $$;

CREATE SCHEMA IF NOT EXISTS vet_clinic;


-- RE-RUNNABLE DROP BLOCK

DROP TABLE IF EXISTS
    vet_clinic.visit_treatments,
    vet_clinic.vaccinations,
    vet_clinic.visits,
    vet_clinic.treatments,
    vet_clinic.vets,
    vet_clinic.pets,
    vet_clinic.departments,
    vet_clinic.owners,
    vet_clinic.species
CASCADE;


-- =====  PART 2: CREATE TABLE  =====

-- Species list for categorizing pets
CREATE TABLE IF NOT EXISTS vet_clinic.species (
    species_id     SERIAL PRIMARY KEY,

    -- Species names must be unique
    species_name   VARCHAR(50) NOT NULL UNIQUE
);


-- Pet owner information
CREATE TABLE IF NOT EXISTS vet_clinic.owners (
    owner_id        SERIAL PRIMARY KEY,

    -- Owner full name is required
    full_name       VARCHAR(150) NOT NULL,

    -- Email must be unique for each owner
    email           VARCHAR(255) NOT NULL UNIQUE,

    -- Initial phone length kept short intentionally for ALTER task
    phone_number    VARCHAR(15),

    birth_date      DATE,

    -- Automatically store account creation time
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);


-- Veterinary clinic departments
CREATE TABLE IF NOT EXISTS vet_clinic.departments (
    department_id     SERIAL PRIMARY KEY,

    -- Department names cannot repeat
    department_name   VARCHAR(100) NOT NULL UNIQUE
);


-- Veterinarian employees
CREATE TABLE IF NOT EXISTS vet_clinic.vets (
    vet_id              SERIAL PRIMARY KEY,

    department_id       INT NOT NULL
                         REFERENCES vet_clinic.departments(department_id)
                         ON DELETE RESTRICT,

    -- Each veterinarian license must be unique
    license_number      VARCHAR(50) NOT NULL UNIQUE,

    -- Veterinarian name is required
    full_name           VARCHAR(100) NOT NULL,

    specialization      VARCHAR(100),

    -- Salary cannot be negative
    salary              NUMERIC(10,2)
                         CHECK (salary >= 0),

    hire_date           DATE
);


-- Pet information
CREATE TABLE IF NOT EXISTS vet_clinic.pets (
    pet_id             SERIAL PRIMARY KEY,

    species_id         INT NOT NULL
                       REFERENCES vet_clinic.species(species_id)
                       ON DELETE RESTRICT,

    owner_id           INT NOT NULL
                       REFERENCES vet_clinic.owners(owner_id)
                       ON DELETE CASCADE,

    -- Pet name is required
    pet_name           VARCHAR(100) NOT NULL,

    birth_date         DATE,

    -- Pet weight cannot be negative
    weight_kg          NUMERIC(5,2)
                       CHECK (weight_kg >= 0),

    -- Allowed gender values only
    gender             VARCHAR(10)
                       CHECK (gender IN ('Male', 'Female', 'Other')),

    -- Pet activity status options
    status             VARCHAR(20)
                       DEFAULT 'active'
                       CHECK (status IN ('active', 'deceased', 'transferred'))
);


-- Clinic visits
CREATE TABLE IF NOT EXISTS vet_clinic.visits (
    visit_id             SERIAL PRIMARY KEY,

    pet_id               INT NOT NULL
                         REFERENCES vet_clinic.pets(pet_id)
                         ON DELETE CASCADE,

    vet_id               INT NOT NULL
                         REFERENCES vet_clinic.vets(vet_id)
                         ON DELETE SET NULL,

    -- Visits in the system must be after 2026-01-01
    visit_date           DATE NOT NULL
                         CHECK (visit_date > DATE '2026-01-01'),

    diagnosis            VARCHAR(255),

    -- Allowed visit status values only
    visit_status         VARCHAR(20)
                         CHECK (visit_status IN
                         ('scheduled', 'completed', 'cancelled')),

    -- Consultation fee cannot be negative
    consultation_fee     NUMERIC(10,2)
                         CHECK (consultation_fee >= 0)
);


-- Vaccination records
CREATE TABLE IF NOT EXISTS vet_clinic.vaccinations (
    vaccination_id      SERIAL PRIMARY KEY,

    pet_id              INT NOT NULL
                        REFERENCES vet_clinic.pets(pet_id)
                        ON DELETE CASCADE,

    vet_id              INT NOT NULL
                        REFERENCES vet_clinic.vets(vet_id)
                        ON DELETE SET NULL,

    vaccine_name        VARCHAR(120) NOT NULL,

    vaccination_date    DATE NOT NULL,

    next_due_date       DATE,

    -- Vaccination cost cannot be negative
    cost                NUMERIC(10,2)
                        CHECK (cost >= 0)
);


-- Treatment types offered by the clinic
CREATE TABLE IF NOT EXISTS vet_clinic.treatments (
    treatment_id        SERIAL PRIMARY KEY,

    -- Treatment names must be unique
    treatment_name      VARCHAR(120) NOT NULL UNIQUE,

    -- Treatment base price cannot be negative
    base_cost           NUMERIC(10,2)
                        CHECK (base_cost >= 0)
);


-- Junction table connecting visits and treatments
CREATE TABLE IF NOT EXISTS vet_clinic.visit_treatments (

    visit_id            INT NOT NULL
                        REFERENCES vet_clinic.visits(visit_id)
                        ON DELETE CASCADE,

    treatment_id        INT NOT NULL
                        REFERENCES vet_clinic.treatments(treatment_id)
                        ON DELETE RESTRICT,

    -- Quantity of procedures must be positive
    quantity            INT NOT NULL
                        CHECK (quantity > 0),

    -- Unit cost cannot be negative
    unit_cost           NUMERIC(10,2) NOT NULL
                        CHECK (unit_cost >= 0),

    -- Automatically calculate treatment total
    total_cost          NUMERIC(12,2)
                        GENERATED ALWAYS AS
                        (quantity * unit_cost) STORED,

    PRIMARY KEY (visit_id, treatment_id)
);

--SELECT table_name FROM information_schema.tables
--WHERE table_schema = 'vet_clinic'
--ORDER BY table_name;

-- =====  PART 3: ALTER TABLE  =====

-- international clients started providing longer phone numbers
ALTER TABLE vet_clinic.owners
ALTER COLUMN phone_number TYPE VARCHAR(20);

-- diagnosis notes became more detailed over time
ALTER TABLE vet_clinic.visits
ALTER COLUMN diagnosis TYPE VARCHAR(500);

-- scheduled visits now default to a zero consultation fee
ALTER TABLE vet_clinic.visits
ALTER COLUMN consultation_fee SET DEFAULT 0;

-- column name 'status' in pets table was too generic
ALTER TABLE vet_clinic.pets
RENAME COLUMN status TO pet_status;

-- vaccination reminders should always have a future due date
ALTER TABLE vet_clinic.vaccinations
ADD CONSTRAINT chk_next_due_date
CHECK (
    next_due_date IS NULL
    OR next_due_date > vaccination_date);



-- =====  PART 4: INSERT  =====

-- Re-runnable reset for all clinic tables
TRUNCATE TABLE
    vet_clinic.visit_treatments,
    vet_clinic.vaccinations,
    vet_clinic.visits,
    vet_clinic.treatments,
    vet_clinic.vets,
    vet_clinic.pets,
    vet_clinic.departments,
    vet_clinic.owners,
    vet_clinic.species
RESTART IDENTITY CASCADE;


-- Parent tables

-- Pet species
INSERT INTO vet_clinic.species (species_name) VALUES
    ('Dog'),
    ('Cat'),
    ('Parrot');


-- Pet owners
INSERT INTO vet_clinic.owners (
    full_name,
    email,
    phone_number,
    birth_date
) VALUES
    (
        'Madison White',
        'madiwhite@gmail.com',
        '+77015551234',
        DATE '1995-04-12'
    ),
    (
        'Alina Lopez',
        'alinkalopez@gmail.com',
        '+77025552345',
        DATE '1989-08-21'
    ),
    (
        'Kamila Nurpeisova',
        'kamila.hi@gmail.com',
        '+77035553456',
        DATE '1998-11-03'
    );


-- Clinic departments
INSERT INTO vet_clinic.departments (
    department_name
) VALUES
    ('Surgery'),
    ('Dentistry'),
    ('Diagnostics');


-- Available treatment types
INSERT INTO vet_clinic.treatments (
    treatment_name,
    base_cost
) VALUES
    ('Vaccination', 5000.00),
    ('X-Ray', 12000.00),
    ('Antibiotic Injection', 3500.00);



-- Child tables with FK subqueries

-- Veterinarians assigned to departments
INSERT INTO vet_clinic.vets (
    department_id,
    license_number,
    full_name,
    specialization,
    salary,
    hire_date
) VALUES
    (
        (
            SELECT department_id
            FROM vet_clinic.departments
            WHERE department_name = 'Surgery'
        ),
        'VET-KZ-1001',
        'Dr. Timur Askarov',
        'Soft Tissue Surgery',
        850000.00,
        DATE '2022-03-15'
    ),
    (
        (
            SELECT department_id
            FROM vet_clinic.departments
            WHERE department_name = 'Dentistry'
        ),
        'VET-KZ-1002',
        'Dr. Aliya Nurgalieva',
        'Veterinary Dentistry',
        780000.00,
        DATE '2021-09-10'
    ),
    (
        (
            SELECT department_id
            FROM vet_clinic.departments
            WHERE department_name = 'Diagnostics'
        ),
        'VET-KZ-1003',
        'Dr. Ruslan Ibrayev',
        'Diagnostic Imaging',
        820000.00,
        DATE '2023-01-20'
    );


-- Pets connected to owners and species
INSERT INTO vet_clinic.pets (
    species_id,
    owner_id,
    pet_name,
    birth_date,
    weight_kg,
    gender,
    pet_status
) VALUES
    (
        (
            SELECT species_id
            FROM vet_clinic.species
            WHERE species_name = 'Dog'
        ),
        (
            SELECT owner_id
            FROM vet_clinic.owners
            WHERE email = 'madiwhite@gmail.com'
        ),
        'Rocky',
        DATE '2022-05-11',
        18.50,
        'Male',
        'active'
    ),
    (
        (
            SELECT species_id
            FROM vet_clinic.species
            WHERE species_name = 'Cat'
        ),
        (
            SELECT owner_id
            FROM vet_clinic.owners
            WHERE email = 'alinkalopez@gmail.com'
        ),
        'Milo',
        DATE '2021-02-17',
        4.30,
        'Male',
        'active'
    ),
    (
        (
            SELECT species_id
            FROM vet_clinic.species
            WHERE species_name = 'Parrot'
        ),
        (
            SELECT owner_id
            FROM vet_clinic.owners
            WHERE email = 'kamila.hi@gmail.com'
        ),
        'Kiwi',
        DATE '2023-07-09',
        0.90,
        'Female',
        'active'
    );


-- Veterinary clinic visits
INSERT INTO vet_clinic.visits (
    pet_id,
    vet_id,
    visit_date,
    diagnosis,
    visit_status,
    consultation_fee
) VALUES
    (
        (
            SELECT pet_id
            FROM vet_clinic.pets
            WHERE pet_name = 'Rocky'
        ),
        (
            SELECT vet_id
            FROM vet_clinic.vets
            WHERE license_number = 'VET-KZ-1001'
        ),
        DATE '2026-03-05',
        'Minor leg inflammation after outdoor injury',
        'completed',
        8000.00
    ),
    (
        (
            SELECT pet_id
            FROM vet_clinic.pets
            WHERE pet_name = 'Milo'
        ),
        (
            SELECT vet_id
            FROM vet_clinic.vets
            WHERE license_number = 'VET-KZ-1002'
        ),
        DATE '2026-03-18',
        'Dental plaque and gum irritation',
        'completed',
        9000.00
    ),
    (
        (
            SELECT pet_id
            FROM vet_clinic.pets
            WHERE pet_name = 'Kiwi'
        ),
        (
            SELECT vet_id
            FROM vet_clinic.vets
            WHERE license_number = 'VET-KZ-1003'
        ),
        DATE '2026-04-02',
        'Routine wellness examination',
        'scheduled',
        0.00
    );


-- Vaccination history
INSERT INTO vet_clinic.vaccinations (
    pet_id,
    vet_id,
    vaccine_name,
    vaccination_date,
    next_due_date,
    cost
) VALUES
    (
        (
            SELECT pet_id
            FROM vet_clinic.pets
            WHERE pet_name = 'Rocky'
        ),
        (
            SELECT vet_id
            FROM vet_clinic.vets
            WHERE license_number = 'VET-KZ-1001'
        ),
        'Rabies Vaccine',
        DATE '2026-03-05',
        DATE '2027-03-05',
        7000.00
    ),
    (
        (
            SELECT pet_id
            FROM vet_clinic.pets
            WHERE pet_name = 'Milo'
        ),
        (
            SELECT vet_id
            FROM vet_clinic.vets
            WHERE license_number = 'VET-KZ-1002'
        ),
        'Feline Viral Rhinotracheitis Vaccine',
        DATE '2026-03-18',
        DATE '2027-03-18',
        6500.00
    ),
    (
        (
            SELECT pet_id
            FROM vet_clinic.pets
            WHERE pet_name = 'Kiwi'
        ),
        (
            SELECT vet_id
            FROM vet_clinic.vets
            WHERE license_number = 'VET-KZ-1003'
        ),
        'Avian Polyomavirus Vaccine',
        DATE '2026-04-02',
        DATE '2027-04-02',
        5500.00
    );



-- Junction table via INSERT ... SELECT

-- Treatments performed during visits
INSERT INTO vet_clinic.visit_treatments (
    visit_id,
    treatment_id,
    quantity,
    unit_cost
)
SELECT
    v.visit_id,
    t.treatment_id,
    x.quantity,
    x.unit_cost
FROM (
    VALUES
        ('Rocky', 'X-Ray', 1, 12000.00),
        ('Rocky', 'Antibiotic Injection', 2, 3500.00),
        ('Milo', 'Vaccination', 1, 5000.00),
        ('Kiwi', 'Vaccination', 1, 5000.00)
) AS x(pet_name, treatment_name, quantity, unit_cost)

JOIN vet_clinic.pets p
    ON p.pet_name = x.pet_name

JOIN vet_clinic.visits v
    ON v.pet_id = p.pet_id

JOIN vet_clinic.treatments t
    ON t.treatment_name = x.treatment_name;


--SELECT 'species' AS t, COUNT(*) FROM vet_clinic.species
--UNION ALL
--SELECT 'owners', COUNT(*) FROM vet_clinic.owners
--UNION ALL
--SELECT 'departments', COUNT(*) FROM vet_clinic.departments
--UNION ALL
--SELECT 'vets', COUNT(*) FROM vet_clinic.vets
--UNION ALL
--SELECT 'pets', COUNT(*) FROM vet_clinic.pets
--UNION ALL
--SELECT 'visits', COUNT(*) FROM vet_clinic.visits
--UNION ALL
--SELECT 'vaccinations', COUNT(*) FROM vet_clinic.vaccinations
--UNION ALL
--SELECT 'treatments', COUNT(*) FROM vet_clinic.treatments
--UNION ALL
--SELECT 'visit_treatments', COUNT(*) FROM vet_clinic.visit_treatments;


-- =====  PART 5: UPDATE  =====

-- Business reason: pets heavier than 10 kg are marked for
-- large-animal dosage monitoring in the clinic system.
UPDATE vet_clinic.pets
SET pet_status = 'transferred'
WHERE weight_kg > 10;


-- Business reason: after treatment costs were reviewed,
-- visit consultation totals must reflect all treatment costs.
UPDATE vet_clinic.visits v
SET consultation_fee = sub.total_treatment_cost
FROM (
    SELECT
        visit_id,
        SUM(total_cost) AS total_treatment_cost
    FROM vet_clinic.visit_treatments
    GROUP BY visit_id
) sub
WHERE v.visit_id = sub.visit_id;


-- =====  PART 5: DELETE  =====

-- Business reason: cancelled visits older than 90 days
-- are periodically removed from the operational system.
-- Wrapped in a transaction so demo data survives defense.
BEGIN;

    DELETE FROM vet_clinic.visits
    WHERE visit_status = 'cancelled'
      AND visit_date < CURRENT_DATE - INTERVAL '90 days'

    RETURNING
        visit_id,
        pet_id,
        vet_id,
        visit_date;

ROLLBACK;


-- =====  PART 6: GRANT / REVOKE  =====

-- Re-runnable cleanup for existing application roles
DO $$
BEGIN

    IF EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'vet_clinic_readonly'
    ) THEN

        REASSIGN OWNED BY vet_clinic_readonly TO CURRENT_USER;
        DROP OWNED BY vet_clinic_readonly;
        DROP ROLE vet_clinic_readonly;

    END IF;


    IF EXISTS (
        SELECT FROM pg_roles
        WHERE rolname = 'vet_clinic_writer'
    ) THEN

        REASSIGN OWNED BY vet_clinic_writer TO CURRENT_USER;
        DROP OWNED BY vet_clinic_writer;
        DROP ROLE vet_clinic_writer;

    END IF;

END $$;


-- Read-only role for clinic reporting staff
CREATE ROLE vet_clinic_readonly;


-- Writer role for appointment management staff
CREATE ROLE vet_clinic_writer;


-- Schema access required before table permissions work
GRANT USAGE
ON SCHEMA vet_clinic
TO vet_clinic_readonly,
   vet_clinic_writer;


-- Read-only role can view all clinic tables
GRANT SELECT
ON ALL TABLES IN SCHEMA vet_clinic
TO vet_clinic_readonly;


-- Writer role can add and update visit records
GRANT INSERT, UPDATE
ON vet_clinic.visits
TO vet_clinic_writer;


-- The writer role is used by front-desk scheduling staff.
-- Visit updates were revoked to prevent unauthorized
-- modifications to completed medical records.
REVOKE UPDATE
ON vet_clinic.visits
FROM vet_clinic_writer;