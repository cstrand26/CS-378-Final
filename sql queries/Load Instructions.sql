use `soccer1`;

CREATE TABLE `Organizations` (
    `Code` varchar(8) NOT NULL,
	`Sup_Code` varchar(8), -- foreign key to create heirachy in Organizations table
    `Name` varchar(255) NOT NULL,
    PRIMARY KEY (`Code`)
);
CREATE TABLE `Tournament Types` (
    `Type_ID` varchar(9) NOT NULL,
    `Org_Code` varchar(8) NOT NULL, -- foreign key from Organizations table
    `Name` varchar(255) NOT NULL,
    PRIMARY KEY (`Type_ID`)
);
CREATE TABLE `Tournaments` (
    `Tournament_ID` int NOT NULL,
    `Year` int NOT NULL,
    `Type_ID` varchar(9) NOT NULL, -- foreign key from Tournament Types table
    `Host_Team` varchar(3) NOT NULL, -- foreign key from Teams table
    PRIMARY KEY (`Tournament_ID`)
);
CREATE TABLE `Teams` (
    `FIFA_Code` varchar(3) NOT NULL,
    `Country` varchar(255) NOT NULL,
    `Official_FIFA_Name` varchar(255),
    `Nickname` varchar(255),
    `Association` varchar(255),
	`Org_Code` varchar(8) NOT NULL, -- foreign key from Organizations table
    `Year_Founded` int,
    PRIMARY KEY (`FIFA_Code`)
);
CREATE TABLE `Rounds` (
	`Round_ID` int NOT NULL,
    `Name` varchar(30) NOT NULL,
    PRIMARY KEY (`Round_ID`)
);
CREATE TABLE `Match Results` (
	`ID` int NOT NULL Auto_increment, -- to assign id numbers to each match
	`Tournament_ID` int NOT NULL, -- foreign key from Tournaments table
    `Round_ID` int NOT NULL, -- foreign key from Rounds table
    `Penalty_Win` int,
    `Year` int NOT NULL,
    `Month` int NOT NULL,
    `Day` int NOT NULL,
    `Team_Code1` varchar(3) NOT NULL, -- foreign key from Teams table
    `Score1` int NOT NULL,
    `Score2` int NOT NULL,
    `Team_Code2` varchar(3) NOT NULL, -- foreing key from Teams table
    PRIMARY KEY (`ID`)
);
LOAD DATA INFILE 'Soccer - Match Results.csv'
INTO TABLE `Match Results`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS -- to skip the header row
(Tournament_ID, Round_ID, @Penalty_Win, Year, Month, Day, Team_Code1, Score1, Score2, Team_Code2)
SET Penalty_Win = NULLIF(@Penalty_Win, ''); -- sets to "null" if field is empty

LOAD DATA INFILE 'Soccer - Organizations.csv'
INTO TABLE `Organizations`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS -- to skip the header row
(Code, @Sup_Code, Name)
Set Sup_Code = Nullif(@Sup_Code, ''); -- sets to "null" if field is empty

LOAD DATA INFILE 'Soccer - Rounds.csv'
INTO TABLE `Rounds`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- to skip the header row

LOAD DATA INFILE 'Soccer - Teams.csv'
INTO TABLE `Teams`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- to skip the header row

LOAD DATA INFILE 'Soccer - Tournament Types.csv'
INTO TABLE `Tournament Types`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- to skip the header row

LOAD DATA INFILE 'Soccer - Tournaments.csv'
INTO TABLE `Tournaments`
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS; -- to skip the header row