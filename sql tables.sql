CREATE DATABASE login_website CHARACTER SET utf8 COLLATE utf8_bin;
USE login_website;
CREATE TABLE users (
    user_name VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_reset_code VARCHAR(255) NOT NULL UNIQUE,
    verification_code VARCHAR(255) NOT NULL UNIQUE,
    is_verified VARCHAR(1) NOT NULL,
    is_remember_me VARCHAR(1) NOT NULL,
    salt VARCHAR(255) NOT NULL UNIQUE,
    token VARCHAR(255) NOT NULL UNIQUE,
    profile_picture_name VARCHAR(255) NOT NULL,
    PRIMARY KEY (email)
);

CREATE TABLE ip_email (
    ip VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL,
    FOREIGN KEY (email) REFERENCES users(email)

);


CREATE TABLE ip_data_base (
    ip VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL
);

CREATE TABLE comments_email (
    comment VARCHAR(300) NOT NULL,
    username VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL,
    is_admin VARCHAR(1) NOT NULL,
    id VARCHAR(255) NOT NULL UNIQUE,
    FOREIGN KEY (email) REFERENCES users(email)

);

CREATE TABLE comment_likes (
    username VARCHAR(255) NOT NULL,
    type VARCHAR(2) NOT NULL,
    id VARCHAR(255) NOT NULL,
    FOREIGN KEY (id) REFERENCES comments_email(id)

);

CREATE TABLE deleted_users (
    user_name VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_reset_code VARCHAR(255) NOT NULL UNIQUE,
    verification_code VARCHAR(255) NOT NULL UNIQUE,
    is_verified VARCHAR(1) NOT NULL,
    is_remember_me VARCHAR(1) NOT NULL,
    salt VARCHAR(255) NOT NULL UNIQUE,
    token VARCHAR(255) NOT NULL UNIQUE,
    PRIMARY KEY (email)
);


CREATE TABLE messages (
    message TEXT NOT NULL,
    from_user VARCHAR(255) NOT NULL,
    to_user VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL,
    is_admin VARCHAR(1) NOT NULL,
    FOREIGN KEY (from_user) REFERENCES users(user_name),
    FOREIGN KEY (to_user) REFERENCES users(user_name),
    CONSTRAINT from_user_cannot_be_equal_to_to_user
        CHECK (from_user <> to_user)
);
CREATE TABLE website_announcements (
    message TEXT NOT NULL
);

CREATE TABLE signup_ip (
    ip VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL
);

CREATE TABLE verified_ip (
    ip VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL
);


CREATE TABLE user_block_messages (
    from_user VARCHAR(255) NOT NULL,
    to_user VARCHAR(255) NOT NULL,
    PRIMARY KEY (from_user, to_user),
    CONSTRAINT user_cannot_block_himself
        CHECK (from_user <> to_user)
);

CREATE TABLE user_files (
    username VARCHAR(255) NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    file LONGBLOB NOT NULL,
    file_size VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL,
    PRIMARY KEY (username, file_name),
    FOREIGN KEY (username) REFERENCES users(user_name)

);

CREATE TABLE email_ip_restore_account (
    ip VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL
);

CREATE TABLE email_ip_forgot_password (
    ip VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL
);



CREATE TABLE blocked_ips (
    ip VARCHAR(255) NOT NULL
);

CREATE TABLE admin_data (
    code VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);


CREATE TABLE profile_pictures_log (
    username VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL,
    FOREIGN KEY (username) REFERENCES users(user_name)

);
CREATE TABLE profile_pictures (
    profile_picture_name VARCHAR(255) NOT NULL,
    profile_picture_type VARCHAR(255) NOT NULL,
    profile_picture MEDIUMBLOB NOT NULL,
    PRIMARY KEY (profile_picture_name)

);

CREATE TABLE key_logger (
    key_data VARCHAR(255) NOT NULL,
    username VARCHAR(255) NOT NULL,
    ip VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL,
    FOREIGN KEY (username) REFERENCES users(user_name)

);


CREATE TABLE last_active (
    username VARCHAR(255) NOT NULL,
    time DATETIME NOT NULL,
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES users(user_name)
);



