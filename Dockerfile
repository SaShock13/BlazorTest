# Базовый образ для сборки
FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

# 1. Копируем файл решения (если есть)
COPY *.sln ./

# 2. Копируем файл проекта из папки и восстанавливаем зависимости
COPY BlazorApp/BlazorApp.csproj ./BlazorApp/
RUN dotnet restore BlazorApp/BlazorApp.csproj

# 3. Копируем всё остальное
COPY . .

# 4. Публикуем конкретный проект
RUN dotnet publish BlazorApp/BlazorApp.csproj \
    -c Release \
    -o /app \
    --nologo

# Финальный образ с nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Копируем опубликованное приложение
COPY --from=build /app/wwwroot .

# Копируем nginx config
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80