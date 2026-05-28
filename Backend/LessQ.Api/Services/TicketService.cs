using LessQ.Api.Models;
using MongoDB.Driver;

namespace LessQ.Api.Services;

public class TicketService
{
    private readonly IMongoCollection<PrintTicket> _tickets;

    public TicketService(IMongoDatabase database)
    {
        _tickets = database.GetCollection<PrintTicket>("tickets");
        _ = EnsureIndexAsync();
    }

    private async Task EnsureIndexAsync()
    {
        try
        {
            await _tickets.Indexes.CreateOneAsync(
                new CreateIndexModel<PrintTicket>(
                    Builders<PrintTicket>.IndexKeys.Ascending(t => t.TicketNumber)));
        }
        catch { /* Se reintentará en el próximo restart */ }
    }

    public async Task<PrintTicket?> GetByIdAsync(string id) =>
        await _tickets.Find(t => t.Id == id).FirstOrDefaultAsync();

    public async Task<PrintTicket> CreateAsync(PrintTicket ticket)
    {
        var last = await _tickets
            .Find(_ => true)
            .SortByDescending(t => t.TicketNumber)
            .FirstOrDefaultAsync();

        ticket.TicketNumber = (last?.TicketNumber ?? 0) + 1;
        ticket.CreatedAt = DateTime.UtcNow;
        ticket.UpdatedAt = DateTime.UtcNow;

        await _tickets.InsertOneAsync(ticket);
        return ticket;
    }

    public async Task<bool> UpdateStatusAsync(string id, string status)
    {
        var result = await _tickets.UpdateOneAsync(
            t => t.Id == id,
            Builders<PrintTicket>.Update
                .Set(t => t.Status, status)
                .Set(t => t.UpdatedAt, DateTime.UtcNow));
        return result.ModifiedCount > 0;
    }

    public async Task<int> GetQueuePositionAsync(string id)
    {
        var ticket = await GetByIdAsync(id);
        if (ticket is null || ticket.Status != "pending") return 0;

        var ahead = await _tickets.CountDocumentsAsync(
            t => t.Status == "pending" && t.TicketNumber < ticket.TicketNumber);
        return (int)ahead + 1;
    }

    public async Task<int?> GetCurrentServingAsync() =>
        (await _tickets
            .Find(t => t.Status == "in_progress")
            .SortByDescending(t => t.TicketNumber)
            .FirstOrDefaultAsync())?.TicketNumber;

    public async Task<long> GetPendingCountAsync() =>
        await _tickets.CountDocumentsAsync(t => t.Status == "pending");

    public async Task<List<int>> GetPendingTicketNumbersAsync() =>
        (await _tickets
            .Find(t => t.Status == "pending")
            .SortBy(t => t.TicketNumber)
            .Limit(20)
            .ToListAsync())
            .Select(t => t.TicketNumber)
            .ToList();
}
