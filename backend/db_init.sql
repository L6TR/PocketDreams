CREATE DATABASE pocket_dreams;
CREATE USER 'dream_user'@'localhost' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON pocket_dreams.* TO 'dream_user'@'localhost';
FLUSH PRIVILEGES;

USE pocket_dreams;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255),
    password VARCHAR(255)
);
