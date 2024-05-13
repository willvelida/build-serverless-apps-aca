using Dapr.Client;
using Microsoft.AspNetCore.Http.HttpResults;
using TaskManager.Svc.Models;

namespace TaskManager.Svc.EndpointHandlers
{
    public static class TasksNotifierHandlers
    {
        public static async Task<Ok<string>> TaskSaved(
            ILogger logger,
            DaprClient daprClient,
            TaskModel taskModel)
        {
            var msg = string.Format("Started processing message with Task Name '{0}'", taskModel.TaskName);
            logger.LogInformation("Started processing message with Task Name '{0}'", taskModel.TaskName);

            return TypedResults.Ok(msg);
        }
    }
}
