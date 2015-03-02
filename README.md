# import-emx-channels

Import EMX Channels es un script de utilidad para cargar canales exportados del sistema EMX (Estudio) hacia el sistema de streaming RMS.

Este script se programa para que se ejecute en un crontab y tiene como objetivo leer la lista de todos los canales desde archivos xml e importa los mismos a una base de datos MySQL para que el sistema de streaming pueda leer dichos canales.

# Instalación

Actualizar paquetes e instalar las dependencias:

sudo apt-get install git ruby2.2 ruby2.2-dev libxml2-dev libxslt1-dev \
        build-essential libmysqlclient-dev
        
### Obtención del software

Clonar los repositorios de servidor (Git Hub):

git clone https://github.com/ddlarosa/import-emx-channels

### Fichero de configuración

La configuración por defecto del sistema está en `import_emx_channels/config/base.rb`.
Este fichero no se debe modificar porque está en control de versiones.
Para ajustar determinadas opciones, en lugar de repetir el fichero de
configuración completo, basta con crear un fichero
`import_emx_channels/config/custom.rb` que modifique las opciones concretas
directamente.

