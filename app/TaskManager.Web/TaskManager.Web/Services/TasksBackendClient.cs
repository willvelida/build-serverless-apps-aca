using Refit;
using TaskManager.Web.Models;

namespace TaskManager.Web.Services
{
    public class TasksBackendClient : ITasksBackendClient
    {
        IHttpClientFactory _httpClientFactory;

        public TasksBackendClient(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public async Task<List<TaskModel>> GetTasksCreatedBy(string taskCreatedBy)
        {
            var client = _httpClientFactory.CreateClient("Tasks");
            return await RestService.For<ITasksBackendClient>(client).GetTasksCreatedBy(taskCreatedBy);
        }
    }
}
