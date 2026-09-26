# syntax=docker/dockerfile:1.4

# --- Frontend build ---
FROM node:22-alpine AS frontend
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY vite.config.js ./
COPY resources ./resources
COPY public ./public
RUN npm run build

# --- PHP / Nginx runtime ---
FROM php:8.4-fpm-alpine

RUN apk add --no-cache \
    nginx supervisor bash git unzip \
    libzip-dev oniguruma-dev icu-dev postgresql-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql mbstring zip intl bcmath opcache \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY . .
COPY --from=frontend /app/public/build ./public/build

RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Nginx listen port is written at runtime from $PORT in entrypoint.sh
RUN mkdir -p /etc/nginx/http.d /run/nginx

RUN cat <<'EOF' > /etc/supervisord.conf
[supervisord]
nodaemon=true

[program:php-fpm]
command=php-fpm -F
autostart=true
autorestart=true
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOF

# Render injects PORT (default 10000). Do not hardcode 80.
EXPOSE 10000

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]