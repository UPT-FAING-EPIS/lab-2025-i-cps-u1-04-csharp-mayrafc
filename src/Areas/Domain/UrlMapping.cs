namespace Shorten.Areas.Domain;

/// <summary>
/// Clase de dominio que representa una acortación de URL
/// </summary>
public class UrlMapping
{
    /// <summary>
    /// Identificador del mapeo de URL
    /// </summary>
    /// <value>Entero</value>
    public int Id { get; set; }

    /// <summary>
    /// Valor original de la URL
    /// </summary>
    /// <value>Cadena</value>
    public string OriginalUrl { get; set; } = string.Empty;

    /// <summary>
    /// Valor corto de la URL
    /// </summary>
    /// <value>Cadena</value>
    public string ShortenedUrl { get; set; } = string.Empty;
}
