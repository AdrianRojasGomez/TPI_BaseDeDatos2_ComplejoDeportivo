--trg_VerificarSocioActivoEnReserva
--Objetivo: Impedir a nivel de base de datos que un socio con FechaBaja pueda ser asignado a una nueva reserva.
--Evento: AFTER INSERT en la tabla Reserva.
--Lógica: Después de que se inserta una fila en Reserva, este trigger comprueba si el IDSocio de esa nueva fila tiene una FechaBaja en la tabla Socio. Si la tiene, anula la inserción.

USE ClubDeportivo_DB;
GO

IF OBJECT_ID('dbo.trg_VerificarSocioActivoEnReserva', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_VerificarSocioActivoEnReserva;
GO

CREATE TRIGGER dbo.trg_VerificarSocioActivoEnReserva
ON dbo.Reserva
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Si alguna reserva insertada pertenece a un socio dado de baja, se bloquea
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN Socio s
            ON s.IDSocio = i.IDSocio
        WHERE s.FechaBaja IS NOT NULL
    )
    BEGIN
        RAISERROR ('No se puede crear una reserva para un socio dado de baja.', 16, 1);
        ROLLBACK TRANSACTION;  -- Anula la inserción
        RETURN;
    END;
END;
GO

--trg_EvitarBorradoSocioConReservas
--Objetivo: Impedir que se elimine (DELETE) un socio si este tiene reservas históricas. La regla de negocio debería ser darlo de baja (UPDATE FechaBaja), no borrarlo.
--Evento: INSTEAD OF DELETE en la tabla Socio.
--Lógica: Este trigger "reemplaza" la acción de DELETE. En lugar de borrar al socio, verifica si tiene reservas. Si tiene, lo impide. Si no tiene, se podría permitir el borrado, aunque lo más seguro es forzar siempre la baja lógica.

USE ClubDeportivo_DB;
GO

IF OBJECT_ID('dbo.trg_EvitarBorradoSocioConReservas', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_EvitarBorradoSocioConReservas;
GO

CREATE TRIGGER dbo.trg_EvitarBorradoSocioConReservas
ON dbo.Socio
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Regla aplicada:
        - No se permite borrar físicamente socios.
        - Cualquier intento de DELETE se transforma en baja lógica (FechaBaja).
        - Si ya tenían FechaBaja, se deja como está.
    */

    -- Marca FechaBaja sólo donde aún no esté seteada
    UPDATE S
    SET FechaBaja = ISNULL(S.FechaBaja, CONVERT(date, GETDATE()))
    FROM Socio S
    INNER JOIN deleted D
        ON S.IDSocio = D.IDSocio;

    -- Mensaje informativo (no hace rollback)
    RAISERROR('No se permite eliminar socios. Se aplicó baja lógica (FechaBaja) en su lugar.', 10, 1);
END;
GO

USE ClubDeportivo_DB;
GO

IF OBJECT_ID('dbo.trg_PrevenirModificacionReservaPasada', 'TR') IS NOT NULL
    DROP TRIGGER dbo.trg_PrevenirModificacionReservaPasada;
GO

CREATE TRIGGER dbo.trg_PrevenirModificacionReservaPasada
ON dbo.Reserva
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    /*
        Regla:
        - Si una reserva ya estaba finalizada (FechaFin anterior < GETDATE()),
          no se permite modificarla.
        - Si el UPDATE afecta varias filas y al menos una es histórica,
          se revierte TODO el UPDATE.
    */

    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.FechaFin < GETDATE()
    )
    BEGIN
        RAISERROR('No se permite modificar reservas que ya han finalizado.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO
