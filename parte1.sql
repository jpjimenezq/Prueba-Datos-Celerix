/* Inserte un nuevo empleado en la tabla empleados con los siguientes datos: ID
6, nombre = Elena, apellido = López;, fecha de contratación = 2023-05-01;, salario
33000.00, departamento 3. */
INSERT INTO empleados VALUES
(6, 'Elena', 'López', '2023-05-01', 33000.00, 3);

SELECT * FROM empleados;

-- Actualice el salario del empleado con ID 2 a 37000.00.
UPDATE empleados
SET salario = 37000.00
WHERE id_empleado = 2;

/* Haz una consulta que muestre el nombre del producto, stock, la cantidad de
veces que ha sido pedido, la cantidad de veces que ha sido vendido, la fecha del
último pedido para cada producto y el total de ingresos generados por ese
producto.
agrega un filtro que me muestre solo lso productos que han tenido mas de un
pedido */
SELECT 
nombre_producto,
stock,
COUNT(pd.id_pedido) AS cantidad_pedidos,
SUM(cantidad) AS cantidad_vendido,
MAX(pd.fecha_pedido) AS ultima_fecha_pedido,
(SUM(cantidad) * precio) AS total_ingresos
FROM productos AS p
INNER JOIN detalle_pedidos AS dp ON p.id_producto = dp.id_producto
INNER JOIN pedidos AS pd ON pd.id_pedido = dp.id_pedido
GROUP BY nombre_producto, stock, precio
HAVING COUNT(pd.id_pedido) >= 2;

SELECT * FROM productos;

/*Implemente un trigger que actualice automáticamente el stock de un producto
cuando se realiza un nuevo pedido.*/

CREATE OR REPLACE FUNCTION actualizar_stock()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE productos
    SET stock = stock - NEW.cantidad
    WHERE id_producto = NEW.id_producto;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_stock
AFTER INSERT ON detalle_pedidos
FOR EACH ROW
EXECUTE FUNCTION actualizar_stock();

/* Caso de prueba del trigger */
INSERT INTO detalle_pedidos (id_detalle, id_pedido, id_producto, cantidad, precio_unitario)
VALUES (9, 2, 3, 2, 300.00);

/* Diseñe los índices apropiados para mejorar el rendimiento de consultas
frecuentes en la tabla pedidos */
-- Indice para buscar por cliente
CREATE INDEX idx_pedidos_cliente
ON pedidos (id_cliente);

-- Indice para consultas por fecha
CREATE INDEX idx_pedidos_fecha
ON pedidos (fecha_pedido);

-- Indice compuesto de cliente + fecha
CREATE INDEX idx_pedidos_cliente_fecha
ON pedidos (id_cliente, fecha_pedido);

-- Indice montos mayores o menores
CREATE INDEX idx_pedidos_total
ON pedidos (total);

/* Escriba una consulta que utilice una ventana deslizante (window function) para
calcular el salario acumulado por departamento */
SELECT 
e.id_empleado,
e.nombre,
e.apellido,
d.nombre_departamento,
e.salario,
SUM(e.salario) OVER (
	PARTITION BY e.id_departamento
	ORDER BY e.fecha_contratacion
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
) AS salario_acumulado
FROM empleados e
JOIN departamentos d ON e.id_departamento = d.id_departamento
ORDER BY d.nombre_departamento, e.fecha_contratacion;

SELECT * FROM empleados;

DELETE FROM empleados 
WHERE id_empleado IN (7, 8, 9, 10, 11, 12, 13, 14,15, 16);