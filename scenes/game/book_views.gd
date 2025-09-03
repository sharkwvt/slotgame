extends Control
class_name BookViews

var book_img_path = "res://image/book/content"

@export var lock_img: Texture
@export var game_scene: GameScene
@export var forward_view_l: TextureRect
@export var back_view_l: TextureRect
@export var forward_view_r: TextureRect
@export var back_view_r: TextureRect
@export var next_btn: ButtonEx
@export var back_btn: ButtonEx
@export var return_btn: ButtonEx

var index: int
var book_imgs = []
var return_view: GameScene.VIEW_STATE
var tween: Tween

var max_img_count = 50
var duration = 0.5

func _ready() -> void:
	next_btn.pressed.connect(page_next)
	back_btn.pressed.connect(page_back)
	return_btn.pressed.connect(game_scene.return_scene)
	refresh_view()

func page_next():
	if tween and tween.is_running():
		return
	if index >= int((max_img_count - 1) / 2.0):
		Main.show_tip("到底了")
		return
	if int((Main.game_data.progress - 1) / 2.0) <= index:
		Main.show_tip("未解鎖")
		return
	back_view_l.texture = load_book_imgs(index * 2)
	forward_view_r.texture = load_book_imgs(index * 2 + 1)
	set_shader_material(0.0, forward_view_r.material, "progress")
	index += 1
	forward_view_l.texture = load_book_imgs(index * 2)
	back_view_r.texture = load_book_imgs(index * 2 + 1)
	set_shader_material(1.0, forward_view_l.material, "progress")
	tween = create_tween()
	tween.tween_method(
		set_shader_material.bind(forward_view_r.material, "progress"),
		0.0,
		1.0,
		duration
	)
	tween.parallel().tween_method(
		set_shader_material.bind(forward_view_l.material, "progress"),
		1.0,
		0.0,
		duration
	).set_delay(duration / 2.0)
	tween.finished.connect(tween.kill)

func page_back():
	if tween and tween.is_running():
		return
	if index <= 0:
		return
	forward_view_l.texture = load_book_imgs(index * 2)
	back_view_r.texture = load_book_imgs(index * 2 + 1)
	set_shader_material(0.0, forward_view_l.material, "progress")
	index -= 1
	back_view_l.texture = load_book_imgs(index * 2)
	forward_view_r.texture = load_book_imgs(index * 2 + 1)
	set_shader_material(1.0, forward_view_r.material, "progress")
	tween = create_tween()
	tween.tween_method(
		set_shader_material.bind(forward_view_l.material, "progress"),
		0.0,
		1.0,
		duration
	)
	tween.parallel().tween_method(
		set_shader_material.bind(forward_view_r.material, "progress"),
		1.0,
		0.0,
		duration
	).set_delay(duration / 2.0)
	tween.finished.connect(tween.kill)

func new_page_anim():
	var progress = Main.game_data.progress
	index = int((progress - 1) / 2.0)
	refresh_view()
	
	var flip_page: TextureRect
	if progress % 2 > 0:
		back_view_r.texture = lock_img
		forward_view_r.texture = load_book_imgs(index * 2 + 1)
		flip_page = forward_view_r
	else:
		back_view_l.texture = lock_img
		forward_view_l.texture = load_book_imgs(index * 2)
		flip_page = forward_view_l
	
	await tween.finished
	tween = create_tween()
	tween.tween_method(
		set_shader_material.bind(flip_page.material, "progress"),
		1.0,
		0.0,
		duration
	)
	tween.finished.connect(tween.kill)


func set_index(value: int):
	var max_index = int(max_img_count / 2.0)
	index = value if value < max_index else max_index
	refresh_view()

func set_shader_material(value: float, sm: ShaderMaterial, param: String):
	sm.set_shader_parameter(param, value)


func refresh_view():
	set_shader_material(1.0, forward_view_l.material, "progress")
	set_shader_material(1.0, forward_view_r.material, "progress")
	back_view_l.texture = load_book_imgs(index * 2)
	back_view_r.texture = load_book_imgs(index * 2 + 1)

func show_anim():
	self.modulate.a = 0.0
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.finished.connect(tween.kill)

func hide_anim():
	if tween and tween.is_running():
		return
	self.modulate.a = 1.0
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5)
	tween.finished.connect(tween.kill)


func load_book_imgs(i) -> Texture:
	if book_imgs.size() < i + 1:
		book_imgs.resize(i + 1)
		
	var texture: Texture
	if i < Main.game_data.progress and i < max_img_count:
		if !book_imgs[i]:
			var path = book_img_path.path_join(str("sex_image_", i + 1, ".jpg"))
			if FileAccess.file_exists(path):
				book_imgs[i] = load(path)
		texture = book_imgs[i]
	else:
		texture = lock_img
	
	return texture


func _input(event: InputEvent):
	# 滑鼠任何鍵
	if visible:
		if event.is_action("page_next"):
			page_next()
		elif event.is_action("page_back"):
			page_back()
