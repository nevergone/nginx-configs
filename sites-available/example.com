## example.com site config, with optional HTTPS support

## HTTP server
server {
  ## port number
  listen                80;

  ## site name
  server_name           example.com *.example.com;

  ## log settings
  access_log            /var/log/nginx/example.com.access.log main;
  error_log             /var/log/nginx/example.com.error.log;

  ## site document root
  root                  /srv/www/example.com/htdocs;

  location ~* \.php$ {
    include             fastcgi_params;
    keepalive_timeout   0;
    # fastcgi_pass        127.0.0.1:9000;     ## port
    # fastcgi_pass        unix:/var/run/php5-fpm-example.com.sock;        ## UNIX socket
    fastcgi_pass        unix:/var/run/php5-fpm-$server_name.sock;       ## UNIX socket with variables
    fastcgi_param       SCRIPT_FILENAME $document_root$fastcgi_script_name;
  }

  ## ======================================================================
  ## Drupal 7 configuration
  ## ======================================================================
  include site-types/drupal_7.conf;
}

## HTTPS server
server {
  ## port number
  listen                443 ssl;

  ## site name
  server_name           example.com *.example.com;

  ## log settings
  access_log            /var/log/nginx/example.com.access.log main;
  error_log             /var/log/nginx/example.com.error.log;

  ## site document root
  root                  /srv/www/example.com/htdocs;

  ssl on;
  ssl_certificate       ssl/example.com.crt;
  ssl_certificate_key   ssl/example.com.key;

  location ~* \.php$ {
    include             fastcgi_params;
    keepalive_timeout   0;
    # fastcgi_pass        127.0.0.1:9000;     ## port
    # fastcgi_pass        unix:/var/run/php5-fpm-example.com.sock;        ## UNIX socket
    fastcgi_pass        unix:/var/run/php5-fpm-$server_name.sock;       ## UNIX socket with variables
    fastcgi_param       SCRIPT_FILENAME $document_root$fastcgi_script_name;
  }

  ## ======================================================================
  ## Drupal 7 configuration
  ## ======================================================================
  include site-types/drupal_7.conf;
}

