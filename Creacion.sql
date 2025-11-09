INSERT INTO Socio (Nombre, Apellido, DNI, Direccion, Email, TipoSocio, FechaAlta)
VALUES
('Lucas', 'Fernandez', '40123456', 'Av. San Martín 123', 'lucasf@gmail.com', 'Titular', GETDATE()),
('María', 'Gómez', '39222111', 'Belgrano 450', 'mariag@gmail.com', 'Titular', GETDATE()),
('Javier', 'Pérez', '38011222', 'Italia 78', 'javierp@gmail.com', 'Familiar', GETDATE()),
('Sofía', 'Ruiz', '40222333', 'Mitre 800', 'sofiar@gmail.com', 'Titular', GETDATE()),
('Carla', 'Benítez', '39555666', 'Sarmiento 1200', 'carlab@gmail.com', 'Familiar', GETDATE());

-- ======================
-- 2?? DEPORTE
-- ======================
INSERT INTO Deporte (Nombre)
VALUES
('Fútbol'),
('Tenis'),
('Pádel'),
('Natación'),
('Básquet');

-- ======================
-- 3?? CANCHA
-- ======================
INSERT INTO Cancha (NumeroCancha, Cubierta, Activo)
VALUES
(1, 0, 1),
(2, 1, 1),
(3, 0, 1),
(4, 1, 1),
(5, 0, 1);

-- ======================
-- 4?? TIPO CANCHA
-- ======================
INSERT INTO TipoCancha (IDDeporte, Modelo, Superficie)
VALUES
(1, '5 jugadores', 'Césped sintético'),
(1, '11 jugadores', 'Césped natural'),
(2, 'Individual', 'Polvo de ladrillo'),
(3, 'Doble', 'Cemento'),
(5, 'Profesional', 'Madera');

-- ======================
-- 5?? CANCHA PUENTE
-- ======================
INSERT INTO CanchaPuente (IDCancha, IDTipoCancha, Habilitada, PrecioHora)
VALUES
(1, 1, 1, 4000.00),
(2, 2, 1, 7000.00),
(3, 3, 1, 3500.00),
(4, 4, 1, 5000.00),
(5, 5, 1, 6000.00);

-- ======================
-- 6?? QUINCHO
-- ======================
INSERT INTO Quincho (NumeroQuincho, Activo, Sector, EsExclusivo)
VALUES
(1, 1, 'Norte', 0),
(2, 1, 'Sur', 1),
(3, 1, 'Centro', 0),
(4, 1, 'Oeste', 1),
(5, 1, 'Este', 0);

-- ======================
-- 7?? PILETA
-- ======================
INSERT INTO Pileta (NumeroPileta, Activo, Sector, EsExclusivo)
VALUES
(1, 1, 'Verano', 1),
(2, 1, 'Invierno', 1),
(3, 1, 'Infantil', 0),
(4, 1, 'Recreativa', 0),
(5, 1, 'Competitiva', 1);

-- ======================
-- 8?? RESERVA
-- ======================
INSERT INTO Reserva (IDSocio, IDCancha, IDTipoCancha, IDQuincho, IDPileta, FechaInicio, FechaFin, PrecioTotal, Estado, Observ)
VALUES
(1, 1, 1, NULL, NULL, '2025-11-03 10:00', '2025-11-03 11:00', 4000, 'Activa', 'Reserva fútbol 5'),
(2, 2, 2, NULL, NULL, '2025-11-04 17:00', '2025-11-04 19:00', 14000, 'Activa', 'Fútbol 11'),
(3, NULL, NULL, 1, NULL, '2025-11-05 12:00', '2025-11-05 16:00', 8000, 'Activa', 'Cumpleaños familiar'),
(4, NULL, NULL, NULL, 2, '2025-11-06 14:00', '2025-11-06 16:00', 6000, 'Activa', 'Pileta climatizada'),
(5, 3, 3, NULL, NULL, '2025-11-07 18:00', '2025-11-07 19:30', 5250, 'Activa', 'Tenis doble');