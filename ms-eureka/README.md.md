# ms-eureka

# Introducción

El servicio `ms-eureka` es un servidor de registro que utiliza `spring-cloud-starter-netflix-eureka` para facilitar la configuración de servicios en el ecosistema de microservicios. `ms-eureka` actúa como un punto central donde todos los servicios se registran y descubren entre sí, permitiendo el balanceo de carga y la resiliencia en el sistema.

## Funcionalidades Principales:

**Registro de Servicios**: Permite a otros microservicios registrarse en el servidor Eureka, almacenando información sobre la ubicación de cada instancia.

**Descubrimiento de Servicios**: Los microservicios clientes pueden consultar el registro para encontrar y comunicarse con otros servicios dentro del sistema.

**Monitoreo de Estado**: Provee información sobre la disponibilidad y estado de las instancias registradas.

**Balanceo de carga:** Permite distribuir el trafico entre instancias.

# self-preservation

Esto es un modo que tiene eureka de indicar que el servidor de Eureka ha detectado que el número de renovaciones (heartbeats) recibidas de los clientes está por debajo de un umbral definido y nos muestra una advertencia que dice “*EMERGENCY! EUREKA MAY BE INCORRECTLY CLAIMING INSTANCES ARE UP WHEN THEY'RE NOT. RENEWALS ARE LESSER THAN THRESHOLD AND HENCE THE INSTANCES ARE NOT BEING EXPIRED JUST TO BE SAFE***.**”. Esto puede hacer que Eureka mantenga en su registro instancias que ya no están activas, pero que no han sido eliminadas para evitar posibles inconsistencias.

## ¿Qué es lo que está pasando?

Eureka se basa en el envío periódico de señales (heartbeats) por parte de los microservicios registrados para indicar que están "vivos". Cuando estos heartbeats no se reciben a tiempo, Eureka considera que el servicio puede estar caído y debería eliminarlo del registro. Sin embargo, si muchas instancias no envían renovaciones a tiempo, Eureka genera una alerta de emergencia y ajusta temporalmente su comportamiento para evitar eliminar instancias de forma incorrecta.

Este comportamiento de "modo de emergencia" se activa cuando el número de renovaciones cae por debajo de un porcentaje específico del umbral esperado.

## Configuración para Cambiar este Comportamiento

Puedes ajustar varios parámetros en Eureka para gestionar este tipo de situación y evitar falsos positivos:

1. **Configurar el umbral de renovaciones**:
Puedes ajustar el porcentaje de renovaciones necesarias para que Eureka no entre en este modo de emergencia. Esto se hace mediante la propiedad `eureka.server.renewal-percent-threshold`.
    
    ```yaml
    eureka:
      server:
        renewal-percent-threshold: 0.85
    ```
    
    En este ejemplo, se indica que se requiere un 85% de las renovaciones para evitar el modo de emergencia.
    
2. **Tiempo para expirar las instancias**:
Puedes ajustar el tiempo que Eureka espera antes de considerar una instancia como no disponible utilizando la propiedad `eureka.instance.lease-expiration-duration-in-seconds`. Por defecto, es 90 segundos.
    
    ```yaml
    yaml
    Copiar código
    eureka:
      instance:
        lease-expiration-duration-in-seconds: 60
    
    ```
    
3. **Frecuencia de los heartbeats**:
Los clientes también tienen una configuración para ajustar cada cuánto tiempo envían sus renovaciones (heartbeats) a Eureka. Esto se puede configurar con `lease-renewal-interval-in-seconds`.
    
    ```yaml
    yaml
    Copiar código
    eureka:
      instance:
        lease-renewal-interval-in-seconds: 10
    
    ```
    
4. **Deshabilitar el modo de emergencia** (opcional):
En algunos casos, puedes optar por deshabilitar el "modo de emergencia" por completo, si estás seguro de que prefieres que las instancias se eliminen aunque haya riesgos de falsos positivos.
    
    ```yaml
    yaml
    Copiar código
    eureka:
      server:
        enable-self-preservation: false
    
    ```
    

Estas configuraciones permiten ajustar la sensibilidad del servidor de Eureka al monitorear la disponibilidad de los servicios registrados y cómo responder cuando el número de heartbeats cae por debajo de los niveles esperados.

# Listeners

El servicio `ms-eureka` cuenta con dos listeners principales que manejan eventos relacionados con el registro y la baja de servicios en el servidor **Eureka**. Estos listeners permiten capturar información de los clientes que coinciden con un patrón específico y enviar dicha información a otro servicio, llamado **ms-payload-store**. A continuación, se detalla el propósito y funcionamiento de cada listener.

1. Listener **`listenRegisterEvent`**:Este listener se ejecuta cuando un nuevo servicio se registra en Eureka. El evento capturado permite analizar el `appName` ******del cliente registrado y, si coincide con un patrón predefinido, la información de este servicio se envía al servicio `ms-payload-store`.
2. Listener `listenDownEvent`:Este listener se activa cuando un servicio registrado en Eureka se da de baja o deja de estar disponible. Al igual que con el registro, se evalúa si el `appName` del cliente cumple con el patrón predefinido. Si lo hace, se envía una notificación a `ms-payload-store` para actualizar el estado del servicio en el sistema.

Ambos listeners utilizan la misma expresión regular para filtrar los servicios:

```yaml
regexHost: "^(?!.*PAYLOAD-STORE).*?(POS|CENTRAL|STORE).*$"
```

En este ejemplo, el servicio ms-eureka esta filtrando todos los servicios que son POS, CENTRAL o STORE.

## Configuración relacionada

La configuración para la comunicación con el servicio `ms-payload-store` está definida de la siguiente manera:

```yaml
services:
  payload-store:
    host: http://ms-payload-store
    send-host-url-path: ${services.payload-store.host}/api/v1/script/Host
```

Esta URL es utilizada por los listeners para enviar la información del servicio registrado o dado de baja.