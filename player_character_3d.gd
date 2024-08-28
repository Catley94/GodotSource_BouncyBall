extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -800.0

@export var bounce_velocity: float = -400.0

var jump_queued: bool = false

# if rotation is positive, floor is tilted right (lower end is right)
	# change rotation of ball to be the same as floor
# if rotation is negative, floor is tilted towars the left



func _ready() -> void:
	set_floor_stop_on_slope_enabled(false)







func _physics_process(delta: float) -> void:
	
	#print(get_floor_angle(Vector2(0, -1)))
	
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_queued = true
	
	# Add the gravity.
	if not is_on_floor():
		# Is falling
		# Add gravity
		velocity += get_gravity() * delta
		
	#if is_on_wall():
		#print("On wall")

	if jump_queued:
		if is_on_floor():
			jump()

	#if is_on_floor() and jump_queued:
		#jump()
		
	# TODO: 
	# Add on falling velocity, from high cliff, drop should add on to bounce / jump

	elif is_on_floor():
		velocity.y = bounce_velocity
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			print("Collided with: ", collision.get_collider().get_property_list())
		#print(get_floor_angle(get_up_direction()))
		#print(get_last_slide_collision().get_angle())
		#print(get_real_velocity())
		#print(get_platform_velocity())

	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		## May be able to simulate bouncing with this?
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func jump() -> void:
	velocity.y = JUMP_VELOCITY
	jump_queued = false
