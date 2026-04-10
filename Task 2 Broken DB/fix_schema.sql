CREATE TABLE Members (
    id          SERIAL        PRIMARY KEY,
    username    VARCHAR(30),                       -- ❌ Missing NOT NULL and UNIQUE
    email       VARCHAR(100),                      -- ❌ Missing NOT NULL and UNIQUE
    joined_date DATE          NOT NULL,
    is_active   BOOLEAN                            -- ❌ Missing DEFAULT true
);

CREATE TABLE Books (
    id          SERIAL        PRIMARY KEY,
    title       VARCHAR(150)  NOT NULL,
    author      VARCHAR(100),                      -- ❌ Missing NOT NULL
    year_pub    INT,                                -- ⚠️ Missing CHECK (year_pub >= 0)
    owner_id    INT                                -- ❌ Missing FOREIGN KEY → Members(id)
    -- ❌ No column: condition VARCHAR(20) — needs to be added
);

CREATE TABLE Exchanges (
    id            SERIAL   PRIMARY KEY,
    book_id       INT,                               -- ❌ Missing FOREIGN KEY → Books(id)
    borrower_id   INT,                               -- ❌ Missing FOREIGN KEY → Members(id)
    exchange_date DATE,                              -- ⚠️ Missing CHECK (exchange_date >= '2026-01-01') + NOT NULL
    return_date   DATE                               -- ❌ Missing CHECK (return_date >= '2026-01-01')
    -- ❌ No column: status VARCHAR(20) — needs to be added with DEFAULT 'pending'
);

CREATE TABLE Reviews (
    id          SERIAL   PRIMARY KEY,
    book_id     INT,                               -- ❌ Missing FOREIGN KEY → Books(id)
    member_id   INT,                               -- ❌ Missing FOREIGN KEY → Members(id)
    rating      INT,                               -- ⚠️ Missing CHECK (rating BETWEEN 1 AND 5)
    review_text TEXT,                              -- ❌ Missing NOT NULL
    created_at  DATE     NOT NULL
);


-- Members
ALTER TABLE Members
ALTER COLUMN username SET NOT NULL;
ALTER TABLE Members 
ALTER COLUMN email SET NOT NULL;

ALTER TABLE Members
ADD CONSTRAINT members_username_unique UNIQUE (username);
ALTER TABLE Members
ADD CONSTRAINT members_email_unique UNIQUE (email);

ALTER TABLE Members
ALTER COLUMN is_active SET DEFAULT true;

-- Books
ALTER TABLE Books 
ALTER COLUMN author SET NOT NULL;

ALTER TABLE Books 
ADD CONSTRAINT books_year_check CHECK (year_pub >= 0);

ALTER TABLE Books 
ADD COLUMN condition TEXT NOT NULL DEFAULT 'good';
ALTER TABLE Books
ALTER COLUMN condition TYPE VARCHAR(30);

ALTER TABLE Books ADD CONSTRAINT books_owner_fk FOREIGN KEY (owner_id) REFERENCES Members(id);

-- Exchanges
ALTER TABLE Exchanges 
ALTER COLUMN exchange_date SET NOT NULL;

ALTER TABLE Exchanges 
ADD CONSTRAINT exchanges_exchange_date_check CHECK (exchange_date >= DATE '2026-01-01');
ALTER TABLE Exchanges 
ADD CONSTRAINT exchanges_return_date_check CHECK (return_date >= DATE '2026-01-01');

ALTER TABLE Exchanges 
ADD COLUMN status VARCHAR(20) DEFAULT 'pending';

ALTER TABLE Exchanges ADD CONSTRAINT exchanges_book_fk FOREIGN KEY (book_id) REFERENCES Books(id);
ALTER TABLE Exchanges ADD CONSTRAINT exchanges_borrower_fk FOREIGN KEY (borrower_id) REFERENCES Members(id);

-- Reviews
ALTER TABLE Reviews 
ALTER COLUMN review_text SET NOT NULL;

ALTER TABLE Reviews 
ADD CONSTRAINT reviews_rating_check CHECK (rating BETWEEN 1 AND 5);

ALTER TABLE Reviews ADD CONSTRAINT reviews_book_fk FOREIGN KEY (book_id) REFERENCES Books(id);
ALTER TABLE Reviews ADD CONSTRAINT reviews_member_fk FOREIGN KEY (member_id) REFERENCES Members(id);


-- Drop Constraint
ALTER TABLE Books
DROP CONSTRAINT books_owner_fk;
-- Re adding constraint with same name
ALTER TABLE Books
ADD CONSTRAINT books_owner_fk
FOREIGN KEY (owner_id) REFERENCES Members(id);
-- comment: Naming constraints is important because PostgreSQL generates random names. if not specified, making them difficult to reference when dropping later.

-- Sample data
-- Members
INSERT INTO Members (username, email, joined_date)
VALUES
('nova_reader', 'novaread@example.com', '2026-01-08'),
('coolwizard', 'wizard@example.com', '2026-02-12'),
('luna_page', 'luna.pages@example.com', '2026-02-25'),
('thebookdude', 'bookslove@example.com', '2026-03-02');

-- Books
INSERT INTO Books (title, author, year_pub, owner_id)
VALUES
('To Kill a Mockingbird', 'Harper Lee', 1960, 1),
('1984', 'George Orwell', 1949, 2),
('The Great Gatsby', 'F. Scott Fitzgerald', 1925, 3),
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 1997, 4);

-- Exchanges
INSERT INTO Exchanges (book_id, borrower_id, exchange_date, return_date)
VALUES
(1, 2, '2026-02-01', '2026-02-09'),
(2, 3, '2026-03-03', '2026-03-18'),
(3, 1, '2026-03-10', '2026-03-20'),
(4, 2, '2026-03-22', NULL);

-- Reviews
INSERT INTO Reviews (book_id, member_id, rating, review_text, created_at)
VALUES
(1, 2, 5, 'A timeless classic with powerful themes.', '2026-02-10'),
(2, 3, 5, 'Chilling and thought-provoking. Still relevant today.', '2026-03-19'),
(3, 1, 4, 'Beautifully written love it.', '2026-03-21'),
(4, 2, 5, 'Such a cool book wow!', '2026-03-25');


-- Error
INSERT INTO Members (username, email, joined_date)
VALUES ('nova_reader', 'novaread@example.com', '2026-01-08');
-- SQL Error [23505]: ОШИБКА: повторяющееся значение ключа нарушает ограничение уникальности "members_username_unique"
-- Подробности: Ключ "(username)=(nova_reader)" уже существует.
