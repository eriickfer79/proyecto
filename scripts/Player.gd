extends CharacterBody2D

signal hit_enemy

@export var speed: float = 220.0
@export var jump_velocity: float = -420.0
@export var double_jump_velocity: float = -340.0
@export var gravity: float = 980.0
@export var max_fall_speed: float = 900.0
@export var dash_speed: float = 520.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

var facing: int = 1
var coyote_timer: float = 0.0
var jump_buffer: float = 0.0
var can_double_jump: bool = true
var is_dashing: bool = false
var dash_timer: float = 0.0

func _physics_process(delta: float) -> void:
    var input_direction = Input.get_axis("move_left", "move_right")

    if input_direction != 0.0:
        facing = int(sign(input_direction))
        velocity.x = move_toward(velocity.x, input_direction * speed, 1500.0 * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, 2200.0 * delta)

    $Sprite2D.flip_h = facing < 0

    if is_on_floor():
        coyote_timer = coyote_time
        can_double_jump = true
    else:
        coyote_timer = max(coyote_timer - delta, 0.0)

    if Input.is_action_just_pressed("jump"):
        jump_buffer = jump_buffer_time
    else:
        jump_buffer = max(jump_buffer - delta, 0.0)

    if jump_buffer > 0.0 and coyote_timer > 0.0:
        velocity.y = jump_velocity
        jump_buffer = 0.0
        coyote_timer = 0.0
    elif jump_buffer > 0.0 and can_double_jump:
        velocity.y = double_jump_velocity
        jump_buffer = 0.0
        can_double_jump = false

    if Input.is_action_just_pressed("dash") and not is_dashing:
        is_dashing = true
        dash_timer = 0.12
        velocity.y = 0.0

    if is_dashing:
        dash_timer -= delta
        velocity.x = facing * dash_speed
        if dash_timer <= 0.0:
            is_dashing = false

    if not is_on_floor() and not is_dashing:
        velocity.y += gravity * delta
        if velocity.y > max_fall_speed:
            velocity.y = max_fall_speed

    move_and_slide()

    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        var collider = collision.get_collider()
        if collider and collider.is_in_group("enemy"):
            hit_enemy.emit()
            break
