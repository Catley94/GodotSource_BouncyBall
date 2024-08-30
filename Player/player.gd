extends RigidBody2D

# See https://github.com/godotengine/godot/issues/89458 for physics bug of random bouncing on corners of tilemaps

# How fast the player moves in meters per second.
@export var speed = 14

# Vertical impulse applied to the character upon jumping in meters per second.
@export var thrust: Vector2 = Vector2(0, -300)

@export var sidewardsThurst: int = 500

var max_amount_of_collisions_detected_in_one_tick: int = 2

var previous_y_velocity: float = 0.0

var velocity_reset_value: int = -300

var queue_jump: bool = false

var reset_position_queued: bool = false

var start_position: Vector2;

# TODO
# Add on force for left and right
# Check that the ball will bounce and fall on slanted floor

# TODO Other
# Add a camera on to player and fixed to center

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position = transform.origin
	setup_collision_reporting()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func resetting_all_properties() -> void:
	queue_jump = false
	reset_position_queued = false
	linear_velocity = Vector2(0, 0) # Resets velocity for both x and y 
	
	

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	
	if reset_position_queued:
		set_freeze_enabled(true)
		resetting_all_properties()
		transform.origin = start_position
		set_freeze_enabled(false)
	
	# Get the current velocity of the Rigidbody2D
	if previous_y_velocity != 0: # Ignores first tick
		check_velocity(state)
	
	#if state.linear_velocity.y <= 0:
		#print("Flying")
		#state.linear_velocity.y = clamp(state.linear_velocity.y, -600, -100)
	#if state.linear_velocity.y > 0:
		#print("Falling")
		#if state.linear_velocity.y < 50:
			#print("gaining downward velocity")
			#if falling:
				#print("test")
	
	if Input.is_action_pressed("move_left"):
		var movementVector: Vector2 = Vector2(-sidewardsThurst, 0)
		apply_force(movementVector)
	if Input.is_action_pressed("move_right"):
		var movementVector: Vector2 = Vector2(sidewardsThurst, 0)
		apply_force(movementVector)
	
	if Input.is_action_pressed("jump"):
		# Queue Jump on next bounce
		queue_jump = true
		
	previous_y_velocity = state.linear_velocity.y
	

func _on_body_entered(body: Node) -> void:
	$BounceAnimation.play("player")


func _on_body_exited(body: Node) -> void:
	#print(body.name)
	
	if queue_jump:
		queue_jump = false
		
		# Reduces the thrust so ball is likely to stay on screen bouncing
		# Small bug: If player continues to push space, it will still increase height minimally
		# 	but once stopped, gravity will quickly pull it back down
		var limiter: float = thrust.y / linear_velocity.y  
		
		#print("thrust.y (%s) / velocity.y (%s)  = %s " % [linear_velocity.y, thrust.y, thrust.y / linear_velocity.y ])
		
		print_rich("[color=cyan][b]Applying thrust now[/b][/color]") 
		apply_impulse(thrust * limiter)

func check_velocity(state: PhysicsDirectBodyState2D) -> void:
	var current_velocity = state.linear_velocity
	var velocity_difference_each_tick = previous_y_velocity - state.linear_velocity.y
	
	if velocity_difference_each_tick > 0:
		if  is_positive_number(previous_y_velocity) and not is_positive_number(state.linear_velocity.y):
			#if velocity_difference_each_tick
			
			print_rich("[color=green][b]previous_y_velocity: %s, state.linear_velocity.y: %s, velocity_difference_each_tick: %s[/b][/color]" % [previous_y_velocity, state.linear_velocity.y, velocity_difference_each_tick]) # Prints out "Hello world!" in green with a bold font
			#print("previous_y_velocity: %s, state.linear_velocity.y: %s, velocity_difference_each_tick: %s " % [previous_y_velocity, state.linear_velocity.y, velocity_difference_each_tick] ) 
			#print("previous y velocity - state.linear_velocity.y = ", velocity_difference_each_tick)
			if velocity_difference_each_tick < 700.00:
				#print("velocity: ", current_velocity.y)
				print_rich("[color=yellow][b]Resetting velocity from: %s, to: %s[/b][/color]" % [state.linear_velocity.y, velocity_reset_value])
				reset_velocity(state)
				
		elif not is_positive_number(previous_y_velocity) and not is_positive_number(state.linear_velocity.y):
			print_rich("[color=orange][b]Not resetting because of jump[/b][/color]")


func setup_collision_reporting() -> void:
	set_contact_monitor(true)
	max_contacts_reported = max_amount_of_collisions_detected_in_one_tick


func reset_velocity(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity.y = velocity_reset_value

func is_positive_number(value: float) -> bool:
	if value > 0.0:
		return true
	else:
		return false
	

func _on_reset_area_body_entered(body: Node2D) -> void:
	#print("Entered reset area")
	queue_reset_position()

func queue_reset_position() -> void: 
	#print("Resetting position")
	reset_position_queued = true
