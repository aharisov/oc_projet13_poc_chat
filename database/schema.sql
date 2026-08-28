-- Your Car Your Way
-- MySQL 8.0+ database schema
-- This schema represents the persistent data required by the full application.
-- The chat PoC itself does not require MySQL to run.

CREATE DATABASE IF NOT EXISTS your_car_your_way
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE your_car_your_way;

CREATE TABLE users (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    birth_date DATE NULL,
    address VARCHAR(500) NULL,
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE password_reset_tokens (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    token_hash VARCHAR(255) NOT NULL,
    expires_at DATETIME(3) NOT NULL,
    used_at DATETIME(3) NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT uq_password_reset_token_hash UNIQUE (token_hash),
    CONSTRAINT fk_password_reset_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE agencies (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name VARCHAR(150) NOT NULL,
    city VARCHAR(150) NOT NULL,
    country VARCHAR(100) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id)
) ENGINE=InnoDB;

CREATE TABLE vehicle_categories (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    acriss_code VARCHAR(4) NOT NULL,
    label VARCHAR(150) NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT uq_vehicle_categories_acriss UNIQUE (acriss_code)
) ENGINE=InnoDB;

CREATE TABLE rental_offers (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    departure_agency_id BIGINT UNSIGNED NOT NULL,
    return_agency_id BIGINT UNSIGNED NOT NULL,
    category_id BIGINT UNSIGNED NOT NULL,
    start_at DATETIME(3) NOT NULL,
    end_at DATETIME(3) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'EUR',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (id),
    CONSTRAINT ck_rental_offers_dates CHECK (end_at > start_at),
    CONSTRAINT ck_rental_offers_price CHECK (price >= 0),
    CONSTRAINT fk_rental_offers_departure_agency
        FOREIGN KEY (departure_agency_id) REFERENCES agencies(id),
    CONSTRAINT fk_rental_offers_return_agency
        FOREIGN KEY (return_agency_id) REFERENCES agencies(id),
    CONSTRAINT fk_rental_offers_category
        FOREIGN KEY (category_id) REFERENCES vehicle_categories(id)
) ENGINE=InnoDB;

CREATE TABLE bookings (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    offer_id BIGINT UNSIGNED NOT NULL,
    status VARCHAR(30) NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'EUR',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT ck_bookings_status CHECK (
        status IN ('PENDING', 'CONFIRMED', 'CANCELLED', 'COMPLETED')
    ),
    CONSTRAINT ck_bookings_total_amount CHECK (total_amount >= 0),
    CONSTRAINT fk_bookings_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_bookings_offer
        FOREIGN KEY (offer_id) REFERENCES rental_offers(id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    booking_id BIGINT UNSIGNED NOT NULL,
    external_reference VARCHAR(255) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency CHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT uq_payments_external_reference UNIQUE (external_reference),
    CONSTRAINT ck_payments_amount CHECK (amount >= 0),
    CONSTRAINT ck_payments_status CHECK (
        status IN ('PENDING', 'SUCCEEDED', 'FAILED', 'REFUNDED', 'PARTIALLY_REFUNDED')
    ),
    CONSTRAINT fk_payments_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(id)
) ENGINE=InnoDB;

CREATE TABLE support_conversations (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    booking_id BIGINT UNSIGNED NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
        ON UPDATE CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT ck_support_conversations_status CHECK (
        status IN ('OPEN', 'CLOSED')
    ),
    CONSTRAINT fk_support_conversations_user
        FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_support_conversations_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(id)
        ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE support_messages (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    conversation_id BIGINT UNSIGNED NOT NULL,
    author_type VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    sent_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT ck_support_messages_author_type CHECK (
        author_type IN ('CUSTOMER', 'ADVISER', 'SYSTEM')
    ),
    CONSTRAINT fk_support_messages_conversation
        FOREIGN KEY (conversation_id) REFERENCES support_conversations(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE video_sessions (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    conversation_id BIGINT UNSIGNED NOT NULL,
    provider_room_id VARCHAR(255) NOT NULL,
    starts_at DATETIME(3) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'CREATED',
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT ck_video_sessions_status CHECK (
        status IN ('CREATED', 'STARTED', 'ENDED', 'CANCELLED')
    ),
    CONSTRAINT fk_video_sessions_conversation
        FOREIGN KEY (conversation_id) REFERENCES support_conversations(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE notifications (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    user_id BIGINT UNSIGNED NOT NULL,
    type VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    PRIMARY KEY (id),
    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_rental_offers_search
    ON rental_offers (
        departure_agency_id,
        return_agency_id,
        category_id,
        start_at,
        end_at
    );

CREATE INDEX idx_bookings_user_created
    ON bookings (user_id, created_at);

CREATE INDEX idx_password_reset_tokens_user
    ON password_reset_tokens (user_id, expires_at);

CREATE INDEX idx_support_conversations_user_created
    ON support_conversations (user_id, created_at);

CREATE INDEX idx_support_messages_conversation_sent
    ON support_messages (conversation_id, sent_at);

CREATE INDEX idx_notifications_user_created
    ON notifications (user_id, created_at);
