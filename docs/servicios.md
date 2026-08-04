# Servicios

Descripción de los servicios desplegados en la infraestructura ServidorMP.

---

# Nginx Proxy Manager

## Función

Reverse proxy encargado de gestionar el acceso externo a los servicios internos mediante HTTPS.

Permite:

* Administración de dominios.
* Generación y renovación automática de certificados SSL.
* Redirección hacia servicios Docker internos.
* Gestión de hosts proxy.

## Puerto

Puerto externo:

```
80  HTTP
81  Panel administrativo
443 HTTPS
```

## Persistencia

```
./infraestructura/nginx/data
./infraestructura/nginx/letsencrypt
```

## Acceso

Panel administrativo:

```
http://dominio:81
```

Servicios publicados:

```
https://dominio/
```

---

# n8n

## Función

Plataforma de automatización de procesos mediante workflows.

Permite integrar:

* APIs REST.
* Bases de datos.
* Servicios externos.
* Webhooks.
* Inteligencia artificial.
* Automatizaciones personalizadas.

## Puerto

Puerto interno:

```
5678
```

## URL

```
https://dominio/n8n/
```

## Persistencia

```
./herramientas/n8n/data
```

## Base de datos

Utiliza MariaDB como motor de almacenamiento.

Configuración mediante variables:

```
DB_TYPE
DB_MYSQLDB_HOST
DB_MYSQLDB_DATABASE
DB_MYSQLDB_USER
DB_MYSQLDB_PASSWORD
```

## Seguridad

* Acceso mediante HTTPS.
* Variables sensibles almacenadas en `.env`.
* Clave de cifrado propia mediante:

```
N8N_ENCRYPTION_KEY
```

---

# Node-RED

## Función

Herramienta de programación visual orientada principalmente a automatización e integración de dispositivos IoT.

Permite crear flujos mediante nodos conectados.

Casos de uso:

* Automatizaciones.
* Procesamiento de datos.
* Integración con MQTT.
* Control de dispositivos.

## Puerto

Puerto interno:

```
1880
```

## URL

```
https://dominio/nodered/
```

## Persistencia

```
./herramientas/node-red/data
```

## Seguridad

Cuenta con autenticación habilitada mediante configuración de usuario y contraseña.

Los flujos y credenciales permanecen almacenados dentro del volumen persistente.

---

# Mosquitto MQTT

## Función

Broker MQTT utilizado para comunicación entre dispositivos IoT y servicios internos.

Arquitectura:

```
Dispositivo IoT
      |
      |
     MQTT
      |
 Mosquitto Broker
      |
 Node-RED / Aplicaciones
```

## Puerto

Puerto MQTT:

```
1883
```

## Persistencia

Configuración:

```
./infraestructura/mosquitto/config
```

Datos:

```
./infraestructura/mosquitto/data
```

Logs:

```
./infraestructura/mosquitto/log
```

## Seguridad

* Autenticación mediante usuario y contraseña.
* Acceso anónimo deshabilitado.

Configuración:

```
allow_anonymous false
password_file
```

---

# MariaDB

## Función

Sistema gestor de bases de datos relacional utilizado por las aplicaciones que requieren almacenamiento persistente.

Actualmente utilizado por:

* n8n.
* phpMyAdmin.

## Puerto

Puerto interno:

```
3306
```

## Persistencia

```
./infraestructura/mariadb/data
```

## Seguridad

Las credenciales se administran mediante:

```
.env
```

No se almacenan contraseñas dentro del repositorio.

---

# phpMyAdmin

## Función

Interfaz web para administración visual de bases de datos MariaDB.

Permite:

* Crear bases de datos.
* Ejecutar consultas SQL.
* Administrar usuarios.
* Revisar tablas y registros.

## Puerto

Puerto interno:

```
80
```

## URL

```
https://dominio/phpmyadmin/
```

## Configuración

Conexión automática hacia:

```
mariadb
```

mediante la red interna Docker.

---

# Homepage

## Función

Página principal del servidor utilizada como dashboard de acceso rápido.

Centraliza enlaces hacia los servicios publicados.

## Puerto

Puerto interno:

```
80
```

## URL

```
https://dominio/
```

## Persistencia

Archivos HTML:

```
./pagina/html
```

---

# Redes Docker

La infraestructura utiliza dos redes separadas.

## proxy

Servicios conectados al reverse proxy:

* nginx
* n8n
* Node-RED
* phpMyAdmin
* homepage

## internal

Comunicación privada entre servicios:

* MariaDB
* Mosquitto
* n8n
* Node-RED

Esta separación evita exponer directamente servicios internos hacia internet.
