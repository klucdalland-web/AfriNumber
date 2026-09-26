#!/bin/sh
set -e

PORT="${PORT:-10000}"

# Bind nginx to Render's injected PORT (avoids "Port scan timeout")
cat > /etc/nginx/http.d/default.conf <<EOF
server {
    listen ${PORT};
    server_name _;
    root /var/www/html/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \\.php\$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

echo "Listening on 0.0.0.0:${PORT}"

# Évite migrate avec les defaults Laravel (127.0.0.1 / laravel)
if [ -z "${DB_HOST:-}" ] || [ -z "${DB_DATABASE:-}" ] || [ -z "${DB_USERNAME:-}" ] || [ -z "${DB_PASSWORD:-}" ]; then
  echo "ERROR: variables DB manquantes. Sur Render, définis au minimum :"
  echo "  DB_CONNECTION, DB_HOST, DB_PORT, DB_DATABASE, DB_USERNAME, DB_PASSWORD, DB_SSLMODE"
  echo "Valeurs vues: DB_CONNECTION=${DB_CONNECTION:-<empty>} DB_HOST=${DB_HOST:-<empty>} DB_DATABASE=${DB_DATABASE:-<empty>} DB_USERNAME=${DB_USERNAME:-<empty>}"
  exit 1
fi

# Rebuild le cache config à chaque boot (les secrets Render ne sont pas dans l'image)
php artisan config:clear || true
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true
php artisan migrate --force
# Unique entrypoint pour les référentiels de prod (voir RequiredDataSeeder)
php artisan db:seed --class=RequiredDataSeeder --force --no-interaction
php artisan storage:link || true

exec /usr/bin/supervisord -c /etc/supervisord.conf
