extends GPUParticles2D

@export var imgs: Array[Texture]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.texture = imgs.pick_random()
	finished.connect(_on_finished)
	


func _on_finished():
	queue_free()
