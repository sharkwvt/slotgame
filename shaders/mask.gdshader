shader_type canvas_item;
uniform float progress : hint_range(0,1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if (UV.y < 1.0 - progress) {
        COLOR.a = 0.0;
    }
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
