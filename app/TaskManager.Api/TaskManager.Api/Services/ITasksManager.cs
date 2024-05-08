using TaskManager.Api.Models;

namespace TaskManager.Api.Services
{
    public interface ITasksManager
    {
        Task<List<TaskModel>> GetTasksByCreator(string createdBy);
        Task<TaskModel?> GetTaskById(Guid taskId);
        Task<Guid> CreateNewTask(string taskName, string createdBy, string assignedTo, DateTime dueDate);
        Task<bool> UpdateTask(Guid taskId, string taskName, string assignedTo, DateTime dueDate);
        Task<bool> MarkTaskCompleted(Guid taskId);
        Task<bool> DeleteTask(Guid taskId);
        Task MarkOverdueTasks(List<TaskModel> overdueTasksList);
        Task<List<TaskModel>> GetYesterdaysDueTasks();
    }
}
