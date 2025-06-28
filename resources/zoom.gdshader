shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture,filter_nearest;
uniform vec2 zoom_center;
uniform float zoom_amount;
uniform bool keep_within_bounds;

void fragment() {
    // Coordinate UV dell'immagine originale
    vec2 uv = SCREEN_UV;

    // Calcolo delle coordinate UV traslate rispetto al centro dello zoom
    vec2 zoomed_uv = (uv - zoom_center) * zoom_amount + zoom_center;

    // Se keep_within_bounds è abilitato, limita le coordinate UV all'intervallo (0-1)
    if (keep_within_bounds) {
        zoomed_uv = clamp(zoomed_uv, vec2(0.0), vec2(1.0));
    }

    // Se le coordinate UV traslate sono fuori dai limiti (0-1), imposta il colore del pixel trasparente
    if (zoomed_uv.x < 0.0 || zoomed_uv.x > 1.0 || zoomed_uv.y < 0.0 || zoomed_uv.y > 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        // Altrimenti, leggi il colore dell'immagine originale alle coordinate UV traslate
        vec2 tex_uv = vec2(zoomed_uv.x, 1.0 - zoomed_uv.y);
        COLOR = texture(screen_texture, tex_uv, 0.0);
    }
}