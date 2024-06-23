using System.ComponentModel.DataAnnotations;

namespace peajeAPI.Models
{
    public class Peaje
    {
        [Key]
        public int Id { get; set; }

        [Required(ErrorMessage = "La placa es obligatoria.")]

        [StringLength(10, ErrorMessage = "La placa no puede ser mayor a 6 caracteres.")]
        public required string Placa { get; set; }

        [Required(ErrorMessage = "El nombre del peaje es obligatorio.")]
        [RegularExpression(@"^[A-Za-z\s]+$", ErrorMessage = "El nombre del peaje solo debe contener letras y espacios.")]
        [StringLength(100, ErrorMessage = "El nombre del peaje no puede exceder los 100 caracteres.")]
        public required string NombrePeaje { get; set; }

        [Required(ErrorMessage = "La categoría de la tarifa es obligatoria.")]
        [RegularExpression("^(I|II|III|IV|V)$", ErrorMessage = "La categoría de la tarifa solo puede ser I, II, III, IV o V.")]
        public required string IdCategoriaTarifa { get; set; }

        [Required(ErrorMessage = "La fecha de registro es obligatoria.")]
        public required DateTime FechaRegistro { get; set; }

        [Required(ErrorMessage = "El valor es obligatorio.")]
        [Range(0, double.MaxValue, ErrorMessage = "El valor debe ser mayor o igual a 0.")]
        public required decimal Valor { get; set; }
     
        [Range(0, double.MaxValue, ErrorMessage = "El valor debe ser mayor o igual a 0.")]
        public string? ValorDolar { get; set; }
        
    }
}
