using TaskManager.Api.Extensions;
using TaskManager.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDaprClient();
builder.Services.AddSingleton<ITasksManager, FakeTaskManager>();

var app = builder.Build();

// Configure the HTTP request pipeline.
app.UseHttpsRedirection();

app.RegisterTasksEndpoints();

app.Run();
