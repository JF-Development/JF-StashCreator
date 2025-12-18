CREATE TABLE IF NOT EXISTS stash_creator (
    id INT AUTO_INCREMENT PRIMARY KEY,
    stash_id VARCHAR(100) UNIQUE,
    label VARCHAR(100),
    slots INT,
    weight INT,
    password VARCHAR(100),
    required_item VARCHAR(100),
    job VARCHAR(50),
    gang VARCHAR(50),
    citizenid VARCHAR(50),
    coords LONGTEXT,
    heading FLOAT DEFAULT 0
);
