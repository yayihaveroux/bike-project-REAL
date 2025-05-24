extends CharacterBody3D


@export var walk_speed = 7.0
@export var jump_velocity = 7.5

@export var h_sensitivity = 0.4
@export var v_sensitivity = 0.3
@export var fov := 75.0

@export var gun_selected = "Assault Rifle"

@onready var bullet_spawn = $CameraRoot/BulletSpawn
@onready var bullet_timer = $BulletTimer

var ARBullet = preload("res://playerscenes/ar_bullet.tscn")
var flash = preload("res://playerscenes/flash.tscn")
var gun_list = ["Assault Rifle", "other"]
var bullet_avail = true

var mouse_motion = Vector2(0, 0)

var pausecamera = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	floor_snap_length = 2.5
	
	
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative
	
	
func _physics_process(delta: float) -> void:
		
		
		
	if Input.is_action_just_pressed("Pause"):
		
				if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					pausecamera = true
				else:
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					pausecamera = false
	
	if !Global.is_on_bike:
			
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta

			# Handle jump.
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = jump_velocity
				
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir := Input.get_vector("Left", "Right", "Forward", "Backward")
			var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x = direction.x * walk_speed
				velocity.z = direction.z * walk_speed
			else:
				velocity.x = move_toward(velocity.x, 0, walk_speed)
				velocity.z = move_toward(velocity.z, 0, walk_speed)
			
	else: 
		
		transform = Global.bike_transform
		
	if not pausecamera:
		if Global.is_on_bike:
				# apply mouse_movement to body and camera
				$CameraRoot.rotation.y -= mouse_motion[0] * delta * h_sensitivity
				$CameraRoot.rotation.x -= mouse_motion[1] * delta * v_sensitivity
		
				# clamp at 90 to avoid vertical spinning infinitely
				$CameraRoot.rotation_degrees.x = clamp($CameraRoot.rotation_degrees.x, -90, 90)
				# reset mouse_motion to 0
		else:
				# apply mouse_movement to body and camera
				rotation.y -= mouse_motion[0] * delta * h_sensitivity
				$CameraRoot.rotation.x -= mouse_motion[1] * delta * v_sensitivity
		
				# clamp at 90 to avoid vertical spinning infinitely
				$CameraRoot.rotation_degrees.x = clamp($CameraRoot.rotation_degrees.x, -90, 90)
				# reset mouse_motion to 0
	
	var speedometer = sqrt(Global.speedometer)
	$CanvasLayer/UI/speed.text = "Speed: " + str(int(speedometer))
	$CanvasLayer/UI/TopLeft/position.text = "Position: " + str(global_position)
	move_and_slide()
	$CanvasLayer/UI/TopLeft/fps.text = "FPS: " + str(Engine.get_frames_per_second())
	#print("this is you: ", transform.basis)
	
	
	
	
	# handle primary fire for all weapons
	if Input.is_action_pressed("LClick"):
		match gun_selected:
			"Assault Rifle":
				if bullet_avail:
					
					var instance = ARBullet.instantiate()
					get_tree().root.add_child(instance)
					instance.global_position = bullet_spawn.global_position
					instance.global_rotation_degrees = bullet_spawn.global_rotation_degrees + Vector3(randi_range(-1,1), randi_range(-1,1), randi_range(-1,1))
					bullet_avail = false
					bullet_timer.start(0.1)
					
					instance = flash.instantiate()
					$CameraRoot/Arm.add_child(instance)
			_:
				print("what the hell have you done")
	# handle secondary fire for all weapons
	if Input.is_action_pressed("RClick"):
		match gun_selected:
			"Assault Rifle":
				if bullet_avail:
					var instance
					for i in 10:
						instance = ARBullet.instantiate()
						get_tree().root.add_child(instance)
						instance.global_position = bullet_spawn.global_position
						instance.global_rotation_degrees = bullet_spawn.global_rotation_degrees + Vector3(randi_range(-5,5), randi_range(-5,5), randi_range(-5,5))
					bullet_avail = false
					bullet_timer.start(1)
					
					instance = flash.instantiate()
					$CameraRoot/Arm.add_child(instance)
					instance.scale = Vector3(7, 7, 7)
			_:
				print("what the hell have you done")
	mouse_motion = Vector2(0,0)
	if Input.is_action_just_pressed("BikeEquip(E)"):
		Global.is_on_bike = not Global.is_on_bike
		if !Global.is_on_bike:
			$Collision.disabled = false
			$CameraRoot.rotation.y = 0
			rotation.z = 0
			rotation.x = 0
			global_transform.basis.y = Vector3.UP
			global_transform.basis = global_transform.basis.orthonormalized()
			global_rotation.y = Global.bike_rotation.y
			#global_position = Global.bike_position
		else:
			$Collision.disabled = true
			
	


func _on_bullet_timer_timeout() -> void:
	bullet_avail = true
