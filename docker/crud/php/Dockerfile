FROM php:8.3-fpm

# Instala la librería de desarrollo de PostgreSQL (libpq-dev), necesaria
# para compilar la extensión, y luego la extensión pdo_pgsql.
# Todo esto ocurre DENTRO de la imagen; tu máquina no se toca.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && rm -rf /var/lib/apt/lists/*

# Por defecto php-fpm oculta las variables de entorno a los scripts.
# Con esto, getenv() en index.php sí puede leer DB_HOST, DB_USER, etc.
RUN echo "clear_env = no" >> /usr/local/etc/php-fpm.d/www.conf
