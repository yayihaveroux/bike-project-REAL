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

func _ready() -> void:
	Global.bike_transform = transform
func _physics_process(delta: float) -> void:
	
	if !is_on_floor() and was_on_floor:
		print("fly!")
		velocity.y += fly_speed
		
	was_on_floor = is_on_floor()
	# Add the gravity.
	if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
		velocity += get_gravity() * 5 * delta
		
	# Handle jump.
	elif Input.is_action_just_pressed("ui_accept") and Global.is_on_bike:
		velocity.y = 20

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Vector2(0, 0)
	if Global.is_on_bike:
		input_dir = Input.get_vector("Left", "Right", "Forward", "Backward")
	if input_dir.y != 0 and is_on_floor():
		speed += (10 + (input_dir.y * 50)) * delta
		speed = clamp(speed, max_speed, min_speed)
	elif input_dir.y != 0:
		#rotate_object_local(Vector3.LEFT, 5 * input_dir.y * delta)
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
	var direction := (transform.basis * Vector3(0, 0, speed))
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

				
	global_transform = global_transform.interpolate_with(slope_align(global_transform), 5 * delta)
	
	rotation_degrees.y += rotating * delta
	rotation_degrees.z = (35 * (rotating / 100)) 
	
		

	velocity.x = direction.x 
	velocity.z = direction.z


	
	
	
	
	

	var collision = get_last_slide_collision()
	var result = collide_and_bounce(collision)
	
	if result != null:
		rotation_amount = result
	rotation.y = lerp_angle(rotation.y, (rotation.y + rotation_amount.y), 0.4)
	rotation_amount.y = lerp_angle(rotation_amount.y, 0, 0.4)
	
	
	
	
	
	Global.speedometer = int(Vector2(velocity.x, velocity.z).length_squared())
	move_and_slide()
	
	
	fly_speed = direction.y
	Global.bike_transform = transform
	#print("this is bike: ", transform.basis)
	Global.bike_position = position
	Global.bike_rotation = rotation
	
	
func slope_align(xform):
	if !is_on_floor():
		var before = xform
		xform.basis.y = Vector3.UP
		xform.basis.x = xform.basis.y.cross(xform.basis.z)
		xform.basis = xform.basis.orthonormalized()
		var result = before.interpolate_with(xform, 0.1)
		return result
	else:
		var normal = get_floor_normal()
		xform.basis.y = normal
		xform.basis.x = xform.basis.y.cross(xform.basis.z)
		xform.basis = xform.basis.orthonormalized()
		return xform
	return "woopsies"
	
func collide_and_bounce(collision):
		
		if !is_on_floor:
			return
		if collision_frame_buffer > 0:
			collision_frame_buffer -= 1
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
