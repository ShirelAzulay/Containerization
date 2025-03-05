using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Our.Umbraco.StorageProviders.AWSS3.DependencyInjection;  // זה המרחב השמות הנכון
using Umbraco.Cms.Web.Common.DependencyInjection;

var builder = WebApplication.CreateBuilder(args);

builder.CreateUmbracoBuilder()
    .AddBackOffice()
    .AddWebsite()
    .AddDeliveryApi()
    .AddComposers()
    // Add the AWS S3 Storage file system
    .AddAWSS3MediaFileSystem()
    .Build();

var app = builder.Build();

await app.BootUmbracoAsync();

app.UseUmbraco()
    .WithMiddleware(u =>
    {
        u.UseBackOffice();
        u.UseWebsite();
        // Enables the AWS S3 Storage middleware for Media
        u.UseAWSS3MediaFileSystem();
    })
    .WithEndpoints(u =>
    {
        u.UseInstallerEndpoints();
        u.UseBackOfficeEndpoints();
        u.UseWebsiteEndpoints();
    });

await app.RunAsync();