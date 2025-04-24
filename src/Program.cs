using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Shorten.Areas.Identity.Data;
using Shorten.Areas.Domain;

var builder = WebApplication.CreateBuilder(args);

// Obtener la cadena de conexión para la base de datos de identidad
var connectionString = builder.Configuration.GetConnectionString("ShortenIdentityDbContextConnection") 
                       ?? throw new InvalidOperationException("Connection string 'ShortenIdentityDbContextConnection' not found.");

// Configurar el contexto de la base de datos para Identity
builder.Services.AddDbContext<ShortenIdentityDbContext>(options => 
    options.UseSqlServer(connectionString));

// Configurar el servicio de identidad
builder.Services.AddDefaultIdentity<IdentityUser>(options => 
    options.SignIn.RequireConfirmedAccount = true)
    .AddEntityFrameworkStores<ShortenIdentityDbContext>();

// Configurar el contexto de la base de datos para ShortenContext
builder.Services.AddDbContext<ShortenContext>(options => 
    options.UseSqlServer(connectionString));

// Configurar la adaptación de QuickGrid para Entity Framework
builder.Services.AddQuickGridEntityFrameworkAdapter();

// Agregar servicios al contenedor
builder.Services.AddRazorPages();

var app = builder.Build();

// Configurar el pipeline de solicitudes HTTP
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // El valor predeterminado de HSTS es 30 días. Puedes cambiar esto para escenarios de producción.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapRazorPages();

app.Run();
