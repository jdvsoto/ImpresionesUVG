using LessQ.Api.Services;
using MongoDB.Driver;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();

var mongoConfig = builder.Configuration.GetSection("MongoDB");
var mongoClient = new MongoClient(mongoConfig["ConnectionString"]);
builder.Services.AddSingleton<IMongoClient>(mongoClient);
builder.Services.AddSingleton<IMongoDatabase>(
    mongoClient.GetDatabase(mongoConfig["DatabaseName"]));
builder.Services.AddSingleton<TicketService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
    app.MapOpenApi();

app.MapControllers();
app.Run();
