# pcp-pmda-php-fpm
Co-pilot pcp pmda metrics module for php-fpm 
by Andrey Fedorov, email: asfedorov@gmail.com

# setup on CentOs 7

## nginx

Add status location for your php-fpm service

    location ~ ^/(status)$ {
        allow 127.0.0.1;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_pass 127.0.0.1:9000;
    }

## pcp pmda module install

~~~bash
cd /var/lib/pcp/pmdas
git clone https://github.com/asfed/pcp-pmda-php-fpm.git php-fpm
cd ./php-fpm
./Install
~~~

## check

pminfo php-fpm -f
