\c booking_db;

CREATE INDEX idx_bookings_room_dates ON bookings (room_id, start_date, end_date);
