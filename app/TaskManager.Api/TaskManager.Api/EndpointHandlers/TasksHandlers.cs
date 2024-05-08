using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using TaskManager.Api.Models;
using TaskManager.Api.Services;

namespace TaskManager.Api.EndpointHandlers
{
    public static class TasksHandlers
    {
        public static async Task<Ok<List<TaskModel>>> GetTasksByCreator(
            ITasksManager tasksManager,
            string createdBy)
        {
            return TypedResults.Ok(await tasksManager.GetTasksByCreator(createdBy));
        }

        public static async Task<Results<NotFound, Ok<TaskModel>>> GetTaskById(
            ITasksManager tasksManager,
            Guid taskId)
        {
            var task = await tasksManager.GetTaskById(taskId);
            if (task != null)
            {
                return TypedResults.Ok(task);
            }

            return TypedResults.NotFound();
        }

        public static async Task<CreatedAtRoute> CreateTask(
            ITasksManager tasksManager,
            [FromBody] TaskAddModel taskAddModel)
        {
            var taskId = await tasksManager.CreateNewTask(
                taskAddModel.TaskName,
                taskAddModel.TaskCreatedBy,
                taskAddModel.TaskAssignedTo,
                taskAddModel.TaskDueDate);

            return TypedResults.CreatedAtRoute(
                $"/api/tasks/{taskId}",
                null);
        }

        public static async Task<Results<Ok, BadRequest>> UpdateTask(
            ITasksManager tasksManager,
            Guid taskId,
            [FromBody] TaskUpdateModel taskUpdateModel)
        {
            var updated = await tasksManager.UpdateTask(
                taskId,
                taskUpdateModel.TaskName,
                taskUpdateModel.TaskAssignedTo,
                taskUpdateModel.TaskDueDate);

            if (updated)
            {
                return TypedResults.Ok();
            }

            return TypedResults.BadRequest();
        }

        public static async Task<Results<Ok, BadRequest>> MarkTaskAsComplete(
            ITasksManager tasksManager,
            Guid taskId)
        {
            var updated = await tasksManager.MarkTaskCompleted(taskId);

            if (updated)
            {
                return TypedResults.Ok();
            }

            return TypedResults.BadRequest();
        }

        public static async Task<Results<Ok, NotFound>> DeleteTask(
            ITasksManager tasksManager,
            Guid taskId)
        {
            var deleted = await tasksManager.DeleteTask(taskId);
            if (deleted)
            {
                return TypedResults.Ok();
            }

            return TypedResults.NotFound();
        }
    }
}
