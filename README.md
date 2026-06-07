# Práctica: Despliegue LAMP con HTTPS (Certificado Autofirmado)

## 📖 Descripción General
Este repositorio contiene la automatización de un entorno **LAMP** (Linux, Apache, MySQL, PHP) junto con la configuración de conexiones seguras **HTTPS** mediante la generación de un certificado SSL/TLS autofirmado.

El proceso automatiza tanto la instalación de los servicios base como la creación del par de claves criptográficas utilizando `openssl`, inyectando la información de la organización mediante variables de entorno.

## 📂 Estructura del Repositorio

* **`conf/`**: Configuraciones del servidor web Apache.
  * `000-default.conf`: VirtualHost para el tráfico HTTP (puerto 80).
  * `default-ssl.conf`: VirtualHost para el tráfico HTTPS (puerto 443), con las directivas del motor SSL activadas.
* **`scripts/`**: Automatización del despliegue.
  * `.env`: Variables de entorno con los datos de la organización (País, Provincia, Localidad, etc.) para el certificado.
  * `install_lamp.sh`: Instalación de paquetes base de la pila LAMP.
  * `generar_certificado.sh`: Script que utiliza OpenSSL para emitir el certificado `.crt` y la clave privada `.key` necesarios para habilitar HTTPS.

## ⚙️ Configuración Previa

Antes de ejecutar la automatización, revisa el archivo `scripts/.env`. Contiene los datos que OpenSSL incrustará en el certificado. Puedes personalizarlos según tus necesidades:
```env
OPENSSL_COUNTRY="ES"
OPENSSL_PROVINCE="Almeria"
OPENSSL_LOCALITY="Almeria"
OPENSSL_ORGANIZATION="IES Celia"
OPENSSL_ORGUNIT="Departamento de Informatica"
OPENSSL_COMMON_NAME="practica-https.local"
OPENSSL_EMAIL="admin@iescelia.org"



### ⚠️ Ojo con un detalle crítico en tus scripts

Analizando el código que me has pasado, hay **dos pequeños errores** en tu script `generar_certificado.sh` que harán que la práctica no funcione si no los corriges:

**1. Te falta importar el archivo `.env`:**
Estás usando variables como `$OPENSSL_COUNTRY` en el comando de `openssl`, pero nunca cargas el archivo `.env` en ese script. El certificado se creará con esos campos vacíos.
**Solución:** Añade `source .env` al principio del script.

**2. Falta activar el SSL en Apache:**
Tu script genera el certificado, pero **no le dice a Apache que lo use**. Tienes que habilitar el módulo SSL, copiar tu archivo `default-ssl.conf` y habilitar el sitio seguro.

Aquí tienes cómo debería quedar tu archivo **`generar_certificado.sh`** corregido para sacar un 10:

```bash
#!/bin/bash
set -ex

# 1. Importamos las variables de entorno
source .env

# 2. Creamos el certificado autofirmado
sudo openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/apache-selfsigned.key \
  -out /etc/ssl/certs/apache-selfsigned.crt \
  -subj "/C=$OPENSSL_COUNTRY/ST=$OPENSSL_PROVINCE/L=$OPENSSL_LOCALITY/O=$OPENSSL_ORGANIZATION/OU=$OPENSSL_ORGUNIT/CN=$OPENSSL_COMMON_NAME/emailAddress=$OPENSSL_EMAIL"

# 3. Copiamos el archivo de configuración SSL de Apache
cp ../conf/default-ssl.conf /etc/apache2/sites-available/

# 4. Habilitamos el módulo SSL en Apache
a2enmod ssl

# 5. Habilitamos el VirtualHost seguro
a2ensite default-ssl.conf

# 6. Reiniciamos Apache para aplicar los cambios
systemctl restart apache2