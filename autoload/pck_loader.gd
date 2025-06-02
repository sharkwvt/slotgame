extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var pck_path = "res://pck_test.pck"
	var success = ProjectSettings.load_resource_pack(pck_path, false)
	if success:
		print(pck_path + " 讀取成功")


func load_dlc_pck(dlc_id: int):
	var file_dir = get_dlc_base_path()
	
	var pck_name: String
	match dlc_id:
		Steamworks.DLC.醫院:
			pck_name = "hospital.pck"
		Steamworks.DLC.學校:
			pck_name = "gym.pck"
		Steamworks.DLC.大樓:
			pck_name = "building.pck"
		Steamworks.DLC.動畫1:
			pck_name = "animation1.pck"
		_:
			pck_name = "dlc.pck"
	var pck_path = file_dir.path_join(pck_name)
	
	if FileAccess.file_exists(pck_path):
		if ProjectSettings.load_resource_pack(pck_path):
			Logger.log("DLC成功載入: %s" % pck_name)
		else:
			Logger.log("DLC載入失敗: %s" % pck_name)
	else:
		Logger.log("pck不存在: %s" % pck_path)


func get_dlc_base_path() -> String:
	var exe_path = OS.get_executable_path()
	var exe_dir = exe_path.get_base_dir()
	
	if OS.get_name() == "macOS":
		# 回三層才是 .app 根目錄
		exe_dir = exe_dir.get_base_dir().get_base_dir().get_base_dir()

	return exe_dir.path_join("dlcs")
