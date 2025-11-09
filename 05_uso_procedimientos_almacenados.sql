-- Prueba de SP dbo.sp_RegistrarSocio
SELECT * FROM Socio;

EXEC dbo.sp_RegistrarSocio
    @Nombre    = 'María',
    @Apellido  = 'Gómez',
    @DNI       = '10000002',
    @TipoSocio = 'Premium',
    @Direccion = 'Av. Siempre Viva 742',
    @Email     = 'maria.gomez@example.com';
GO