CREATE TABLE Branches(
    name    TEXT,
    program TEXT,
    PRIMARY KEY (name, program)
);

CREATE TABLE Students(
    idnr    TEXT PRIMARY KEY,
    name    TEXT,
    login   TEXT UNIQUE,
    program TEXT
);