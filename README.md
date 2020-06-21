# pcp-pmda-php-fpm

<p align="left">
        <a href="https://github.com/asfed/pcp-pmda-php-fpm/releases">
            <img src="https://img.shields.io/github/v/release/asfed/pcp-pmda-php-fpm" />
        </a>
        <a href="https://www.patreon.com/asfedorov">
            <img src="https://img.shields.io/badge/donate-patreon-green" />
        </a>
</p>

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
