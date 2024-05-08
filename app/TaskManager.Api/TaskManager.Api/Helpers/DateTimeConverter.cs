using System.Text.Json.Serialization;
using System.Text.Json;

namespace TaskManager.Api.Helpers
{
    public class DateTimeConverter : JsonConverter<DateTime>
    {
        private readonly string _dateFormatString;

        public DateTimeConverter(string dateFormatString)
        {
            _dateFormatString = dateFormatString;
        }

        public override DateTime Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
        {
            return DateTime.ParseExact(reader.GetString(), _dateFormatString, System.Globalization.CultureInfo.InvariantCulture);
        }

        public override void Write(Utf8JsonWriter writer, DateTime value, JsonSerializerOptions options)
        {
            writer.WriteStringValue(value.ToString(_dateFormatString));
        }
    }
}
