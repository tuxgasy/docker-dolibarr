FROM nginx:alpine

WORKDIR /etc/nginx
COPY ./nginx/nginx.conf ./conf.d/default.conf
EXPOSE 8080
ENTRYPOINT [ "nginx" ]
CMD [ "-g", "daemon off;" ]
