namespace TaskManager.Api.Models
{
    public class TaskAddModel
    {
        public string TaskName { get; set; } = string.Empty;
        public string TaskCreatedBy { get; set; } = string.Empty;
        public DateTime TaskDueDate { get; set; }
        public string TaskAssignedTo { get; set; } = string.Empty;
    }
}
