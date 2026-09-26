extends CharacterBody2D

@export var speed := 90.0
@export var patrol_distance := 170.0
var direction := -1
var origin_x := 0.0
var health := 2

func _ready() -> void:
    origin_x = global_position.x
    queue_redraw()

func _physics_process(delta: float) -> void:
    velocity.x = direction * speed
    if not is_on_floor():
        velocity.y += 1100.0 * delta
    move_and_slide()
    if abs(global_position.x - origin_x) > patrol_distance or is_on_wall():
        direction *= -1
        origin_x = global_position.x
    queue_redraw()

func take_hit() -> void:
    health -= 1
    if health <= 0:
        queue_free()
    else:
        modulate = Color("#ffffff")
        await get_tree().create_timer(0.12).timeout
        if is_instance_valid(self):
            modulate = Color.WHITE

func _draw() -> void:
    draw_circle(Vector2(0, -15), 16.0, Color("#9d4d7d"))
    draw_rect(Rect2(-14, -2, 28, 22), Color("#512f5e"), true)
    draw_circle(Vector2(-6, -16), 3.0, Color("#ffe2ef"))
    draw_circle(Vector2(6, -16), 3.0, Color("#ffe2ef"))
