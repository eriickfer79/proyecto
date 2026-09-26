extends CharacterBody2D

signal defeated

@export var speed := 90.0
@export var patrol_distance := 190.0
@export var max_health := 2

var direction := -1
var origin_x := 0.0
var health: int = max_health

func _ready() -> void:
    origin_x = global_position.x

func _physics_process(delta: float) -> void:
    if not is_on_floor():
        velocity.y += 1050.0 * delta
    else:
        velocity.y = min(velocity.y, 0.0)

    if abs(global_position.x - origin_x) >= patrol_distance or is_on_wall():
        direction *= -1
        origin_x = global_position.x

    velocity.x = direction * speed
    move_and_slide()

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        emit_signal("defeated")
        queue_free()
    else:
        modulate = Color("#ff8a8a")
        await get_tree().create_timer(0.1).timeout
        modulate = Color.WHITE

func trigger_hit() -> void:
    modulate = Color("#ffd9d9")
    await get_tree().create_timer(0.08).timeout
    modulate = Color.WHITE

func _draw() -> void:
    draw_circle(Vector2(0, -15), 14.0, Color("#b75f82"))
    draw_rect(Rect2(-12, 0, 24, 22), Color("#6d2f52"), true)
    draw_circle(Vector2(-5, -15), 2.2, Color("#ffe0ee"))
    draw_circle(Vector2(5, -15), 2.2, Color("#ffe0ee"))
