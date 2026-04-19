CREATE SCHEMA IF NOT EXISTS astana_library;

-- TABLES
-- Genres table
CREATE TABLE IF NOT EXISTS astana_library.Genres (
    GenreID SERIAL PRIMARY KEY,
    GenreName VARCHAR(50) NOT NULL UNIQUE
);

-- Authors table
CREATE TABLE IF NOT EXISTS astana_library.Authors (
    AuthorID SERIAL PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL
);

-- Books table
CREATE TABLE IF NOT EXISTS astana_library.Books (
    BookID SERIAL PRIMARY KEY,
    BookName VARCHAR(100) NOT NULL,
    PublicationYear INT CHECK (PublicationYear > 0),
    ISBN CHAR(13) NOT NULL UNIQUE
);

-- Many-to-many: Books-Genres
CREATE TABLE IF NOT EXISTS astana_library.BookGenre (
    BookID INT,
    GenreID INT,
    PRIMARY KEY (BookID, GenreID),
    FOREIGN KEY (BookID) REFERENCES astana_library.Books(BookID),
    FOREIGN KEY (GenreID) REFERENCES astana_library.Genres(GenreID)
);

-- Many-to-many: Books-Authors
CREATE TABLE IF NOT EXISTS astana_library.BookAuthors (
    BookID INT,
    AuthorID INT,
    PRIMARY KEY (BookID, AuthorID),
    FOREIGN KEY (BookID) REFERENCES astana_library.Books(BookID),
    FOREIGN KEY (AuthorID) REFERENCES astana_library.Authors(AuthorID)
);

-- Borrowers table
CREATE TABLE IF NOT EXISTS astana_library.Borrowers (
    BorrowerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    Phone VARCHAR(15) NOT NULL UNIQUE,
    RegistrationDate DATE NOT NULL CHECK (RegistrationDate > '2026-01-01')
);

-- Staff table
CREATE TABLE IF NOT EXISTS astana_library.LibraryStaff (
    StaffID SERIAL PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Birthdate DATE NOT NULL,
    Role VARCHAR(20) NOT NULL CHECK (Role IN ('Librarian', 'Assistant')),
    Phone VARCHAR(15) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    Address VARCHAR(255) NOT NULL,
    EmploymentDate DATE NOT NULL
);

-- Book copies
CREATE TABLE IF NOT EXISTS astana_library.BookCopies (
    CopyID SERIAL PRIMARY KEY,
    BookID INT NOT NULL,
    Barcode VARCHAR(50) NOT NULL UNIQUE,
    Shelf VARCHAR(50) NOT NULL,
    Status VARCHAR(20) DEFAULT 'available' CHECK (Status IN ('available','borrowed','reserved','lost')),
    FOREIGN KEY (BookID) REFERENCES astana_library.Books(BookID)
);

-- Loans table
CREATE TABLE IF NOT EXISTS astana_library.Loans (
    LoanID SERIAL PRIMARY KEY,
    LoanDate DATE NOT NULL,
    DueDate DATE NOT NULL,
    ReturnDate DATE,
    BorrowerID INT NOT NULL,
    CopyID INT NOT NULL,
    StaffID INT NOT NULL,
    
    LoanDuration INT GENERATED ALWAYS AS (DueDate - LoanDate) STORED,

    FOREIGN KEY (BorrowerID) REFERENCES astana_library.Borrowers(BorrowerID),
    FOREIGN KEY (CopyID) REFERENCES astana_library.BookCopies(CopyID),
    FOREIGN KEY (StaffID) REFERENCES astana_library.LibraryStaff(StaffID),
    CHECK (DueDate >= LoanDate) -- CHECK constraint
);

-- Reservations
CREATE TABLE IF NOT EXISTS astana_library.Reservations (
    ReservationID SERIAL PRIMARY KEY,
    BorrowerID INT NOT NULL,
    BookID INT NOT NULL,
    ReservationDate DATE DEFAULT CURRENT_DATE NOT NULL,
    FOREIGN KEY (BorrowerID) REFERENCES astana_library.Borrowers(BorrowerID),
    FOREIGN KEY (BookID) REFERENCES astana_library.Books(BookID)
);

