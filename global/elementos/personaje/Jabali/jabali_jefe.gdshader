shader_type canvas_item;

// Un color de entrada para que puedas ajustarlo desde el Inspector si es necesario.
// Por defecto es blanco puro.
uniform vec4 color_to_remove : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Un umbral para eliminar colores "cercanos" al blanco (útil para bordes).
uniform float threshold : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 current_color = texture(TEXTURE, UV);

    // Calculamos la distancia (diferencia de color) entre el píxel actual y el blanco
    float dist = distance(current_color.rgb, color_to_remove.rgb);

    // Si la distancia es menor que el umbral, descartamos el píxel (lo hacemos transparente)
    if (dist < threshold) {
        discard; // Desecha el píxel
    }

    // De lo contrario, mantenemos el color original
    COLOR = current_color;
}
