

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

select   s.IDSocio,s.Nombre,s.Apellido,s.DNI,s.Direccion,s.Email,s.TipoSocio,s.FechaAlta
from socio s  
 where s.FechaBaja is null

 select *from VW_SOCIOSACTIVOS 

--Vista: VW_ReservasDetalladas


--Crear una vista que muestre todas las reservas realizadas por los socios, detallando la información del socio y del recurso reservado (cancha, quincho o pileta).
--Debe incluir: nombre y apellido del socio, tipo de recurso reservado, número del recurso, fecha y hora de inicio, fecha y hora de fin, precio total y estado de la reserva.
--La vista permitirá obtener un resumen completo de las reservas efectuadas en el club.

--Objetivo práctico:
--Brindar una herramienta para visualizar todas las reservas con sus respectivos socios y recursos.

 create view VW_RESERVASDETALLADAS












-- Vista: VW_RecaudacionPorFecha



--Crear una vista que muestre la recaudación total diaria generada por las reservas, agrupando las sumas por fecha.
--Debe incluir la fecha, la cantidad de reservas realizadas en esa fecha y el monto total recaudado.
--Esta vista servirá para generar reportes financieros y analizar el rendimiento del club.

--Objetivo práctico:
--Obtener un resumen financiero por día, semana o mes sin necesidad de cálculos manuales.