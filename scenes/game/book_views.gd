extends Control
class_name BookViews

var book_img_path = "res://image/book"

@export var game_scene: GameScene
@export var forward_view: TextureRect
@export var back_view: TextureRect
@export var return_btn: ButtonEx

var progress: int
var book_imgs = []
var return_view: GameScene.VIEW_STATE
var tween: Tween
var is_anim_playing: bool


var max_img_count = 50
var duration = 0.5

func _ready() -> void:
	return_btn.pressed.connect(game_scene.return_scene)
	refresh_view()

func page_up():
	if is_anim_playing:
		return
	if Main.game_data.progress <= progress:
		Main.show_tip("未解鎖")
		return
	if progress >= max_img_count:
		Main.show_tip("到底了")
		return
	is_anim_playing = true
	back_view.texture = load_book_imgs(progress + 1)
	forward_view.texture = load_book_imgs(progress)
	set_shader_material(0.0, "progress")
	tween = forward_view.create_tween()
	tween.tween_method(set_shader_material.bind("progress"), 0.0, 1.0, duration)
	tween.finished.connect(
		func ():
			progress += 1
			tween.kill()
			is_anim_playing = false
	)

func page_down():
	if is_anim_playing:
		return
	if progress <= 0:
		return
	is_anim_playing = true
	back_view.texture = load_book_imgs(progress)
	forward_view.texture = load_book_imgs(progress - 1)
	set_shader_material(1.0, "progress")
	tween = forward_view.create_tween()
	tween.tween_method(set_shader_material.bind("progress"), 1.0, 0.0, duration)
	tween.finished.connect(
		func ():
			progress -= 1
			tween.kill()
			is_anim_playing = false
	)


func set_shader_material(value: float, param: String):
	var shader_material: ShaderMaterial = forward_view.material
	shader_material.set_shader_parameter(param, value)


func refresh_view():
	forward_view.texture = load_book_imgs(progress)
	set_shader_material(0.0, "progress")


func load_book_imgs(index) -> Texture:
	if book_imgs.size() <= index:
		book_imgs.resize(index + 1)
		
	var texture: Texture
	if !book_imgs[index]:
		var path: String
		if index == 0:
			path = book_img_path.path_join("sex_book.png")
		else:
			path = book_img_path.path_join("content").path_join(str("slot_sex_", index, ".png"))
		if FileAccess.file_exists(path):
			book_imgs[index] = load(path)
	texture = book_imgs[index]
	
	return texture


func _input(event):
	# 滑鼠任何鍵
	if event is InputEventMouseButton and event.pressed and visible:
		if (event as InputEventMouseButton).is_action("page_up"):
			page_up()
		elif (event as InputEventMouseButton).is_action("page_down"):
			page_down()
