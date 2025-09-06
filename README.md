# Proyecto Celerix - ETL Pipeline

Sistema ETL (Extract, Transform, Load) que procesa datos de empleados desde archivos CSV y los carga en una base de datos PostgreSQL con generación automática de IDs.

## Descripción

Este proyecto implementa un pipeline ETL que:
- Extrae datos de empleados desde un archivo CSV
- Transforma y valida los datos
- Genera automáticamente IDs únicos para evitar duplicados
- Carga los datos en PostgreSQL

## Uso

Para ejecutar el pipeline ETL:

```bash
docker-compose up --build
```

## Estructura del Proyecto

```
├── data.csv              # Archivo de datos de entrada
├── etl.py               # Script principal del ETL
├── requirements.txt     # Dependencias de Python
├── Dockerfile          # Imagen del contenedor ETL
├── docker-compose.yml  # Configuración de servicios
├── .env               # Variables de entorno
└── README.md          # Documentación
```

## Estructura de Datos

### Archivo CSV de entrada
El archivo `data.csv` debe contener las siguientes columnas (separadas por tabulador):
- `nombre`: Nombre del empleado (VARCHAR)
- `apellido`: Apellido del empleado (VARCHAR)
- `fecha_contratacion`: Fecha de contratación en formato YYYY-MM-DD
- `salario`: Salario del empleado (DECIMAL)
- `id_departamento`: ID del departamento (INTEGER)

### Tabla PostgreSQL
La tabla `empleados` se crea automáticamente con la siguiente estructura:
```sql
CREATE TABLE empleados (
    id_empleado INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    fecha_contratacion DATE,
    salario DECIMAL(10, 2),
    id_departamento INT
);
```

## Funcionalidades

### Generación Automática de IDs
- El sistema consulta automáticamente el último ID utilizado en la tabla
- Genera IDs secuenciales únicos para evitar conflictos
- No requiere especificar IDs manualmente en el CSV

### Manejo de Errores
- Validación de conexión a base de datos
- Rollback automático en caso de errores
- Logs detallados del proceso

### Transformación de Datos
- Limpieza de valores nulos
- Conversión automática de tipos de datos
- Validación de estructura del CSV

## Configuración

### Variables de Entorno
El archivo `.env` contiene las siguientes configuraciones:

```
POSTGRES_DB=nombre_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=tu_contraseña
POSTGRES_HOST=host.docker.internal
POSTGRES_PORT=5432
```

### Conexión a Base de Datos
- Para usar PostgreSQL local: `POSTGRES_HOST=host.docker.internal`
- Para usar PostgreSQL en contenedor: `POSTGRES_HOST=db`

## Requisitos

- Docker
- Docker Compose
- PostgreSQL (local o en contenedor)

## Ejemplo de Archivo CSV

```
nombre	apellido	fecha_contratacion	salario	id_departamento
Juan	Perez	2024-01-15	35000	1
Maria	Lopez	2024-02-20	37000	2
Carlos	Rodriguez	2024-03-10	38000	1
```

## Proceso ETL

1. **Extract**: Lee el archivo CSV con separador de tabulador
2. **Transform**:
   - Limpia datos nulos
   - Convierte tipos de datos
   - Obtiene el siguiente ID disponible
   - Genera IDs automáticamente
3. **Load**:
   - Crea la tabla si no existe
   - Inserta los datos con batch processing
   - Confirma la transacción

## Logs del Proceso

El sistema proporciona logs detallados:
- Conexión a base de datos
- Número de registros extraídos
- Transformaciones aplicadas
- Siguiente ID disponible
- Registros insertados exitosamente
- Manejo de errores
