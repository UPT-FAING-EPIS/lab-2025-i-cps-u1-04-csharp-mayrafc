# Utilizar la imagen base de .NET SDK
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar el resto de la aplicación
COPY src/. ./

# Verificar los archivos copiados (esto es útil para depuración)
RUN ls -la /app

# Restaurar las dependencias
RUN dotnet restore

# Publicar la aplicación
RUN dotnet publish -c Release -o out

# Utilizar la imagen base de .NET Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS runtime

LABEL org.opencontainers.image.source="https://github.com/p-cuadros/Shorten02"

# Establecer el directorio de trabajo
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:80

# Instalar dependencias adicionales
RUN apk add --no-cache icu-libs

# Configurar para que .NET no use la globalización invariante
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false

# Copiar los archivos compilados desde la etapa de construcción
COPY --from=build /app/out ./

# Definir el comando de entrada para ejecutar la aplicación
ENTRYPOINT ["dotnet", "Shorten.dll"]
