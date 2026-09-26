extends CharacterBody2D

signal hit_enemy
signal enemy_defeated

@export var speed := 260.0
@export var acceleration := 1800.0
@export var friction := 2200.0
@export var gravity := 1250.0
@export var jump_velocity := -500.0
@export var double_jump_velocity := -430.0
@export var dash_speed := 720.0

var facing := 1
var can_double_jump := true
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var dash_timer := 0.0
var dash_cooldown := 0.0
var attack_timer := 0.0
var invulnerability_timer := 0.0

func _ready() -> void:
    queue_redraw()

func _physics_process(delta: float) -> void:
    attack_timer = max(attack_timer - delta, 0.0)
    dash_cooldown = max(dash_cooldown - delta, 0.0)
    invulnerability_timer = max(invulnerability_timer - delta, 0.0)

    if is_on_floor():
        coyote_timer = 0.12
        can_double_jump = true
    else:
        coyote_timer = max(coyote_timer - delta, 0.0)
        if not is_dashing():
            velocity.y = min(velocity.y + gravity * delta, 1100.0)

    var direction := Input.get_axis("move_left", "move_right")
    if direction != 0.0:
        facing = 1 if direction > 0 else -1
        velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, friction * delta)

    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = 0.14
    else:
        jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

    if jump_buffer_timer > 0.0:
        if coyote_timer > 0.0:
            velocity.y = jump_velocity
            jump_buffer_timer = 0.0
            coyote_timer = 0.0
        elif can_double_jump:
            velocity.y = double_jump_velocity
            can_double_jump = false
            jump_buffer_timer = 0.0

    if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
        dash_timer = 0.14
        dash_cooldown = 0.55
        velocity = Vector2(facing * dash_speed, 0.0)

    if dash_timer > 0.0:
        dash_timer -= delta
        velocity = Vector2(facing * dash_speed, 0.0)
    elif Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
        attack_timer = 0.28
        _attack()

    move_and_slide()
    if global_position.y > 900.0:
        hit_enemy.emit()
        global_position = Vector2(140, 500)
        velocity = Vector2.ZERO
    queue_redraw()

func is_dashing() -> bool:
    return dash_timer > 0.0

func _attack() -> void:
    for enemy in get_tree().get_nodes_in_group("enemies"):
        var offset: Vector2 = enemy.global_position - global_position
        if abs(offset.x) < 105.0 and abs(offset.y) < 70.0 and sign(offset.x) == facing:
            if enemy.has_method("take_hit"):
                enemy.take_hit()
                enemy_defeated.emit()

func hurt() -> void:
    if invulnerability_timer > 0.0:
        return
    invulnerability_timer = 1.0
    hit_enemy.emit()
    global_position = Vector2(140, 500)
    velocity = Vector2.ZERO

func _draw() -> void:
    var body_color := Color("#e9edf7") if invulnerability_timer <= 0.0 else Color("#8a91ac")
    draw_circle(Vector2(0, -19), 15.0, body_color)
    draw_colored_polygon(PackedVector2Array([Vector2(-14,-20), Vector2(-26,-40), Vector2(-18,-43), Vector2(-6,-27)]), body_color)
    draw_colored_polygon(PackedVector2Array([Vector2(14,-20), Vector2(26,-40), Vector2(18,-43), Vector2(6,-27)]), body_color)
    draw_rect(Rect2(-12, -8, 24, 28), Color("#28304b"), true)
    draw_circle(Vector2(-5, -20), 2.5, Color("#20263d"))
    draw_circle(Vector2(5, -20), 2.5, Color("#20263d"))
    if attack_timer > 0.0:
        var slash_pos := Vector2(facing * 52, -16)
        draw_arc(slash_pos, 35.0, -1.2 if facing > 0 else 1.9, 1.2 if facing > 0 else 4.6, 18, Color("#d8f2ff"), 5.0)
