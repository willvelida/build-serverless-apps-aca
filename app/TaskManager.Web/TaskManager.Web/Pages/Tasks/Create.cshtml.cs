using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using TaskManager.Web.Pages.Tasks.Models;

namespace TaskManager.Web.Pages.Tasks
{
    public class CreateModel : PageModel
    {
        private readonly IHttpClientFactory _httpClientFactory;
        public CreateModel(IHttpClientFactory httpClientFactory)
        {
            _httpClientFactory = httpClientFactory;
        }
        public string? TasksCreatedBy { get; set; }

        public IActionResult OnGet()
        {
            TasksCreatedBy = Request.Cookies["TasksCreatedByCookie"];

            return (!String.IsNullOrEmpty(TasksCreatedBy)) ? Page() : RedirectToPage("../Index");
        }

        [BindProperty]
        public TaskAddModel? TaskAdd { get; set; }

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            if (TaskAdd != null)
            {
                var createdBy = Request.Cookies["TasksCreatedByCookie"];

                if (!string.IsNullOrEmpty(createdBy))
                {
                    TaskAdd.TaskCreatedBy = createdBy;

                    // direct svc to svc http request
                    var httpClient = _httpClientFactory.CreateClient("TasksApi");
                    var result = await httpClient.PostAsJsonAsync("api/tasks/", TaskAdd);
                }
            }

            return RedirectToPage("./Index");
        }
    }
}