-- Fines table
CREATE TABLE IF NOT EXISTS astana_library.Fines (
    FinesID SERIAL PRIMARY KEY,
    LoanID INT UNIQUE,
    FinePrice DECIMAL(10,2) CHECK (FinePrice >= 0),
    FineDate DATE NOT NULL,
    PayDue DATE,
    FOREIGN KEY (LoanID) REFERENCES astana_library.Loans(LoanID)
);


-- ALTER TABLE
-- added this constraint to make sure books can't be returned before they are borrowed.
ALTER TABLE astana_library.Loans
ADD CONSTRAINT chk_return_date
CHECK (ReturnDate IS NULL OR ReturnDate >= LoanDate);

-- this constraint was added to make sure staff can't be employed before they are born.
ALTER TABLE astana_library.LibraryStaff
ADD CONSTRAINT chk_employment_date
CHECK (EmploymentDate > Birthdate);

-- since international phone numbers can be longer than 15 characters, I changed the phone column length
ALTER TABLE astana_library.Borrowers
ALTER COLUMN Phone TYPE VARCHAR(20);

-- added a default value for PayDue so fines automatically get a due date without manual input
ALTER TABLE astana_library.Fines
ALTER COLUMN PayDue SET DEFAULT CURRENT_DATE + INTERVAL '7 days';

-- renamed this column to make its purpose clearer
ALTER TABLE astana_library.LibraryStaff
RENAME COLUMN Role TO JobTitle;


-- Truncate clean data
-- RUNCATE CASCADE is used to make sure the script can be rerun without FK conflicts
TRUNCATE TABLE 
    astana_library.Fines,
    astana_library.Loans,
    astana_library.Reservations,
    astana_library.BookCopies,
    astana_library.BookAuthors,
    astana_library.BookGenre,
    astana_library.Borrowers,
    astana_library.LibraryStaff,
    astana_library.Books,
    astana_library.Authors,
    astana_library.Genres
CASCADE;


-- INSERT DATA
-- Genres
INSERT INTO astana_library.Genres (GenreName) VALUES
('Fiction'),('Classic'),('Fantasy')
ON CONFLICT DO NOTHING;

-- Authors
INSERT INTO astana_library.Authors (FirstName, LastName) VALUES
('J.K.', 'Rowling'),
('Fyodor', 'Dostoevsky'),
('Frank', 'Herbert')
ON CONFLICT DO NOTHING;

-- Books
INSERT INTO astana_library.Books (BookName, PublicationYear, ISBN) VALUES
('Harry Potter and the Philosopher''s Stone', 1997, '1111111111111'),
('Crime and Punishment', 1866, '2222222222222'),
('Dune', 1965, '3333333333333')
ON CONFLICT DO NOTHING;

-- BookGenre
INSERT INTO astana_library.BookGenre (BookID, GenreID)
VALUES (
 (SELECT BookID FROM astana_library.Books WHERE BookName='Dune'),
 (SELECT GenreID FROM astana_library.Genres WHERE GenreName='Fantasy')
),
(
 (SELECT BookID FROM astana_library.Books WHERE BookName='Harry Potter and the Philosopher''s Stone'),
 (SELECT GenreID FROM astana_library.Genres WHERE GenreName='Fantasy')
),
(
 (SELECT BookID FROM astana_library.Books WHERE BookName='Crime and Punishment'),
 (SELECT GenreID FROM astana_library.Genres WHERE GenreName='Classic')
)
ON CONFLICT DO NOTHING;

-- BookAuthors
INSERT INTO astana_library.BookAuthors (BookID, AuthorID)
VALUES (
  (SELECT BookID FROM astana_library.Books WHERE BookName='Dune'),
  (SELECT AuthorID FROM astana_library.Authors WHERE LastName='Herbert')
),
(
 (SELECT BookID FROM astana_library.Books WHERE BookName='Harry Potter and the Philosopher''s Stone'),
 (SELECT AuthorID FROM astana_library.Authors WHERE LastName='Rowling')
),
(
 (SELECT BookID FROM astana_library.Books WHERE BookName='Crime and Punishment'),
 (SELECT AuthorID FROM astana_library.Authors WHERE LastName='Dostoevsky')
)
ON CONFLICT DO NOTHING;

