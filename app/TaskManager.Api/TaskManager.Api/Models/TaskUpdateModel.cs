namespace TaskManager.Api.Models
{
    public class TaskUpdateModel
    {
        public Guid TaskId { get; set; }
        public string TaskName { get; set; } = string.Empty;
        public DateTime TaskDueDate { get; set; }
        public string TaskAssignedTo { get; set; } = string.Empty;
    }
}
