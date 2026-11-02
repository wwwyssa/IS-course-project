\c booking_db;

INSERT INTO pets (owner_id, name, species, gender, characteristics, birthday) VALUES
(1, 'Барсик', 'Кошка', 'Male', 'Спокойный, привит', '2022-05-10'),
(1, 'Рекс', 'Собака', 'Male', 'Активный, любит играть', '2021-08-15');

INSERT INTO room_categories (name, price_per_day) VALUES
('Стандарт для кошек', 1500.00),
('Люкс для собак', 3500.00);

INSERT INTO rooms (category_id, room_number, is_available) VALUES
(1, 'C-101', TRUE),
(2, 'D-201', TRUE);

INSERT INTO bookings (pet_id, room_id, start_date, end_date, status, total_amount, time_pay) VALUES
(1, 1, '2026-06-01', '2026-06-07', 'CONFIRMED', 10500.00, '2026-05-20 12:00:00');

INSERT INTO services (name, price) VALUES
('Индивидуальный рацион', 300.00),
('Ежедневный груминг', 800.00);

INSERT INTO booking_services (booking_id, service_id, quantity) VALUES
(1, 1, 6),
(1, 2, 2);
