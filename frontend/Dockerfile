FROM ghcr.io/cirruslabs/flutter:3.40.0-0.2.pre

WORKDIR /app

COPY pubspec.yaml pubspec.lock* ./

RUN flutter pub get

COPY . .

CMD [ "bash" ]