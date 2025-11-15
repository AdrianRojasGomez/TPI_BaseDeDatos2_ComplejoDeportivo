-- Prueba de SP dbo.sp_RegistrarSocio
USE ClubDeportivo_DB;
GO
SELECT * FROM Socio;

EXEC dbo.sp_RegistrarSocio
    @Nombre    = 'Mar�a',
    @Apellido  = 'G�mez',
    @DNI       = '10000002',
    @TipoSocio = 'Premium',
    @Direccion = 'Av. Siempre Viva 742',
    @Email     = 'maria.gomez@example.com';
GO
---------------------------------------------------------
--Prueba exitosa de SP dbo.sp_CrearReserva 
---------------------------------------------------------

EXEC dbo.sp_CrearReserva
    @IDSocio = 4,
    @IDCancha = 1,
    @IDTipoCancha = 1,
    @IDQuincho = NULL,
    @IDPileta = NULL,
    @FechaInicio = '2025-11-03 18:00:00',
    @FechaFin = '2025-11-03 19:00:00',
    @PrecioTotal = 4000.00,
    @Observ = 'Reserva de cancha Fútbol 5 para Sofía';

--Prueba de error conflicto de horariode SP dbo.sp_CrearReserva 

---------------------------------------------------------
--Intentar reservar la Cancha 1 el 3 de noviembre de 10:30 a 11:30. Esto entra en conflicto con la reserva existente de Lucas (Reserva ID 1) que es de 10:00 a 11:00.
---------------------------------------------------------   

EXEC dbo.sp_CrearReserva
    @IDSocio = 2, 
    @IDCancha = 1,
    @IDTipoCancha = 1,
    @FechaInicio = '2025-11-03 10:30:00',
    @FechaFin = '2025-11-03 11:30:00',
    @PrecioTotal = 4000.00;


---------------------------------------------------------
--Rankings de mas rentables
---------------------------------------------------------   
 
USE ClubDeportivo_DB;
-- Ranking de canchas entre 2025-01-01 y 2025-12-31
EXEC dbo.sp_RankingRecursosMasRentables
    @FechaDesde  = '2025-01-01',
    @FechaHasta  = '2025-12-31',
    @TipoRecurso = 'CANCHA';

-- Ranking de quinchos en todo 2025
EXEC dbo.sp_RankingRecursosMasRentables
    @FechaDesde  = '2025-01-01',
    @FechaHasta  = '2025-12-31',
    @TipoRecurso = 'QUINCHO';

-- Errores
USE ClubDeportivo_DB;

EXEC dbo.sp_RankingRecursosMasRentables
    @FechaDesde  = '2025-01-01',
    @FechaHasta  = '2025-12-31',
    @TipoRecurso = NULL; 


EXEC dbo.sp_RankingRecursosMasRentables
    @FechaDesde  = '2025-01-01',
    @FechaHasta  = '2025-12-31',
    @TipoRecurso = 'PILETAS';

