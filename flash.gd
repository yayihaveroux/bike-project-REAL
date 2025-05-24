extends Sprite3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation_degrees.z = randi_range(0, 360)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	transparency += 0.2


func _on_timer_timeout() -> void:
	queue_free()
