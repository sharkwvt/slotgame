extends Scene

@export var menu_btn: PackedScene
@export var menus_root: HBoxContainer
@export var scroll_view: ScrollContainer
@export var left_btn: ButtonEx
@export var right_btn: ButtonEx

var btns = []

func _ready() -> void:
	setup()

func setup():
	scroll_view.scroll_horizontal = true
	for data in Main.character_datas:
		var view = menu_btn.instantiate()
		view.set_data(data)
		(view.btn as ButtonEx).pressed.connect(start_game.bind(data))
		menus_root.add_child(view)
		btns.append(view)
	
	left_btn.pressed.connect(scroll_left)
	right_btn.pressed.connect(scroll_right)


func refresh():
	for btn in btns:
		btn.refresh()


func show_scene():
	refresh()

func return_scene():
	Main.to_scene(Main.SCENE.start)


func scroll_left():
	var scroll_index = 0
	var is_end = true
	for i in range(btns.size() - 1, -1, -1):
		if scroll_view.scroll_horizontal > btns[i].position.x:
			scroll_index = i
			is_end = false
			break
	if is_end:
		scroll_index = btns.size() - 1
	scroll_view.ensure_control_visible(btns[scroll_index])
	
func scroll_right():
	var scroll_index = 0
	var is_end = true
	for i in btns.size():
		if scroll_view.scroll_horizontal + scroll_view.size.x < btns[i].position.x + btns[i].size.x:
			scroll_index = i
			is_end = false
			break
	if is_end:
		scroll_index = 0
	scroll_view.ensure_control_visible(btns[scroll_index])

func start_game(data: CharacterData):
	Main.current_character_data = data
	Main.to_scene(Main.SCENE.demo)
