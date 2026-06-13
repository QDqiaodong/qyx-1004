# syntax=docker/dockerfile:1.7

FROM node:20-bookworm-slim AS frontend-build
WORKDIR /frontend

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

COPY web web
RUN npm run build:web

FROM maven:3.9-eclipse-temurin-17 AS backend-deps
WORKDIR /build/backend

COPY backend/pom.xml ./
RUN --mount=type=cache,target=/root/.m2 mvn -q -DskipTests dependency:go-offline

FROM backend-deps AS backend-build
WORKDIR /build/backend

COPY backend/src src
RUN --mount=type=cache,target=/root/.m2 mvn -q -DskipTests package

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

COPY --from=backend-build /build/backend/target/chuanzi-restaurant-assistant.jar /app/app.jar
COPY --from=frontend-build /frontend/dist/web /app/web

ENV APP_PORT=8080
ENV WEB_ROOT=/app/web

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
