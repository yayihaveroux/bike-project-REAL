extends CharacterBody3D


const JUMP_VELOCITY = 4.5
var max_speed = -100
var min_speed = 20
var speed := 0.0 
var rotating := 0.0
var collision_frame_buffer := 0
var rotation_amount := Vector3.ZERO
var was_on_floor := false
var fly_speed = 0
var FORWARD := Vector3.BACK
var UP := Vector3.UP
var LEFT := Vector3.LEFT
@onready var FrontNormal = $BikeTurn/FrontWheel/FrontCast
@onready var BackNormal = $BikeTurn/Backwheel/BackCast
func _ready() -> void:
	Global.bike_transform = transform
	
func _physics_process(delta: float) -> void:
	BackNormal = $BikeTurn/Backwheel/BackCast
	FrontNormal = $BikeTurn/FrontWheel/FrontCast
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2(0, 0)
	if Global.is_on_bike:
		input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	if input_dir.y != 0 and is_on_floor() or is_on_wall():
		speed += (10 + (input_dir.y * 50)) * delta
		speed = clamp(speed, max_speed, min_speed)
	elif input_dir.y != 0:
		#rotate_object_local(Vector3.LEFT, -1 * input_dir.y * delta)
		pass
		# dont worry about these 
		#rotation_degrees.x = -180 * input_dir.y
		#transform.basis = transform.basis.rotated(Vector3.RIGHT, 6 * input_dir.y * delta)
		#print(rotation_degrees.x)
	
		
	else:
		speed = lerp(speed, 0.0, 0.005)
		if speed > -0.5 and speed < 0.5:
			speed = 0
		if velocity.x > -0.1 and velocity.x < 0.1:
			velocity.x = 0
		if velocity.z > -0.1 and velocity.z < 0.1:
			velocity.z = 0
	var direction := (transform.basis * Vector3(0, 0, 1) * speed)
	print(FORWARD)
	if speed != 0:
		
		if input_dir.x != 0 and is_on_floor():
			rotating += input_dir.x * 5 * clamp((speed / 20), -1, 1)
			rotating = clamp(rotating, -100, 100)
		elif input_dir.x != 0:
			rotating += input_dir.x * 2.5 * clamp((speed / 20), -1, 1)
			rotating = clamp(rotating, -100, 100)
			
		else:
			rotating = lerp(rotating, 0.0, 0.05)
			if rotating > -0.05 and rotating < 0.05:
				rotating = 0

				
	global_transform = global_transform.interpolate_with(slope_align(global_transform), 8 * delta)
	
	rotation_degrees += FORWARD * (35 * (rotating / 100))
	if (rotation_degrees * FORWARD) > FORWARD * 35 or (rotation_degrees * FORWARD) < FORWARD * -35:
		var new_rot = clamp((rotation_degrees * FORWARD), FORWARD * -35 , FORWARD * 35)
		var safe_vectors = Vector3.ONE - FORWARD
		rotation_degrees *= safe_vectors
		rotation_degrees += new_rot
	rotation_degrees += UP * (rotating * delta)
	print(UP)
	
	if !is_on_floor() and !is_on_wall() and was_on_floor:
		print("fly!")
		direction += (UP * fly_speed)
		print(velocity)
		
	if is_on_wall() or is_on_floor():
		was_on_floor = true
	else:
		was_on_floor = false
	# Add the gravity.
	if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
		direction += get_gravity() * 50 * delta
		
		
	if Input.is_action_just_pressed("ui_accept") and Global.is_on_bike:
		direction += UP * 200

	velocity.x = direction.x 
	velocity.z = direction.z
	velocity.y = direction.y
	#print(FORWARD, UP, LEFT)
	#print(velocity.normalized())
	#direction = direction * transform.basis
	
	
	
	
	

	#var collision = get_last_slide_collision()
	#var result = collide_and_bounce(collision)
	
	#if result != null:
	#	rotation_amount = result
	#$BikeTurn.rotation.y = lerp_angle($BikeTurn.rotation.y, ($BikeTurn.rotation.y + rotation_amount.y), 0.4)
	#global_rotation.y = $BikeTurn.global_rotation.y
	#$BikeTurn.rotation.y = 0
	#rotation_amount.y = lerp_angle(rotation_amount.y, 0, 0.4)
	
	
	
	
	#print(velocity)
	Global.speedometer = int(Vector2(velocity.x, velocity.z).length_squared())
	move_and_slide()
	
	
	fly_speed = (UP * direction)
	Global.bike_transform = $BikeTurn/PlayerPos.global_transform
	#print("this is bike: ", transform.basis)
	Global.bike_position = $BikeTurn/PlayerPos.position
	Global.bike_rotation = $BikeTurn/PlayerPos.rotation
	
	


func slope_align(xform):
	if !is_on_floor() and !is_on_wall():
		return xform
		var before = xform
		xform.basis.y = Vector3.UP
		xform.basis.x = xform.basis.y.cross(xform.basis.z)
		xform.basis = xform.basis.orthonormalized()
		var result = before.interpolate_with(xform, 0.1)
		print("falling it rn")
		FORWARD = Vector3.BACK
		UP = Vector3.UP
		
		return result
	elif is_on_wall():
		xform.basis.y = get_wall_normal()
		xform.basis.z = Vector3.DOWN
		
		xform.basis.x = xform.basis.y.cross(xform.basis.z)
		xform.basis = xform.basis.orthonormalized()
		print("walling it rn")
		#print(xform.basis)
		FORWARD = Vector3.UP
		UP = get_wall_normal()
		
		return xform
	else:
		FORWARD = Vector3.BACK
		var normal = get_floor_normal()
		xform.basis.y = normal
		xform.basis.x = xform.basis.y.cross(xform.basis.z)
		xform.basis = xform.basis.orthonormalized()
		FORWARD = Vector3.BACK
		UP = Vector3.UP
		print("flooring it rn")
		return xform
	#pass
	#return "woopsies"
	
func collide_and_bounce(collision):
		
		if !is_on_floor:
			return
		if collision == null:
			return
		if collision.get_normal() == get_floor_normal():
			return
		#print("thats a wall or smth i think idk")
		if  collision_frame_buffer == 0:
				var reflect = collision.get_remainder().bounce(collision.get_normal())
				var dir1 = velocity
				velocity = velocity.bounce(collision.get_normal())
				var dir2 = velocity
				var dot = dir1.normalized().dot(dir2.normalized())
				var cross = dir1.normalized().cross(dir2.normalized())
				var pleasework = acos(dot)
				move_and_collide(reflect)
				speed *= 0.8
				return (cross * pleasework)

				

				#collision_frame_buffer = 1
			#print("hit a wall! Speed: ", speed)
