select *from Socio
select *from Reserva
select *from Cancha
select *from TipoCancha

--Vista: VW_SociosActivos
--Crear una vista que muestre todos los socios activos del club, es decir, aquellos que no registran fecha de baja.
--La vista debe incluir los datos principales del socio: ID, nombre, apellido, DNI, dirección, correo electrónico, tipo de socio y fecha de alta.
--El objetivo es facilitar la consulta rápida de socios vigentes para el área administrativa.

--Objetivo práctico:
--Permitir al personal del club listar socios activos sin tener que filtrar manualmente.
create view VW_SOCIOSACTIVOS as
select s.IDSocio,s.Nombre,s.Apellido,s.DNI,s.Direccion,s.Email,s.TipoSocio,s.FechaAlta
from socio s  
where s.FechaBaja is null

 select *from VW_SOCIOSACTIVOS 

--Vista: VW_ReservasDetalladas


--Crear una vista que muestre todas las reservas realizadas por los socios, detallando 
--la información del socio y del recurso reservado (cancha, quincho o pileta).
--Debe incluir: nombre y apellido del socio, tipo de recurso reservado, número del recurso, 
--fecha y hora de inicio, fecha y hora de fin, precio total y estado de la reserva.
--La vista permitirá obtener un resumen completo de las reservas efectuadas en el club.

--Objetivo práctico:
--Brindar una herramienta para visualizar todas las reservas con sus respectivos socios y recursos.

 create view VW_RESERVASDETALLADAS as

 select s.Nombre,s.Apellido,d.Nombre as NombreCancha,c.numerocancha,q.numeroquincho,p.numeropileta,r.fechainicio,r.fechafin,r.preciototal,r.estado 
 from Socio s
 inner join Reserva r on r.IDSocio = s.IDSocio 
 LEFT  join Cancha c on c.IDCancha = r.IDCancha
 LEFT  join Quincho q on r.IDQuincho = q.IDQuincho
 LEFT  join Pileta p on  r.IDPileta = p.IDPileta
 LEFT JOIN CanchaPuente cp ON cp.IDCancha = r.IDCancha
LEFT JOIN TipoCancha tc ON tc.IDTipoCancha = cp.IDTipoCancha
LEFT JOIN Deporte d ON d.IDDeporte = tc.IDDeporte
where r.Estado = 'Activa'

select *from VW_RESERVASDETALLADAS
 
-- Vista: VW_RecaudacionPorFecha



--Crear una vista que muestre la recaudación total diaria generada por las reservas, agrupando las sumas por fecha.
--Debe incluir la fecha, la cantidad de reservas realizadas en esa fecha y el monto total recaudado.
--Esta vista servirá para generar reportes financieros y analizar el rendimiento del club.

--Objetivo práctico:
--Obtener un resumen financiero por día, semana o mes sin necesidad de cálculos manuales.

create view VW_RECAUDACIONPORFECHA as
SELECT 
    CONVERT(DATE, r.FechaInicio) AS Fecha,
    SUM(CASE WHEN r.Estado = 'Activa' THEN r.PrecioTotal ELSE 0 END) AS TotalRecaudado,
	COUNT (*) as cantidadreserva

	
FROM Reserva r
GROUP BY CONVERT(DATE, r.FechaInicio);

select *from VW_RECAUDACIONPORFECHA



-- VW_RecaudacionSemanaCompleta

-- 
-- Crear una vista que muestre la recaudación total de cada semana completa del año.
-- La vista debe incluir:
--   ▪ El año correspondiente
--   ▪ El número de semana del año
--   ▪ La fecha de inicio y la fecha de fin de esa semana
--   ▪ La cantidad de reservas activas registradas en esa semana
--   ▪ El monto total recaudado durante esa semana
--
--  Objetivo 
-- Obtener un resumen financiero semanal del club,
-- que permita analizar el rendimiento de las reservas por semana (lunes a domingo),
-- sin necesidad de realizar cálculos manuales.
-- Esta vista servirá para reportes de gestión y análisis de actividad semanal.


CREATE VIEW VW_RecaudacionSemanaCompleta
AS
SELECT
    YEAR(r.FechaInicio) AS Anio,
    DATEPART(WEEK, r.FechaInicio) AS Semana,
    MIN(CONVERT(DATE, r.FechaInicio)) AS FechaInicioSemana,
    MAX(CONVERT(DATE, r.FechaFin)) AS FechaFinSemana,
    COUNT(*) AS CantReservas,
    SUM(CASE 
            WHEN r.Estado = 'Activa' THEN r.PrecioTotal 
            ELSE 0 
        END) AS MontoRecaudado
FROM Reserva r
WHERE r.Estado = 'Activa'
GROUP BY 
    YEAR(r.FechaInicio),
    DATEPART(WEEK, r.FechaInicio);

select *from VW_RECAUDACIONPORFECHA


-- VW_RecaudacionMensual

--  Enunciado:
-- Crear una vista que muestre la recaudación total por mes del año.
-- La vista debe incluir:
--   El año correspondiente
--   El número del mes
--   La cantidad de reservas activas registradas en ese mes
--   El monto total recaudado durante ese mes
--
--  Objetivo práctico:
-- Obtener un resumen financiero mensual del club,
-- que permita analizar la evolución de la recaudación a lo largo del año,
-- sin necesidad de realizar cálculos manuales.
-- Esta vista facilitará los reportes contables y de gestión económica.


CREATE VIEW VW_RecaudacionMensual
AS
SELECT
    YEAR(r.FechaInicio) AS Anio,                      
    MONTH(r.FechaInicio) AS Mes,                      
    COUNT(*) AS CantReservas,                         
    SUM(CASE 
            WHEN r.Estado = 'Activa' THEN r.PrecioTotal 
            ELSE 0 
        END) AS MontoRecaudado                        
FROM Reserva r
WHERE r.Estado = 'Activa'                             
GROUP BY 
    YEAR(r.FechaInicio),
    MONTH(r.FechaInicio);

	select *from VW_RecaudacionMensual