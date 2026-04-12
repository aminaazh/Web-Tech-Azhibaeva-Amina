CREATE TABLE if not exists users (
    userID SERIAL PRIMARY KEY,
	username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    subscription_type VARCHAR(20) NOT null
    	CHECK (subscription_type IN ('free', 'premium', 'family', 'student')),
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
        CHECK (created_at >= '2026-01-01')
        );

CREATE table if not exists artists (
    artistID SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    country VARCHAR(100) NOT NULL,
    debut_date DATE NOT NULL
    	CHECK (debut_date >= '2026-01-01'),
    active BOOLEAN NOT NULL DEFAULT true
    );

CREATE TABLE if not exists songs (
    songID SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    artistID INT NOT NULL,
    duration_seconds INT NOT NULL
        CHECK (duration_seconds >= 0),
    release_date DATE NOT NULL
        CHECK (release_date >= '2026-01-01'),
    play_count INT DEFAULT 0
        CHECK (play_count >= 0),
    FOREIGN KEY (artistID) REFERENCES artists(artistID)
    );

CREATE TABLE if not exists playlists (
    playlistID SERIAL PRIMARY KEY,
    userID INT NOT NULL,
    songID INT NOT NULL,
    playlist_name VARCHAR(100) NOT NULL,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
        CHECK (created_at >= '2026-01-01'),
    is_public BOOLEAN NOT NULL DEFAULT true,
    FOREIGN KEY (userID) REFERENCES users(userID),
    FOREIGN KEY (songID) REFERENCES songs(songID)
    );


INSERT INTO users (username, email, subscription_type, created_at) VALUES
('helloimalice', 'alice@example.com', 'premium', '2026-01-10'),
('bob228', 'bobby@example.com', 'free', '2026-02-15'),
('charlie99', 'charlie@example.com', 'premium', '2026-03-01'),
('coolperson', 'verycool123@example.com', 'student', '2026-03-21'),
('dianalove', 'dian4@example.com', 'family', '2026-04-05');

INSERT INTO artists (name, country, debut_date, active) VALUES
('Seibiant', 'Spain', '2026-01-14', true),
('LATENCY', 'South Korea', '2026-01-08', true),
('The Waves', 'Canada', '2026-03-10', true),
('Raindrop', 'UK', '2026-02-21', true),
('Electro Beat', 'Germany', '2026-04-01', false);

INSERT INTO songs (title, artistID, duration_seconds, release_date, play_count) VALUES
('Leave No Light', 1, 122, '2026-03-28', 100),
('It Was Love', 2, 186, '2026-01-08', 250),
('Journey', 3, 240, '2026-03-15', 75),
('Fade To Black', 4, 247, '2026-02-24', 100),
('Electric Pulse', 5, 200, '2026-04-02', 300);

INSERT INTO playlists (userID, songID, playlist_name, created_at, is_public) VALUES
(1, 1, 'Chilling', '2026-01-15', true),
(2, 2, 'Party Time', '2026-02-18', true),
(3, 3, 'Morning Playlist', '2026-03-20', false),
(4, 4, 'Grieving', '2026-03-02', false),
(5, 5, 'Gaming', '2026-04-06', true);


-- INSERT INTO songs (title, artistID, duration_seconds, release_date, play_count)
-- VALUES ('Ride', 1, 202, '2025-12-31', 50);
-- error: new row for relation "songs" violates check constraint on release_date