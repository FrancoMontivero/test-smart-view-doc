# Zookeeper

# Guía para Configurar Apache Zookeeper en Windows

## Descargar y Extraer Apache Zookeeper usando 7-Zip

Puedes descargar Apache Zookeeper desde el siguiente enlace: [Apache Zookeeper Descargas](http://zookeeper.apache.org/releases.html#download).

La versión estable de Zookeeper al momento de escribir esto es la 3.8.4. Puedes descargar y extraer el archivo en cualquier ubicación de tu sistema, pero para este ejemplo asumiremos que está extraído en la carpeta `C:\\Tools\\`.

### Requisitos Previos

- Se requiere JRE (Java Runtime Environment) o JDK (Java Development Kit) para ejecutar Apache Zookeeper.

A continuación, se explica cómo configurar la variable de entorno `JAVA_HOME` en Windows 11/10.

## Configuración de JAVA_HOME en Windows

1. **Descargar e instalar Java**: Primero, descarga e instala Java desde el sitio oficial [java.com](https://www.java.com/).
2. **Abrir Configuración Avanzada del Sistema**:
    - Ve al menú de inicio y escribe "Configuración avanzada del sistema".
    - Haz clic en "Ver configuración avanzada del sistema" para abrir las Propiedades del Sistema.
3. **Variables de Entorno**:
    - Ve a la pestaña "Avanzado" y haz clic en el botón "Variables de entorno".
4. **Crear la Variable JAVA\_HOME**:
    - En la sección de Variables del sistema, haz clic en "Nuevo".
    - En "Nombre de la variable", escribe `JAVA_HOME`.
    - En "Valor de la variable", escribe la ruta al directorio donde instalaste el JDK. Por ejemplo: `C:\\Program Files\\Java\\jdk1.8.0_121`.
    - Haz clic en "Aceptar".
5. **Actualizar la Variable Path**:
    - En la ventana de Variables de entorno, selecciona "Path" en la sección de Variables del sistema y haz clic en "Editar".
    - Haz clic en "Nuevo" y escribe `%JAVA_HOME%\\bin`.
    - Haz clic en "Aceptar" para aplicar los cambios.
6. **Comprobar la Configuración**:
    - Abre el "Símbolo del sistema" (CMD).
    - Escribe `echo %JAVA_HOME%` y presiona Enter. Esto debería mostrar la ruta del JDK que configuraste.
    - Luego, escribe `javac -version` para verificar la versión del compilador de Java.

## Configurar Apache Zookeeper

1. **Renombrar el Archivo de Configuración**:
    - Copia y renombra el archivo `zoo_sample.cfg` a `zoo.cfg` en `C:\\Tools\\zookeeper-3.4.9\\conf`.
2. **Crear Directorio de Datos**:
    - Crea una carpeta llamada `data` dentro del directorio de Zookeeper (`C:\\Tools\\zookeeper-3.4.9`).
3. **Editar Configuración del Directorio de Datos**:
    - Abre el archivo `zoo.cfg` con un editor de texto como Notepad o Notepad++.
    - Busca la línea `dataDir=/tmp/zookeeper` y cámbiala por:
    (Asegúrate de cambiar el número de versión si es diferente en tu caso).
        
        ```
        dataDir=C:\\Tools\\zookeeper-3.4.9\\data
        ```
        
4. **Agregar Variables de Entorno para Zookeeper**:
    - Ve nuevamente a las Variables de entorno del sistema.
    - Agrega una nueva variable del sistema llamada `ZOOKEEPER_HOME` con el valor `C:\\Tools\\zookeeper-3.4.9`.
    - Edita la variable `Path` y añade al final `;%ZOOKEEPER_HOME%\\bin;`.
5. **Iniciar Zookeeper**:
    - Abre el "Símbolo del sistema" y escribe `zkserver`.
    - Esto iniciará Zookeeper en el puerto predeterminado (2181). Si deseas cambiar este puerto, puedes editar el archivo `zoo.cfg` y modificar la línea correspondiente.

## Verificar la Instalación

Para asegurarte de que Zookeeper está funcionando correctamente, abre un "Símbolo del sistema" y escribe `zkserver`. Deberías ver mensajes indicando que el servidor Zookeeper ha iniciado correctamente.

¡Y eso es todo! Ahora deberías tener Apache Zookeeper configurado y ejecutándose en tu sistema Windows.

## Configurar TTL

Para habilitar la posibildad de configurar ttl en los nodos de ZooKeeper es necesario agregar estas propieades el archivo `zoo.cfg`

```
extendedTypesEnabled=true
emulate353TTLNodes=true
```

# Configurar Apache ZooKeeper en Docker

## Docker run

Puedes utilizar `docker run` para desplegar ZooKeeper de manera sencilla. A continuación se muestra un ejemplo de cómo hacerlo:

```
docker run --name zookeeper -p 2181:2181 -d \
  -e ZOO_MY_ID=1 \
  -e ZOO_SERVERS="server.1=zookeeper:2888:3888" \
  -e ZOO_CFG_EXTRA="extendedTypesEnabled=true\nemulate353TTLNodes=true" \
  zookeeper:3.7.1
```

Este comando crea un contenedor con el nombre `zookeeper` y expone el puerto `2181` para que puedas conectarte a él desde tu host o cualquier otro contenedor que lo necesite. El contenedor se ejecutará en segundo plano (`-d`). Además, se agregan las configuraciones para habilitar el soporte de TTL en los nodos (`extendedTypesEnabled` y `emulate353TTLNodes`).

## Docker compose

Otra opción es usar `docker-compose` para desplegar ZooKeeper junto con otros servicios. A continuación, se presenta un archivo `docker-compose.yml` de ejemplo:

```yaml
version: '3.8'

services:
  zookeeper:
    image: zookeeper:3.7.1
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: "server.1=zookeeper:2888:3888"
      ZOO_CFG_EXTRA: |
        # Enable TTL
        extendedTypesEnabled=true
        emulate353TTLNodes=true
```

Este archivo define un servicio llamado `zookeeper` que se despliega con la imagen oficial de ZooKeeper y expone el puerto `2181` para la comunicación. Además, se han agregado configuraciones para habilitar el soporte de TTL en los nodos (`extendedTypesEnabled` y `emulate353TTLNodes`).

Puedes desplegar ZooKeeper utilizando `docker-compose` con el siguiente comando:

```docker
docker-compose up -d
```