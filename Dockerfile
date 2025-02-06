# ========== BUILD STAGE ==========
# Use .NET 8 SDK to compile and publish the project
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy the .csproj file and restore NuGet packages
COPY MyUmbracoProject.csproj ./
RUN dotnet restore MyUmbracoProject.csproj

# Copy the remaining project files and publish the application
COPY . .
RUN dotnet publish MyUmbracoProject.csproj -c Release -o /app/publish

# ========== RUNTIME STAGE ==========
# Use ASP.NET Runtime to run the published application
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Copy the published output from the build stage
COPY --from=build /app/publish .

# Create required directories and set permissions
RUN mkdir -p /app/wwwroot/media \
   /app/Data \
   /app/wwwroot/css \
   /app/wwwroot/js \
   /app/App_Plugins \
   /app/umbraco \
   /app/logs \
   && chmod -R 777 /app/Data \
   && chmod -R 777 /app/wwwroot/media \
   && chmod -R 777 /app/App_Plugins \
   && chmod -R 777 /app/umbraco \
   && chmod -R 777 /app/logs

# Set essential environment variables
ENV ASPNETCORE_URLS="http://+:80"                                             # Set URL configuration
ENV ASPNETCORE_ENVIRONMENT=Development                                        # Set development environment
ENV Umbraco__CMS__Global__InstallMissingDatabase=true                       # Allow missing database installation
ENV Umbraco__CMS__Hosting__Debug=true                                       # Enable debug mode
ENV ASPNETCORE_LOGGING__CONSOLE__DISABLECOLORS=true                         # Disable colors in logs
ENV Umbraco__CMS__Global__Id="00000000-0000-0000-0000-000000000042"        # Set unique system ID
ENV Umbraco__CMS__Unattended__InstallUnattended=true                       # Enable unattended installation
ENV Umbraco__CMS__Unattended__UnattendedUserName="admin"                   # Set admin username
ENV Umbraco__CMS__Unattended__UnattendedUserEmail="admin@example.com"      # Set admin email
ENV Umbraco__CMS__Unattended__UnattendedUserPassword="AdminPassword123!"   # Set admin password
ENV ConnectionStrings__umbracoDbDSN="Data Source=|DataDirectory|/Umbraco.sqlite.db;Cache=Shared;Foreign Keys=True;Pooling=True"  # Database connection string
ENV Umbraco__CMS__Global__MainDomLock="FileSystemMainDomLock"              # Set filesystem lock configuration

# Expose port 80 for communication
EXPOSE 80

# Set the entry point for the container
ENTRYPOINT ["dotnet", "MyUmbracoProject.dll"]