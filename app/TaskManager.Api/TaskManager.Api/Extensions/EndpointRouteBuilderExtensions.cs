using TaskManager.Api.EndpointHandlers;

namespace TaskManager.Api.Extensions
{
    public static class EndpointRouteBuilderExtensions
    {
        public static void RegisterTasksEndpoints(this IEndpointRouteBuilder endpointRouteBuilder)
        {
            var tasksEndpoints = endpointRouteBuilder.MapGroup("/api/tasks");

            tasksEndpoints.MapGet("", TasksHandlers.GetTasksByCreator)
                .WithName("GetTasksByCreator");

            tasksEndpoints.MapGet("{taskId:guid}", TasksHandlers.GetTaskById)
                .WithName("GetTasksById");

            tasksEndpoints.MapPut("{taskId:guid}", TasksHandlers.UpdateTask)
                .WithName("UpdateTask");

            tasksEndpoints.MapPost("", TasksHandlers.CreateTask)
                .WithName("CreateTask");

            tasksEndpoints.MapPut("{taskId:guid}/markcomplete", TasksHandlers.MarkTaskAsComplete)
                .WithName("MarkTaskAsComplete");

            tasksEndpoints.MapDelete("{taskId:guid}", TasksHandlers.DeleteTask)
                .WithName("DeleteTask");
        }
    }
}
