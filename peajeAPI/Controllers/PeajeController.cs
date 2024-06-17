using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using peajeAPI.Data;
using peajeAPI.Models;

namespace peajeAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PeajeController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public PeajeController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Peaje
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Peaje>>> GetPeajes()
        {
            return await _context.Peaje.ToListAsync();
        }

        // GET: api/Peaje/5
        [HttpGet("{id}")]
        public async Task<ActionResult<Peaje>> GetPeaje(int id)
        {
            var peaje = await _context.Peaje.FindAsync(id);

            if (peaje == null)
            {
                return NotFound();
            }

            return peaje;
        }

        // POST: api/peaje
        [HttpPost]
        public async Task<ActionResult<Peaje>> PostPeajes(Peaje peaje)
        {
            if(peaje.Valor >= 0)
            {
                _context.Peaje.Add(peaje);
                await _context.SaveChangesAsync();

                return CreatedAtAction(nameof(GetPeaje), new { Id = peaje.Id }, peaje);
            }
            return BadRequest();
        }


        // PUT: api/Peaje/5
        [HttpPut("{id}")]
        public async Task<IActionResult> PutPeaje(int id, Peaje peaje)
        {
            if (id != peaje.Id)
            {
                return BadRequest();
            }

            _context.Entry(peaje).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!PeajeExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // DELETE: api/Peaje/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePeaje(int id)
        {
            var peaje = await _context.Peaje.FindAsync(id);
            if (peaje == null)
            {
                return NotFound();
            }

            _context.Peaje.Remove(peaje);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool PeajeExists(int id)
        {
            return _context.Peaje.Any(e => e.Id == id);
        }
    }
}
