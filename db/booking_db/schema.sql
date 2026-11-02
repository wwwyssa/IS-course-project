CREATE DATABASE booking_db;
\c booking_db;

CREATE TABLE pets (
    pet_id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL, -- Logical FK -> auth_db.persons(user_id)
    name VARCHAR(100) NOT NULL,
    species VARCHAR(50) NOT NULL,
    breed VARCHAR(100),
    gender VARCHAR(8) CHECK (gender IN ('Male', 'Female')),
    characteristics TEXT,
    birthday DATE
);

CREATE TABLE room_categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price_per_day DECIMAL(10, 2) NOT NULL CHECK (price_per_day >= 0)
);

CREATE TABLE rooms (
    room_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES room_categories(category_id) ON DELETE RESTRICT,
    room_number VARCHAR(20) UNIQUE NOT NULL,
    is_available BOOLEAN DEFAULT TRUE
);

CREATE TABLE bookings (
    booking_id SERIAL PRIMARY KEY,
    pet_id INT NOT NULL, -- Logical FK -> pets(pet_id)
    room_id INT NOT NULL REFERENCES rooms(room_id) ON DELETE RESTRICT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'CREATED',
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    time_pay TIMESTAMP,
    CONSTRAINT check_dates CHECK (end_date > start_date)
);

CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0)
);

CREATE TABLE booking_services (
    booking_id INT NOT NULL REFERENCES bookings(booking_id) ON DELETE CASCADE,
    service_id INT NOT NULL REFERENCES services(service_id) ON DELETE CASCADE,
    quantity INT NOT NULL DEFAULT 1 CHECK (quantity > 0),
    PRIMARY KEY (booking_id, service_id)
);

-- Функция и триггер для предотвращения пересечения дат бронирования
CREATE OR REPLACE FUNCTION check_room_booking_overlap()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1 FROM bookings
        WHERE room_id = NEW.room_id
          AND booking_id <> COALESCE(NEW.booking_id, -1)
          AND status NOT IN ('CANCELLED', 'REJECTED')
          AND (NEW.start_date < end_date AND NEW.end_date > start_date)
    ) THEN
        RAISE EXCEPTION 'Номер уже забронирован на выбранные даты!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_booking_overlap
    BEFORE INSERT OR UPDATE ON bookings
    FOR EACH ROW
    EXECUTE FUNCTION check_room_booking_overlap();
