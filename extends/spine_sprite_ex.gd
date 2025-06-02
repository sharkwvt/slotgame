extends SpineSprite
class_name SpineSpriteEx


func set_skin(skin_name: String):
	get_skeleton().set_skin_by_name(skin_name)


func play_first_anim(loop: bool = true):
	var animations = get_skeleton().get_data().get_animations()
	if animations.size() > 0:
		var anim: SpineAnimation = animations[0]
		play_anim(anim.get_name(), loop)


func play_anim(anim_name: String, loop: bool = true):
	get_animation_state().set_animation(anim_name, loop)
