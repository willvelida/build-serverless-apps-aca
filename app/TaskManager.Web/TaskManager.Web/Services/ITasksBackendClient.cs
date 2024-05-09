using Refit;
using TaskManager.Web.Models;

namespace TaskManager.Web.Services
{
    public interface ITasksBackendClient
    {
        [Get("/api/tasks/?createdBy={taskCreatedBy}")]
        Task<List<TaskModel>> GetTasksCreatedBy(string taskCreatedBy);
    }
}
