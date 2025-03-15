FROM mcr.microsoft.com/dotnet/sdk:9.0 AS builder
WORKDIR /

COPY ./.editorconfig ./
COPY ./global.json ./
COPY ./Directory.Build.props ./

# Setup working directory for the project
COPY ./building-blocks/BuildingBlocks.csproj ./building-blocks/
COPY ./3-microservices-architecture-style/src/Services/Booking/src/Booking/Booking.csproj ./3-microservices-architecture-style/src/Services/Booking/src/Booking/
COPY ./3-microservices-architecture-style/src/Services/Booking/src/Booking.Api/Booking.Api.csproj ./3-microservices-architecture-style/src/Services/Booking/src/Booking.Api/


# Restore nuget packages
RUN --mount=type=cache,id=booking_nuget,target=/root/.nuget/packages \
    dotnet restore ./3-microservices-architecture-style/src/Services/Booking/src/Booking.Api/Booking.Api.csproj

# Copy project files
COPY ./building-blocks ./building-blocks/
COPY ./3-microservices-architecture-style/src/Services/Booking/src/Booking/  ./3-microservices-architecture-style/src/Services/Booking/src/Booking/
COPY ./3-microservices-architecture-style/src/Services/Booking/src/Booking.Api/  ./3-microservices-architecture-style/src/Services/Booking/src/Booking.Api/

# Build project with Release configuration
# and no restore, as we did it already

RUN ls
RUN --mount=type=cache,id=booking_nuget,target=/root/.nuget/packages\
    dotnet build  -c Release --no-restore ./3-microservices-architecture-style/src/Services/Booking/src/Booking.Api/Booking.Api.csproj

WORKDIR /3-microservices-architecture-style/src/Services/Booking/src/Booking.Api

# Publish project to output folder
# and no build, as we did it already
RUN --mount=type=cache,id=booking_nuget,target=/root/.nuget/packages\
    dotnet publish -c Release --no-build -o out

FROM mcr.microsoft.com/dotnet/aspnet:9.0

# Setup working directory for the project
WORKDIR /
COPY --from=builder /3-microservices-architecture-style/src/Services/Booking/src/Booking.Api/out  .

ENV ASPNETCORE_URLS https://*:443, http://*:80
ENV ASPNETCORE_ENVIRONMENT docker

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["dotnet", "Booking.Api.dll"]

