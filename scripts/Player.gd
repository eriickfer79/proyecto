extends CharacterBody2D

signal hit_enemy
signal enemy_defeated

const MAX_HEALTH := 5
const RESPAWN_POINT := Vector2(160, 440)

@export var speed := 260.0
@export var accel := 1600.0
@export var friction := 2200.0
@export var gravity := 1300.0
@export var jump_velocity := -480.0
@export var double_jump_velocity := -430.0
@export var dash_speed := 700.0
@export var dash_duration := 0.15
@export var coyote_time := 0.12
@export var jump_buffer_time := 0.12

var health: int = MAX_HEALTH
var facing := 1
var can_double_jump := true
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var dash_timer := 0.0
var dash_cooldown := 0.0
var attack_cooldown := 0.0
var invuln_timer := 0.0
var attack_flash := 0.0

func _physics_process(delta: float) -> void:
    if invuln_timer > 0.0:
        invuln_timer = max(invuln_timer - delta, 0.0)
    if attack_flash > 0.0:
        attack_flash = max(attack_flash - delta, 0.0)
    if attack_cooldown > 0.0:
        attack_cooldown = max(attack_cooldown - delta, 0.0)
    if dash_cooldown > 0.0:
        dash_cooldown = max(dash_cooldown - delta, 0.0)
    if dash_timer > 0.0:
        dash_timer = max(dash_timer - delta, 0.0)

    var is_grounded := is_on_floor()
    if is_grounded:
        coyote_timer = coyote_time
        can_double_jump = true
    else:
        coyote_timer = max(coyote_timer - delta, 0.0)
        velocity.y = min(velocity.y + gravity * delta, 1200.0)

    var direction := Input.get_axis("move_left", "move_right")
    if direction != 0.0:
        facing = 1 if direction > 0 else -1
        velocity.x = move_toward(velocity.x, direction * speed, accel * delta)
    else:
        velocity.x = move_toward(velocity.x, 0.0, friction * delta)

    if Input.is_action_just_pressed("jump"):
        jump_buffer_timer = jump_buffer_time

    if jump_buffer_timer > 0.0:
        if coyote_timer > 0.0:
            velocity.y = jump_velocity
            coyote_timer = 0.0
            jump_buffer_timer = 0.0
        elif can_double_jump:
            velocity.y = double_jump_velocity
            can_double_jump = false
            jump_buffer_timer = 0.0
    jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

    if Input.is_action_just_pressed("dash") and dash_cooldown <= 0.0:
        dash_timer = dash_duration
        dash_cooldown = 0.75
        velocity.x = facing * dash_speed
        velocity.y = 0.0

    if dash_timer > 0.0:
        velocity.x = facing * dash_speed
        velocity.y = 0.0

    if Input.is_action_just_pressed("attack") and attack_cooldown <= 0.0:
        attack_cooldown = 0.28
        attack_flash = 0.12
        _do_attack()

    move_and_slide()

    if global_position.y > 900.0:
        hurt()

    if not is_on_floor() and not dash_timer > 0.0:
        velocity.y = min(velocity.y, 1200.0)

    if velocity.x != 0.0:
        $Camera2D.enabled = true

func _do_attack() -> void:
    for enemy in get_tree().get_nodes_in_group("enemy"):
        if not is_instance_valid(enemy):
            continue
        var dx := abs(enemy.global_position.x - global_position.x)
        var dy := abs(enemy.global_position.y - global_position.y)
        if dx < 90.0 and dy < 60.0 and sign(enemy.global_position.x - global_position.x) == facing:
            if enemy.has_method("take_damage"):
                enemy.take_damage(1)
                if enemy.has_method("trigger_hit"):
                    enemy.trigger_hit()

func hurt() -> void:
    if invuln_timer > 0.0:
        return
    health -= 1
    invuln_timer = 1.0
    emit_signal("hit_enemy")
    if health <= 0:
        health = MAX_HEALTH
    global_position = RESPAWN_POINT
    velocity = Vector2.ZERO

func _draw() -> void:
    var body_color := Color("#e8eefc") if invuln_timer <= 0.0 else Color("#8e9cc7")
    draw_circle(Vector2(0, -17), 14.0, body_color)
    draw_rect(Rect2(-12, -2, 24, 28), Color("#1a1f2d"), true)
    draw_circle(Vector2(-5, -17), 2.2, Color("#151a2b"))
    draw_circle(Vector2(5, -17), 2.2, Color("#151a2b"))
    if attack_flash > 0.0:
        var slash_color := Color("#cfe6ff")
        var arc_offset := Vector2(facing * 44.0, -12.0)
        draw_arc(arc_offset, 28.0, -1.1 if facing > 0 else 1.1, 1.1 if facing > 0 else 3.2, 24, slash_color, 4.0)
