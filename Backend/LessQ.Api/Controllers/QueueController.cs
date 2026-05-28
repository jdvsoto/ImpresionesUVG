using LessQ.Api.Services;
using Microsoft.AspNetCore.Mvc;

namespace LessQ.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class QueueController : ControllerBase
{
    private readonly TicketService _tickets;

    public QueueController(TicketService tickets) => _tickets = tickets;

    [HttpGet]
    public async Task<IActionResult> GetStatus()
    {
        var currentServing = await _tickets.GetCurrentServingAsync();
        var pendingCount = await _tickets.GetPendingCountAsync();
        var pendingTickets = await _tickets.GetPendingTicketNumbersAsync();

        return Ok(new
        {
            currentServingTicket = currentServing,
            totalWaiting = pendingCount,
            pendingTickets
        });
    }
}
