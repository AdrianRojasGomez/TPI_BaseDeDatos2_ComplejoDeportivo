CREATE DATABASE ClubDeportivo_DB;
GO
USE ClubDeportivo_DB;
GO

CREATE TABLE Socio (
    IDSocio     INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    Apellido    VARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    DNI         CHAR(8) COLLATE Latin1_General_CI_AS NOT NULL UNIQUE,
    Direccion   VARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
    Email       VARCHAR(100) COLLATE Latin1_General_CI_AS NULL UNIQUE,
    TipoSocio   VARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    FechaAlta   DATE NOT NULL DEFAULT GETDATE(),
    FechaBaja   DATE NULL
);

CREATE TABLE Deporte (
    IDDeporte INT IDENTITY(1,1) PRIMARY KEY,
    Nombre    VARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL UNIQUE
);

CREATE TABLE Cancha (
    IDCancha     INT IDENTITY(1,1) PRIMARY KEY,
    NumeroCancha INT NOT NULL UNIQUE,
    Cubierta     BIT NOT NULL DEFAULT 0,
    Activo       BIT NOT NULL DEFAULT 1
);

CREATE TABLE TipoCancha (
    IDTipoCancha INT IDENTITY(1,1) PRIMARY KEY,
    IDDeporte    INT NOT NULL,
    Modelo       VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    Superficie   VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT FK_TipoCancha_Deporte FOREIGN KEY (IDDeporte) REFERENCES Deporte(IDDeporte)
);

CREATE TABLE CanchaPuente (
    IDCanchaPuente INT IDENTITY(1,1) PRIMARY KEY,
    IDCancha       INT NOT NULL,
    IDTipoCancha   INT NOT NULL,
    Habilitada     BIT NOT NULL DEFAULT 1,
    PrecioHora     DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_CanchaPuente_Cancha FOREIGN KEY (IDCancha) REFERENCES Cancha(IDCancha),
    CONSTRAINT FK_CanchaPuente_TipoCancha FOREIGN KEY (IDTipoCancha) REFERENCES TipoCancha(IDTipoCancha),
    CONSTRAINT UQ_Cancha_Tipo UNIQUE (IDCancha, IDTipoCancha)
);

CREATE TABLE Quincho (
    IDQuincho     INT IDENTITY(1,1) PRIMARY KEY,
    NumeroQuincho INT NOT NULL UNIQUE,
    Activo        BIT NOT NULL DEFAULT 1,
    Sector        VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    EsExclusivo   BIT NOT NULL DEFAULT 0
);

CREATE TABLE Pileta (
    IDPileta      INT IDENTITY(1,1) PRIMARY KEY,
    NumeroPileta  INT NOT NULL UNIQUE,
    Activo        BIT NOT NULL DEFAULT 1,
    Sector        VARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    EsExclusivo   BIT NOT NULL DEFAULT 1
);

CREATE TABLE Reserva (
    IDReserva     INT IDENTITY(1,1) PRIMARY KEY,
    IDSocio       INT NOT NULL,
    IDCancha      INT NULL,
    IDTipoCancha  INT NULL,
    IDQuincho     INT NULL,
    IDPileta      INT NULL,
    FechaInicio   DATETIME NOT NULL,
    FechaFin      DATETIME NOT NULL,
    PrecioTotal   DECIMAL(10,2) NULL,
    Estado        VARCHAR(20) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT 'Activa',
    Observ        VARCHAR(200) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT CK_Reserva_Alguno CHECK (
        (IDCancha IS NOT NULL) OR (IDQuincho IS NOT NULL) OR (IDPileta IS NOT NULL)
    ),
    CONSTRAINT CK_Reserva_Rango CHECK (FechaFin > FechaInicio),
    CONSTRAINT FK_Reserva_Socio       FOREIGN KEY (IDSocio)      REFERENCES Socio(IDSocio),
    CONSTRAINT FK_Reserva_Cancha      FOREIGN KEY (IDCancha)     REFERENCES Cancha(IDCancha),
    CONSTRAINT FK_Reserva_TipoCancha  FOREIGN KEY (IDTipoCancha) REFERENCES TipoCancha(IDTipoCancha),
    CONSTRAINT FK_Reserva_Quincho     FOREIGN KEY (IDQuincho)    REFERENCES Quincho(IDQuincho),
    CONSTRAINT FK_Reserva_Pileta      FOREIGN KEY (IDPileta)     REFERENCES Pileta(IDPileta)
);
