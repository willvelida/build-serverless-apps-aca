using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using TaskManager.Web.Pages.Tasks.Models;

namespace TaskManager.Web.Pages.Tasks
{
    public class IndexModel : PageModel
    {
        private readonly IHttpClientFactory _httpClientFactory;
        public List<TaskModel?> TasksList { get; set; }

        [BindProperty]
        public string? TasksCreatedBy { get; set; }

        public IndexModel(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }

        public async Task<IActionResult> OnGetAsync()
        {
            TasksCreatedBy = Request.Cookies["TasksCreatedByCookie"];

            if (!String.IsNullOrEmpty(TasksCreatedBy))
            {
                // direct svc to svc http request
                var httpClient = _httpClientFactory.CreateClient("TasksApi");
                TasksList = await httpClient.GetFromJsonAsync<List<TaskModel>>($"api/tasks?createdBy={TasksCreatedBy}");
                return Page();
            }
            else
            {
                return RedirectToPage("../Index");
            }
        }

        public async Task<IActionResult> OnPostDeleteAsync(Guid id)
        {
            // direct svc to svc http request
            var httpClient = _httpClientFactory.CreateClient("BackEndApiExternal");
            var result = await httpClient.DeleteAsync($"api/tasks/{id}");
            return RedirectToPage();
        }

        public async Task<IActionResult> OnPostCompleteAsync(Guid id)
        {
            // direct svc to svc http request
            var httpClient = _httpClientFactory.CreateClient("BackEndApiExternal");
            var result = await httpClient.PutAsync($"api/tasks/{id}/markcomplete", null);
            return RedirectToPage();
        }

    }
}
