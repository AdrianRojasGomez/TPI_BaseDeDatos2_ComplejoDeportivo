--sp_RegistrarSocio
--Objetivo: A�adir un nuevo socio al club, asegurando que los datos b�sicos est�n presentes.
--L�gica: Recibe los datos del socio, los valida (en este caso, solo inserta) y lo registra con la fecha actual.

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

    -- Validaciones b�sicas
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

    -- DNI �nico
    IF EXISTS (SELECT 1 FROM Socio WHERE DNI = @DNI)
    BEGIN
        RAISERROR('Ya existe un socio registrado con ese DNI.', 16, 1);
        RETURN;
    END;

    -- Email �nico si viene
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

--Fin sp_RegistrarSocio

-----------------------------------------------------------------
--sp_CrearReserva
--Objetivo: Crear una nueva reserva, validando que no haya conflictos de horario con el mismo recurso.
--Logica: Esta revisa si ya existe una reserva activa para el mismo recurso (cancha, quincho o pileta) que se superponga con el horario solicitado. Si esta libre, la inserta.
-----------------------------------------------------------------

USE ClubDeportivo_DB;
GO

IF OBJECT_ID('dbo.sp_CrearReserva', 'P') IS NOT NULL
    DROP PROCEDURE dbo.sp_CrearReserva;
GO

CREATE PROCEDURE dbo.sp_CrearReserva
(
    @IDSocio       INT,
    @IDCancha      INT = NULL,
    @IDTipoCancha  INT = NULL,      
    @IDQuincho     INT = NULL,
    @IDPileta      INT = NULL,
    @FechaInicio   DATETIME,
    @FechaFin      DATETIME,
    @PrecioTotal   DECIMAL(10,2) = NULL,
    @Observ        VARCHAR(200) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    IF (@Observ IS NOT NULL)
        SET @Observ = TRIM(@Observ);

    ----------------------------------------------------------------
    -- Validar socio
    ----------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM Socio WHERE IDSocio = @IDSocio)
    BEGIN
        RAISERROR('El socio indicado no existe.', 16, 1);
        RETURN;
    END;

    ----------------------------------------------------------------
    -- Validar fechas
    ----------------------------------------------------------------
    IF (@FechaInicio IS NULL OR @FechaFin IS NULL)
    BEGIN
        RAISERROR('Las fechas de inicio y fin son obligatorias.', 16, 1);
        RETURN;
    END;

    IF (@FechaFin <= @FechaInicio)
    BEGIN
        RAISERROR('La fecha de fin debe ser mayor a la fecha de inicio.', 16, 1);
        RETURN;
    END;

    ----------------------------------------------------------------
    -- Validar seleccion Solo se puede uno
    ----------------------------------------------------------------
    DECLARE @CantidadRecursos INT =
        (CASE WHEN @IDCancha  IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN @IDQuincho IS NULL THEN 0 ELSE 1 END) +
        (CASE WHEN @IDPileta  IS NULL THEN 0 ELSE 1 END);

    IF (@CantidadRecursos = 0)
    BEGIN
        RAISERROR('Debe seleccionar al menos un recurso: cancha, quincho o pileta.', 16, 1);
        RETURN;
    END;

    IF (@CantidadRecursos > 1)
    BEGIN
        RAISERROR('La reserva solo puede asociarse a un recurso (cancha, quincho o pileta).', 16, 1);
        RETURN;
    END;

    ----------------------------------------------------------------
    -- Validar existencia
    ----------------------------------------------------------------

    -- Cancha
    IF (@IDCancha IS NOT NULL)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Cancha WHERE IDCancha = @IDCancha AND Activo = 1)
        BEGIN
            RAISERROR('La cancha indicada no existe o no está activa.', 16, 1);
            RETURN;
        END;

       
        IF (@IDTipoCancha IS NOT NULL)
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM CanchaPuente
                WHERE IDCancha = @IDCancha
                  AND IDTipoCancha = @IDTipoCancha
                  AND Habilitada = 1
            )
            BEGIN
                RAISERROR('La combinación de cancha y tipo de cancha no está habilitada.', 16, 1);
                RETURN;
            END;
        END;
    END
    ELSE
    BEGIN
        SET @IDTipoCancha = NULL;
    END;

    -- Quincho
    IF (@IDQuincho IS NOT NULL)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Quincho WHERE IDQuincho = @IDQuincho AND Activo = 1)
        BEGIN
            RAISERROR('El quincho indicado no existe o no está activo.', 16, 1);
            RETURN;
        END;
    END;

    -- Pileta
    IF (@IDPileta IS NOT NULL)
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Pileta WHERE IDPileta = @IDPileta AND Activo = 1)
        BEGIN
            RAISERROR('La pileta indicada no existe o no está activa.', 16, 1);
            RETURN;
        END;
    END;

    -- Cancha
    IF (@IDCancha IS NOT NULL)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM Reserva
            WHERE IDCancha = @IDCancha
              AND Estado = 'Activa'
              AND FechaInicio < @FechaFin
              AND FechaFin > @FechaInicio
        )
        BEGIN
            RAISERROR('La cancha seleccionada ya tiene una reserva activa en el horario indicado.', 16, 1);
            RETURN;
        END;
    END;

    -- Quincho
    IF (@IDQuincho IS NOT NULL)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM Reserva
            WHERE IDQuincho = @IDQuincho
              AND Estado = 'Activa'
              AND FechaInicio < @FechaFin
              AND FechaFin > @FechaInicio
        )
        BEGIN
            RAISERROR('El quincho seleccionado ya tiene una reserva activa en el horario indicado.', 16, 1);
            RETURN;
        END;
    END;

    -- Pileta
    IF (@IDPileta IS NOT NULL)
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM Reserva
            WHERE IDPileta = @IDPileta
              AND Estado = 'Activa'
              AND FechaInicio < @FechaFin
              AND FechaFin > @FechaInicio
        )
        BEGIN
            RAISERROR('La pileta seleccionada ya tiene una reserva activa en el horario indicado.', 16, 1);
            RETURN;
        END;
    END;

    ----------------------------------------------------------------
    -- Insertar reserva (Estado usa default 'Activa')
    ----------------------------------------------------------------
    INSERT INTO Reserva
    (
        IDSocio,
        IDCancha,
        IDTipoCancha,
        IDQuincho,
        IDPileta,
        FechaInicio,
        FechaFin,
        PrecioTotal,
        Observ
    )
    VALUES
    (
        @IDSocio,
        @IDCancha,
        @IDTipoCancha,
        @IDQuincho,
        @IDPileta,
        @FechaInicio,
        @FechaFin,
        @PrecioTotal,
        @Observ
    );

    SELECT SCOPE_IDENTITY() AS IDReservaCreada;
END;
GO

--FIN sp_CrearReserva