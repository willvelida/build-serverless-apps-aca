using System.ComponentModel.DataAnnotations;

namespace TaskManager.Web.Pages.Tasks.Models
{
    public class TaskUpdateModel
    {
        public Guid TaskId { get; set; }

        [Display(Name = "Task Name")]
        [Required]
        public string TaskName { get; set; } = string.Empty;

        [Display(Name = "Task DueDate")]
        [Required]
        public DateTime TaskDueDate { get; set; }

        [Display(Name = "Assigned To")]
        [Required]
        public string TaskAssignedTo { get; set; } = string.Empty;
    }
}
