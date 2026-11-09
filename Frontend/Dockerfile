# ==============================================================================
# Dockerfile do Frontend (Flutter Web + Nginx)
# ==============================================================================
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /build

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
ARG API_URL=SAME_ORIGIN
RUN flutter build web --release --pwa-strategy=none --dart-define=API_URL=${API_URL}

FROM nginx:1.27-alpine

RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/software_brava.conf
COPY --from=builder /build/build/web /usr/share/nginx/html

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]

