using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using TaskManager.Web.Pages.Tasks.Models;

namespace TaskManager.Web.Pages.Tasks
{
    public class EditModel : PageModel
    {
        private readonly DaprClient _daprClient;

        [BindProperty]
        public TaskUpdateModel? TaskUpdate { get; set; }
        public string? TasksCreatedBy { get; set; }

        public EditModel(DaprClient daprClient)
        {
            _daprClient = daprClient;
        }

        public async Task<IActionResult> OnGetAsync(Guid? id)
        {
            TasksCreatedBy = Request.Cookies["TasksCreatedByCookie"];

            if (String.IsNullOrEmpty(TasksCreatedBy))
            {
                return RedirectToPage("../Index");
            }

            if (id == null)
            {
                return NotFound();
            }

            // direct svc to svc http request
            var Task = await _daprClient.InvokeMethodAsync<TaskModel>(HttpMethod.Get, "taskmanager-backend-api", $"api/tasks/{id}");

            if (Task == null)
            {
                return NotFound();
            }

            TaskUpdate = new TaskUpdateModel()
            {
                TaskId = Task.TaskId,
                TaskName = Task.TaskName,
                TaskAssignedTo = Task.TaskAssignedTo,
                TaskDueDate = Task.TaskDueDate,
            };

            return Page();
        }

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            if (TaskUpdate != null)
            {
                await _daprClient.InvokeMethodAsync<TaskUpdateModel>(HttpMethod.Put, "taskmanager-backend-api", $"api/tasks/{TaskUpdate.TaskId}", TaskUpdate);
            }

            return RedirectToPage("./Index");
        }
    }
}
