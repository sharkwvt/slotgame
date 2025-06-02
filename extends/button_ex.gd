extends Button
class_name ButtonEx

func _init() -> void:
	button_down.connect(_on_button_down)
	resized.connect(_on_resize)
	focus_mode = FOCUS_NONE
	set_pivot_center()


func set_pivot_center():
	pivot_offset = Vector2(size.x/2.0, size.y/2.0)


func _on_button_down() -> void:
	Main.play_btn_sfx()

func _on_resize():
	set_pivot_center()
