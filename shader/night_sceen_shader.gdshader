shader_type canvas_item;
render_mode unshaded;

uniform mat4 global_transform;

uniform sampler2D light_data;
uniform int lights_count = 0;

uniform float camera_zoom_factor = 1.0;

uniform vec4 night_screen_color : hint_color = vec4(0.13, 0.13, 0.13, 1.0); // red, green, blue, alpha
uniform vec4 default_light_color : hint_color;

uniform float light_strength_modifier : hint_range(0.0, 1.0) = 1.0;

varying vec2 world_position;

void vertex() {
	// Set new pixel position
	world_position = (global_transform * vec4(VERTEX * vec2(camera_zoom_factor, camera_zoom_factor), camera_zoom_factor, camera_zoom_factor)).xy;
}

void fragment() {
	// floor() the world_position so that it matches the native resolution
	// Set the current pixel position
	vec2 pixel_position = floor(world_position);
	float min_shading_value = 0.0; // 0.0 = dark; 1.0 = light
	vec4 light_color = default_light_color;
	
	// Iterate over every light
	for(int i = 0; i < lights_count; i++) {
		// Get specific light_informations from the texture which was passed
		vec4 light_informations = texelFetch(light_data, ivec2(i, 0), 0);
		
		// Alpha channel -> radius informations
		float radius = light_informations.a;
		// Blue channel -> light strength informations
		float strength = light_informations.b * 1.0;

		// Red & green channel -> light positions x & y then normalize
		float dist = distance(light_informations.xy, pixel_position);
		dist = min(dist / radius, 1.0);
		
		// Get shading value of the pixel with the distance to the light
		float shading_value = 0.0;
		
		// Calcuate shading value
		shading_value = (1.0 - dist) * strength * light_strength_modifier;
		
		shading_value = clamp(shading_value, 0.0, 1.0);
		if(shading_value > min_shading_value) {
			min_shading_value = shading_value;
			light_color = texelFetch(light_data, ivec2(i, 1), 0);
		}
	}
	
	// mix darkness with light based on light level
	vec4 ambient_color = mix(night_screen_color, light_color, min_shading_value);

	// get screen color for this pixel
	vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	// apply multiply blend mode
	COLOR = screen_color * ambient_color;
	
}