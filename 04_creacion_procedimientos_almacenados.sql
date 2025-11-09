USE ClubDeportivo_DB;
GO

IF OBJECT_ID('dbo.sp_RegistrarSocio', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_RegistrarSocio;
GO

CREATE PROCEDURE dbo.sp_RegistrarSocio
(
    @Nombre      VARCHAR(50),
    @Apellido    VARCHAR(50),
    @DNI         CHAR(8),
    @TipoSocio   VARCHAR(50),
    @Direccion   VARCHAR(150) = NULL,
    @Email       VARCHAR(100) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Normalizo espacios (TRIM quita al inicio y al final)
    SET @Nombre    = TRIM(@Nombre);
    SET @Apellido  = TRIM(@Apellido);
    SET @DNI       = TRIM(@DNI);
    SET @TipoSocio = TRIM(@TipoSocio);

    IF (@Direccion IS NOT NULL)
        SET @Direccion = TRIM(@Direccion);

    IF (@Email IS NOT NULL)
        SET @Email = TRIM(@Email);

    -- Validaciones básicas
    IF (@Nombre = '' OR @Nombre IS NULL)
    BEGIN
        RAISERROR('El nombre es obligatorio.', 16, 1);
        RETURN;
    END;

    IF (@Apellido = '' OR @Apellido IS NULL)
    BEGIN
        RAISERROR('El apellido es obligatorio.', 16, 1);
        RETURN;
    END;

    IF (@DNI IS NULL OR @DNI = '')
    BEGIN
        RAISERROR('El DNI es obligatorio.', 16, 1);
        RETURN;
    END;

    IF (LEN(@DNI) <> 8)
    BEGIN
        RAISERROR('El DNI debe tener 8 caracteres.', 16, 1);
        RETURN;
    END;

    IF (@TipoSocio IS NULL OR @TipoSocio = '')
    BEGIN
        RAISERROR('El TipoSocio es obligatorio.', 16, 1);
        RETURN;
    END;

    -- DNI único
    IF EXISTS (SELECT 1 FROM Socio WHERE DNI = @DNI)
    BEGIN
        RAISERROR('Ya existe un socio registrado con ese DNI.', 16, 1);
        RETURN;
    END;

    -- Email único si viene
    IF (@Email IS NOT NULL AND @Email <> '')
       AND EXISTS (SELECT 1 FROM Socio WHERE Email = @Email)
    BEGIN
        RAISERROR('Ya existe un socio registrado con ese Email.', 16, 1);
        RETURN;
    END;

    -- Insert (FechaAlta usa el DEFAULT GETDATE() de la tabla)
    INSERT INTO Socio (Nombre, Apellido, DNI, Direccion, Email, TipoSocio)
    VALUES (@Nombre, @Apellido, @DNI, @Direccion, @Email, @TipoSocio);

    -- Devuelvo el ID generado
    SELECT SCOPE_IDENTITY() AS IDSocioCreado;
END;
GO
