FROM openresty/openresty:1.21.4.1-0-alpine-fat

COPY ./nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY ./src /lua/src

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-redis

EXPOSE 8888/tcp
EXPOSE 8888/udp

ENTRYPOINT ["/usr/local/openresty/bin/openresty"]
CMD ["-g", "daemon off;"]