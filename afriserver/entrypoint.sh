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

php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true
php artisan migrate --force
php artisan storage:link || true

exec /usr/bin/supervisord -c /etc/supervisord.conf
