using LessQ.Api.Models;
using LessQ.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LessQ.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TicketsController : ControllerBase
{
    private readonly TicketService _tickets;

    public TicketsController(TicketService tickets) => _tickets = tickets;

    [HttpPost]
    [Consumes("multipart/form-data")]
    public async Task<IActionResult> Create([FromForm] CreateTicketRequest request)
    {
        if (request.File is null || request.File.Length == 0)
            return BadRequest(new { error = "No se adjuntó ningún archivo." });

        using var ms = new MemoryStream();
        await request.File.CopyToAsync(ms);

        var ticket = new PrintTicket
        {
            DocumentName = request.File.FileName,
            DocumentData = Convert.ToBase64String(ms.ToArray()),
            ContentType = request.File.ContentType,
            Options = new PrintOptions
            {
                Copies = request.Copies,
                Duplex = request.Duplex,
                ColorMode = request.ColorMode,
                PageRange = request.PageRange
            }
        };

        var created = await _tickets.CreateAsync(ticket);
        var position = await _tickets.GetQueuePositionAsync(created.Id!);

        return CreatedAtAction(nameof(GetById), new { id = created.Id },
            TicketDto.From(created, position));
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var ticket = await _tickets.GetByIdAsync(id);
        if (ticket is null) return NotFound();

        var position = await _tickets.GetQueuePositionAsync(id);
        return Ok(TicketDto.From(ticket, position));
    }

    [HttpPut("{id}/start")]
    public async Task<IActionResult> Start(string id)
    {
        var updated = await _tickets.UpdateStatusAsync(id, "in_progress");
        return updated ? NoContent() : NotFound();
    }

    [HttpPut("{id}/complete")]
    public async Task<IActionResult> Complete(string id)
    {
        var updated = await _tickets.UpdateStatusAsync(id, "completed");
        return updated ? NoContent() : NotFound();
    }
}

public class CreateTicketRequest
{
    public IFormFile? File { get; set; }
    public int Copies { get; set; } = 1;
    public bool Duplex { get; set; } = false;
    public string ColorMode { get; set; } = "bw";
    public string? PageRange { get; set; }
}

public record TicketDto(
    string Id,
    int TicketNumber,
    string DocumentName,
    PrintOptions Options,
    string Status,
    int QueuePosition,
    DateTime CreatedAt)
{
    public static TicketDto From(PrintTicket t, int pos) =>
        new(t.Id!, t.TicketNumber, t.DocumentName, t.Options, t.Status, pos, t.CreatedAt);
}
