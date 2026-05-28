using MongoDB.Bson;
using MongoDB.Bson.Serialization.Attributes;

namespace LessQ.Api.Models;

public class PrintTicket
{
    [BsonId]
    [BsonRepresentation(BsonType.ObjectId)]
    public string? Id { get; set; }

    public int TicketNumber { get; set; }
    public string DocumentName { get; set; } = string.Empty;
    public string DocumentData { get; set; } = string.Empty;
    public string ContentType { get; set; } = string.Empty;
    public PrintOptions Options { get; set; } = new();
    public string Status { get; set; } = "pending";
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
}

public class PrintOptions
{
    public int Copies { get; set; } = 1;
    public bool Duplex { get; set; } = false;
    public string ColorMode { get; set; } = "bw";
    public string? PageRange { get; set; }
}
