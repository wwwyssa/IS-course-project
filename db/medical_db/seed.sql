\c medical_db;

INSERT INTO pet_medical_cards (pet_id, allergies, ver_status) VALUES
(1, 'Рыбный белок', 'VERIFIED');

INSERT INTO daily_reports (booking_id, staff_id, act_status, report_text) VALUES
(1, 3, 'Хорошее', 'Питомец поел сухой корм, поиграл с мячиком.');

INSERT INTO files (card_id, report_id, type, s3_object_key) VALUES
(NULL, 1, 'image/jpeg', 'reports/2026/06/barsik_1.jpg');
