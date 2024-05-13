using TaskManager.Svc.EndpointHandlers;

namespace TaskManager.Svc.Extensions
{
    public static class EndpointRouteBuilderExtensions
    {
        public static void RegisterTasksNotifierEndpoint(this IEndpointRouteBuilder endpointRouteBuilder)
        {
            var tasksNotifierEndpoints = endpointRouteBuilder.MapGroup("/api/tasksnotifier");

            tasksNotifierEndpoints.MapPost("/", TasksNotifierHandlers.TaskSaved)
                .WithName("tasksaved")
                .WithTopic("dapr-pubsub-servicebus", "tasksavedtopic");
        }
    }
}
