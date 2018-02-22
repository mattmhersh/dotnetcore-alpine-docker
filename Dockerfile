FROM microsoft/dotnet-nightly:2.1-sdk AS build-env
WORKDIR /app

COPY /webfilter.ascensus.com.crt ./
Add /webfilter.ascensus.com.crt /usr/local/share/ca-certificates/webfilter.ascensus.com.crt
RUN update-ca-certificates --verbose


# copy csproj and restore as distinct layers
COPY *.csproj ./
COPY NuGet.config ./
RUN dotnet restore

# copy everything else and build
COPY . ./
RUN dotnet publish -c Release -o out --no-restore


# build runtime image
#FROM microsoft/dotnet-nightly:2.1-runtime-alpine AS runtime
FROM microsoft/dotnet-nightly:2.1-runtime-alpine AS runtime
RUN apk add --no-cache libuv \
 && ln -s /usr/lib/libuv.so.1 /usr/lib/libuv.so
ENV ASPNETCORE_URLS http://+:80

WORKDIR /app
COPY --from=build-env /app/out ./
ENTRYPOINT ["dotnet", "demo.dll"]
#ENV ASPNETCORE_URLS http://*:5000
#EXPOSE 5000
