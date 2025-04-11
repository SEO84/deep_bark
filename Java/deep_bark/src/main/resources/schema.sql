CREATE TABLE IF NOT EXISTS dog_breed (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name_en VARCHAR(255) NOT NULL,
    name_ko VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    weight VARCHAR(50),
    lifespan VARCHAR(50),
    origin VARCHAR(100),
    image_url VARCHAR(255),
    temperament TEXT
);

CREATE TABLE IF NOT EXISTS mix_dog (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name_en VARCHAR(255) NOT NULL,
    name_ko VARCHAR(255) NOT NULL,
    breed1_id BIGINT,
    breed2_id BIGINT,
    FOREIGN KEY (breed1_id) REFERENCES dog_breed(id),
    FOREIGN KEY (breed2_id) REFERENCES dog_breed(id)
); 