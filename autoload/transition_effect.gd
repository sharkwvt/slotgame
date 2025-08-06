extends Node

var main: Control
var viewport: SubViewport
var texture_rect: TextureRect
var shader_material: ShaderMaterial
var tween: Tween

signal anim_finished

# anim_type: 0 淡出, 1 移出
func start_transition(scene: Node, anim_type = 0, duration: float = 1.0):
	main = Control.new()
	get_tree().root.add_child(main)
	setup_viewport()
	setup_mask()
	setup_texture_rect()
	var org_parent = scene.get_parent()
	scene.reparent(viewport) # viewport只投射子節點
	if anim_type != 1:
		apply_shader(anim_type)
	set_tween(anim_type, duration)
	tween.finished.connect(_on_tween_finished.bind(scene, org_parent))


func setup_viewport():
	viewport = SubViewport.new()
	#viewport.size = get_viewport().size
	viewport.size = Main.screen_size
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	main.add_child(viewport)

func setup_mask():
	var mask = ColorRect.new()
	mask.size = get_viewport().size
	mask.color = Color.hex(0)
	main.add_child(mask)

func setup_texture_rect():
	texture_rect = TextureRect.new()
	texture_rect.texture = viewport.get_texture()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
	#texture_rect.size = get_viewport().size
	texture_rect.size = Main.screen_size
	main.add_child(texture_rect)

func apply_shader(anim_type = 0):
	shader_material = ShaderMaterial.new()
	shader_material.shader = Shader.new()
	match anim_type:
		_: # 淡出效果
			shader_material.shader.code = """
				shader_type canvas_item;
				uniform float progress : hint_range(0,1);
				void fragment() {
					vec4 color = texture(TEXTURE, UV);
					color.a *= smoothstep(1.0, 0.0, progress);
					COLOR = color;
				}
			"""
	shader_material.set_shader_parameter("progress", 0.0)
	texture_rect.material = shader_material

func set_tween(anim_type = 0, duration: float = 1.0):
	if tween:
		tween.kill()
	tween = main.create_tween()
	match anim_type:
		1: # 左移出
			tween.tween_property(texture_rect, "position:x", -texture_rect.size.x, duration)
		2: # 放大+移動+跑shader
			tween.set_parallel(true)
			tween.tween_property(texture_rect, "position", -get_viewport().get_mouse_position(), duration)
			tween.tween_property(texture_rect, "scale", Vector2(2, 2), duration)
			tween.tween_property(shader_material, "shader_parameter/progress", 1.0, duration)
		_: # 跑shader
			tween.tween_property(shader_material, "shader_parameter/progress", 1.0, duration)


func skip_anim():
	main.visible = false


func _on_tween_finished(scene: Control, org_parent: Node):
	scene.visible = false # reparent會移到最前，需要隱藏
	scene.reparent(org_parent)
	main.queue_free()
	anim_finished.emit()
