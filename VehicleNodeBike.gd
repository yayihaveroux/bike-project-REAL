extends VehicleBody3D


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	steering = move_toward(steering, Input.get_axis("Right", "Left") * 0.5, delta * 10)
	engine_force = Input.get_axis("Backward",  "Forward") * 500
	

	#velocity.x = move_toward(velocity.x, 0.0,  SPEED)
	#velocity.z = move_toward(velocity.y, 0.0,  SPEED)
	
	#move_and_slide()
