import os
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv
import time
import sys

# Cargar variables de entorno
load_dotenv()

# Configuración de base de datos
DB_CONFIG = {
    'dbname': os.getenv('POSTGRES_DB'),
    'user': os.getenv('POSTGRES_USER'),
    'password': os.getenv('POSTGRES_PASSWORD'),
    'host': os.getenv('POSTGRES_HOST'),
    'port': os.getenv('POSTGRES_PORT')
}

def wait_for_db():
    """Espera a que la base de datos esté disponible"""
    max_retries = 30
    for i in range(max_retries):
        try:
            conn = psycopg2.connect(**DB_CONFIG)
            conn.close()
            print("Base de datos disponible")
            return True
        except psycopg2.OperationalError:
            print(f"Esperando base de datos ({i+1}/{max_retries})")
            time.sleep(2)
    return False

def main():
    print("Iniciando proceso ETL")

    if not wait_for_db():
        print("No se pudo conectar a la base de datos")
        sys.exit(1)

    try:
        # Extraer
        print("Extrayendo datos del CSV")
        df = pd.read_csv('data.csv', sep='\t')
        print(f"Datos extraídos: {len(df)} registros")

        # Transformar
        print("Transformando datos")
        df = df.dropna()
        df['salario'] = df['salario'].astype(float)
        df['nombre'] = df['nombre'].astype(str)
        df['apellido'] = df['apellido'].astype(str)
        df['fecha_contratacion'] = df['fecha_contratacion'].astype(str)
        df['id_departamento'] = df['id_departamento'].astype(int)
        print(f"Datos transformados: {len(df)} registros listos")

        # Cargar
        print("Conectando a la base de datos")
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()

        # Crear tabla si no existe
        print("Creando tabla si no existe")
        cur.execute("""
        CREATE TABLE IF NOT EXISTS empleados (
            id_empleado INT PRIMARY KEY,
            nombre VARCHAR(50),
            apellido VARCHAR(50),
            fecha_contratacion DATE,
            salario DECIMAL(10, 2),
            id_departamento INT
        );
        """)

        # Obtener el siguiente ID disponible
        print("Obteniendo siguiente ID disponible")
        cur.execute("SELECT COALESCE(MAX(id_empleado), 0) + 1 FROM empleados;")
        next_id = cur.fetchone()[0]

        # Generar IDs automáticamente
        df['id_empleado'] = range(next_id, next_id + len(df))

        # Insertar datos
        print("Insertando datos")
        records = [(row['id_empleado'], row['nombre'], row['apellido'], row['fecha_contratacion'], row['salario'], row['id_departamento']) 
                  for _, row in df.iterrows()]

        execute_values(
            cur,
            "INSERT INTO empleados (id_empleado, nombre, apellido, fecha_contratacion, salario, id_departamento) VALUES %s",
            records
        )

        conn.commit()
        print(f"ETL completado: {len(records)} registros insertados")

    except Exception as e:
        print(f"Error: {e}")
        if 'conn' in locals():
            conn.rollback()
        sys.exit(1)
    finally:
        if 'cur' in locals():
            cur.close()
        if 'conn' in locals():
            conn.close()
        print("Conexión cerrada")

if __name__ == "__main__":
    main()