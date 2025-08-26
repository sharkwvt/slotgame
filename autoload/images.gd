extends Node

var item_imgs = []
var money_icon: Texture
var voucher_icon: Texture
var voucher_icon_2: Texture

func _ready() -> void:
	money_icon = load("res://image/slot/money.png")
	voucher_icon = load("res://image/slot/money_3.png")
	voucher_icon_2 = load("res://image/slot/money_3.png")
