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

-- Полная стоимость проживания и дополнительных услуг.
CREATE OR REPLACE FUNCTION calculate_booking_cost(p_booking_id INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    v_days INT;
    v_room_price DECIMAL(10, 2);
    v_services_cost DECIMAL(10, 2) := 0;
    v_total DECIMAL(10, 2);
BEGIN
    -- Длительность проживания в ночах.
    SELECT b.end_date - b.start_date, rc.price_per_day
    INTO v_days, v_room_price
    FROM bookings b
    JOIN rooms r ON b.room_id = r.room_id
    JOIN room_categories rc ON r.category_id = rc.category_id
    WHERE b.booking_id = p_booking_id;

    IF v_days IS NULL OR v_days <= 0 THEN
        RAISE EXCEPTION 'Бронирование не найдено или период бронирования некорректен';
    END IF;

    -- Стоимость дополнительных услуг.
    SELECT COALESCE(SUM(s.price * bs.quantity), 0)
    INTO v_services_cost
    FROM booking_services bs
    JOIN services s ON bs.service_id = s.service_id
    WHERE bs.booking_id = p_booking_id;

    -- Итоговая стоимость.
    v_total := (v_days * v_room_price) + v_services_cost;
    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- Поиск доступных номеров выбранной категории на заданный период.
CREATE OR REPLACE FUNCTION get_available_rooms(
    p_category_id INT,
    p_start_date DATE,
    p_end_date DATE
)
RETURNS TABLE (
    room_id INT,
    room_number VARCHAR,
    price_per_day DECIMAL
) AS $$
BEGIN
    IF p_start_date IS NULL OR p_end_date IS NULL OR p_end_date <= p_start_date THEN
        RAISE EXCEPTION 'Некорректный период бронирования';
    END IF;

    RETURN QUERY
    SELECT r.room_id, r.room_number, rc.price_per_day
    FROM rooms r
    JOIN room_categories rc ON r.category_id = rc.category_id
    WHERE r.category_id = p_category_id
      AND r.is_available = TRUE
      AND NOT EXISTS (
          SELECT 1
          FROM bookings b
          WHERE b.room_id = r.room_id
            AND b.status NOT IN ('CANCELLED', 'REJECTED')
            AND p_start_date < b.end_date
            AND p_end_date > b.start_date
      );
END;
$$ LANGUAGE plpgsql;
