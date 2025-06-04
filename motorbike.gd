extends CharacterBody3D


var jump_velocity = 0.0
var max_speed = -100
var min_speed = 20
var speed := 0.0 
var rotating := 0.0
var was_on_floor := false
var fly_speed = Vector3.ZERO
var floor = Vector3.UP
var accumulative_gravity := Vector3.ZERO
var brake_light_on = false
var respawn_pos
var respawn_trans

func _ready() -> void:
	Global.bike_transform = transform
	respawn_pos = global_position
	respawn_trans = global_transform
	Global.bike_missing = false
func _physics_process(delta: float) -> void:
	if Global.bike_missing:
		death()
		return
	velocity = Vector3.ZERO
	if !is_on_floor() and !is_on_wall() and !is_on_ceiling():
		accumulative_gravity += get_gravity() * 3 * delta
		velocity += accumulative_gravity
	else:
		accumulative_gravity = Vector3.ZERO
		fly_speed = Vector3.ZERO
		#transform = transform.interpolate_with(xform, 0.2)
	if is_on_floor_only():
		print("hhfdhffhfdh")
		floor = get_floor_normal()
		
	
	if get_last_slide_collision() != null and get_last_slide_collision().get_normal() != transform.basis.y:
		var a = transform.basis.y
		var b = get_last_slide_collision().get_normal()
		var result = rad_to_deg(a.angle_to(b))
		#print(abs(result))
		if abs(result) > 75 and Global.is_on_bike and is_on_floor():
			#print("frbvljdsbjlfjljljkfbjfj")
			speed = 0
		else:
			print("shimmy ay")
			floor = get_last_slide_collision().get_normal()
			pass
		#var collision_angle = rad_to_deg(acos(get_last_slide_collision().get_normal().dot(get_floor_normal())))

	
	
	var input_dir = Input.get_axis("Backward", "Forward") 
	if !Global.is_on_bike:
		input_dir = 0
	if input_dir != 0 and (is_on_wall() or is_on_ceiling() or is_on_floor()):
		speed -= (10 + (input_dir * 50)) * delta
		speed = clamp(speed, max_speed, min_speed)
	else:
		speed = lerp(speed, 0.0, 0.01)
	if speed > -0.5 and speed < 0.5:
		speed = 0
	if input_dir < 0:
		brake_light_on = true
	else:
		brake_light_on = false
	$BikeTurn/Brakelight.visible = brake_light_on
		#print(speed)
		
	var left_right = -Input.get_axis("Left", "Right")
	if !Global.is_on_bike:
		left_right = 0
		
	if left_right != 0:
		rotating += left_right
		rotating = clamp(rotating, -20, 20)
	else:
		rotating = lerp(rotating, 0.0, 0.05)
		if rotating > -0.05 and rotating < 0.05:
			rotating = 0
	$BikeTurn/BichaelRot.rotation_degrees.y = (rotating * abs((speed / 70)))
	if speed != 0 and was_on_floor:
		var new_trans = transform
		new_trans.basis = new_trans.basis.rotated(new_trans.basis.y, deg_to_rad(rotating * clamp((speed / -20), -1, 1)))
		transform = transform.interpolate_with(new_trans, 0.1)
		$BikeTurn.rotation_degrees.z = (rotating * clamp((abs(speed) / 20), -1, 1)) * 0.5
	elif speed != 0 and !was_on_floor:
		var new_trans = transform
		new_trans.basis = new_trans.basis.rotated(new_trans.basis.y, deg_to_rad(left_right * 3))
		transform = transform.interpolate_with(new_trans, 0.2)
			
			#$BikeTurn.rotation_degrees.z = (rotating * clamp((abs(speed) / 20), -1, 1)) * 0.3
		
	
	align_with_floor(floor)
		
	#print(forwardDirection)
	var forwardDirection := (transform.basis * Vector3(0, 0, -speed))
	velocity -= forwardDirection
	if was_on_floor:
		pass
	if is_on_floor() or is_on_wall() or is_on_ceiling():
		fly_speed = Vector3.ZERO
	if !is_on_floor() and !is_on_wall() and !is_on_ceiling() and was_on_floor:
		velocity -= transform.basis.y * 0.7
		fly_speed += (transform.basis.y * velocity)
		#floor = Vector3.ZERO
	if Global.is_on_bike and Input.is_action_just_pressed("ui_accept") and (is_on_floor() or is_on_wall() or is_on_ceiling()):
		fly_speed += transform.basis.y * 80
	velocity += (fly_speed)

	fly_speed = lerp(fly_speed, Vector3.ZERO, 0.1)
	if is_on_wall() or is_on_floor() or is_on_ceiling():
		was_on_floor = true
	else:
		was_on_floor = false
	var front_rot = speed
	if speed != 0 and was_on_floor:
		$BikeTurn/BackWheel.rotation_degrees.x += speed
		$BikeTurn/BichaelRot/FrontWheel.rotation_degrees.x += speed
		front_rot = speed
	if speed != 0 and !was_on_floor:
		$BikeTurn/BackWheel.rotation_degrees.x += speed
		$BikeTurn/BichaelRot/FrontWheel.rotation_degrees.x += front_rot
		front_rot = lerp(front_rot, 0.0, 0.7)
	Global.speedometer = int(velocity.length_squared())
	move_and_slide()
	Global.bike_transform = $BikeTurn/PlayerPos.global_transform
	Global.bike_position = $BikeTurn/PlayerPos.global_position
	Global.bike_rotation = $BikeTurn/PlayerPos.global_rotation
	Global.bike_dismount = $Player_dismount.global_position

func align_with_floor(floor):
	var new_trans = transform
	new_trans.basis.y = floor
	new_trans.basis.x = -new_trans.basis.z.cross(new_trans.basis.y)
	new_trans.basis = new_trans.basis.orthonormalized()
	transform = transform.interpolate_with(new_trans, 0.1).orthonormalized()

	

func collide_and_bounce(collision):
		print("yuh")
		if !is_on_floor:
			return
		if collision == null:
			return
		if collision.get_normal() == get_floor_normal():
			return
		#print("thats a wall or smth i think idk")
		var reflect = collision.get_remainder().bounce(collision.get_normal())
		var dir1 = velocity
		velocity = velocity.bounce(collision.get_normal())
		var dir2 = velocity
		var dot = dir1.normalized().dot(dir2.normalized())
		var cross = dir1.normalized().cross(dir2.normalized())
		var pleasework = acos(dot)
		move_and_collide(reflect)
		speed *= 0.8
		return (pleasework)


func death():
	if Global.is_on_bike:
		Global.player_health = 0
	Global.is_on_bike = false
	global_position = respawn_pos
	global_transform = respawn_trans
	$BikeTurn.rotation = Vector3.ZERO
	$BikeTurn/BichaelRot.rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	speed = 0 
	rotating = 0
	floor = Vector3.UP
	Global.bike_missing = false
