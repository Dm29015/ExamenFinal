using Microsoft.EntityFrameworkCore;
using peajeAPI.Models;

namespace peajeAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext() { }
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }
        public DbSet<Peaje> Peaje { get; set; }
    }
}