-- BookCopies
INSERT INTO astana_library.BookCopies (BookID, Barcode, Shelf, Status)
VALUES
(
 (SELECT BookID FROM astana_library.Books WHERE BookName='Dune'),
 'BC001','A1','available'
),
(
 (SELECT BookID FROM astana_library.Books WHERE BookName='Harry Potter and the Philosopher''s Stone'),
 'BC002','A2','borrowed'
),
(
 (SELECT BookID FROM astana_library.Books WHERE BookName='Crime and Punishment'),
 'BC003','B1','available'
)
ON CONFLICT DO NOTHING;

-- Borrowers
INSERT INTO astana_library.Borrowers VALUES
(DEFAULT,'Amina','Adams','amina@gmail.com','1111111111','2026-02-01'),
(DEFAULT,'Ivan','Petrov','ivan@gmail.com','2222222222','2026-02-10'),
(DEFAULT,'John','Doe','john@gmail.com','3333333333','2026-03-01')
ON CONFLICT DO NOTHING;

-- LibraryStaff
INSERT INTO astana_library.LibraryStaff VALUES
(DEFAULT,'Emma','Wilson','1990-05-10','Librarian','4444444444','emma@lib.com','Street 1','2020-01-01'),
(DEFAULT,'Olga','Ivanova','1988-07-20','Assistant','5555555555','olga@lib.com','Street 2','2019-06-01'),
(DEFAULT,'Mark','Brown','1992-01-15','Assistant','6666666666','mark@lib.com','Street 3','2021-03-01')
ON CONFLICT DO NOTHING;

-- Loans
INSERT INTO astana_library.Loans (LoanDate, DueDate, ReturnDate, BorrowerID, CopyID, StaffID)
VALUES
(
 '2026-04-01','2026-04-10',NULL,
 (SELECT BorrowerID FROM astana_library.Borrowers WHERE Email='ivan@gmail.com'),
 (SELECT CopyID FROM astana_library.BookCopies WHERE Barcode='BC002'),
 (SELECT StaffID FROM astana_library.LibraryStaff WHERE Email='emma@lib.com')
),
(
 '2026-04-02','2026-04-12','2026-04-11',
 (SELECT BorrowerID FROM astana_library.Borrowers WHERE Email='amina@gmail.com'),
 (SELECT CopyID FROM astana_library.BookCopies WHERE Barcode='BC001'),
 (SELECT StaffID FROM astana_library.LibraryStaff WHERE Email='olga@lib.com')
),
(
 '2026-04-03','2026-04-13',NULL,
 (SELECT BorrowerID FROM astana_library.Borrowers WHERE Email='john@gmail.com'),
 (SELECT CopyID FROM astana_library.BookCopies WHERE Barcode='BC003'),
 (SELECT StaffID FROM astana_library.LibraryStaff WHERE Email='mark@lib.com')
)
ON CONFLICT DO NOTHING;

-- Reservations
INSERT INTO astana_library.Reservations (BorrowerID, BookID)
VALUES
(
 (SELECT BorrowerID FROM astana_library.Borrowers WHERE Email='john@gmail.com'),
 (SELECT BookID FROM astana_library.Books WHERE BookName='Dune')
),
(
 (SELECT BorrowerID FROM astana_library.Borrowers WHERE Email='amina@gmail.com'),
 (SELECT BookID FROM astana_library.Books WHERE BookName='Harry Potter')
),
(
 (SELECT BorrowerID FROM astana_library.Borrowers WHERE Email='ivan@gmail.com'),
 (SELECT BookID FROM astana_library.Books WHERE BookName='Crime and Punishment')
)
ON CONFLICT DO NOTHING;

-- Fines
INSERT INTO astana_library.Fines (LoanID, FinePrice, FineDate)
VALUES
(
 (SELECT LoanID FROM astana_library.Loans LIMIT 1),
 5.50,'2026-04-12'
),
(
 (SELECT LoanID FROM astana_library.Loans OFFSET 1 LIMIT 1),
 3.00,'2026-04-13'
),
(
 (SELECT LoanID FROM astana_library.Loans OFFSET 2 LIMIT 1),
 7.25,'2026-04-14'
)
ON CONFLICT DO NOTHING;