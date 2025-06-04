extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_kill_box_body_entered(body: Node3D) -> void:
	print("eyedhdhvfeccv")
	if body.name == "Motorbike":
		Global.bike_missing = true
	if body.name == "Player":
		Global.player_health = 0
