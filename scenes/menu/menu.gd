extends Scene

@export var menu_btn: PackedScene
@export var menus_root: HBoxContainer

var btns = []

func _ready() -> void:
	setup()

func setup():
	for data in Main.character_datas:
		var view = menu_btn.instantiate()
		view.set_data(data)
		(view.btn as ButtonEx).pressed.connect(start_game.bind(data))
		menus_root.add_child(view)
		btns.append(view)

func refresh():
	for btn in btns:
		btn.refresh()


func show_scene():
	refresh()

func return_scene():
	Main.to_scene(Main.SCENE.start)


func start_game(data: CharacterData):
	Main.current_character_data = data
	Main.to_scene(Main.SCENE.demo)
