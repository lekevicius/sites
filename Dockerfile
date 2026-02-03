FROM nginxinc/nginx-unprivileged:alpine
ARG TARGETOS TARGETARCH
ARG SITE
COPY sites/${SITE}/dist /usr/share/nginx/html
EXPOSE 8080