extends Object
class_name CharacterData

var id = 0
var dlc_id = 0
var display_name: String
var file_name: String
var category: String
var level: int
var progress = 0
var has_bonus = false
var has_dlc: bool

func get_path() -> String:
	return "res://categorys/" + category + "/characters/sex_girl_" + file_name

func get_avatar() -> String:
	return "res://image/avatar/sex_girl_" + file_name + ".png"

func get_avatar_name() -> String:
	return "photo_girl_" + file_name

func get_cg_path(index) -> String:
	var img_name = "sex_girl_" + file_name + "_lv" + str(index+1) + ".png"
	var path = get_path().path_join(img_name)
	return path

func get_full_cg_path(index) -> String:
	var img_name = "sex_girl_" + file_name + "_lv" + str(index+1) + ".png"
	var path = "res://categorys/" + category + "/characters/full/sex_girl_" + file_name
	return path.path_join(img_name)

func get_spine_path() -> String:
	var spine_name = file_name + ".tres"
	var path = get_path().path_join("spine").path_join(spine_name)
	#return path if FileAccess.file_exists(path) else ""
	return path if ResourceLoader.exists(path) else ""

func check_dlc():
	if Steamworks.is_steam_enabled():
		has_dlc = Steam.isDLCInstalled(dlc_id) if id != 1 else true
