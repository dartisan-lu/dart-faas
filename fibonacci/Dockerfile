# Use Google's official Dart image.
# https://hub.docker.com/_/dart
FROM dart:stable as builder

WORKDIR /app

COPY ./pubspec.yaml ./pubspec.yaml
COPY ./pubspec.lock ./pubspec.lock
COPY ./bin ./bin

RUN dart pub get
RUN dart compile exe bin/server.dart -o bin/server

ENTRYPOINT ["bin/server"]
