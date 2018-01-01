DROP TABLE IF EXISTS games;
CREATE TABLE games (
	id          INTEGER PRIMARY KEY AUTOINCREMENT,
	date		DATE,
	league_id	TEXT,
	home_team	TEXT,
	home_score	INTEGER,
	away_team	TEXT,
	away_score	INTEGER
);
