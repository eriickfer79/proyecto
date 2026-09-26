extends CharacterBody2D

@export var speed: float = 90.0
@export var patrol_range: float = 150.0

var direction: int = 1
var start_x: float = 0.0

func _ready() -> void:
    start_x = global_position.x

func _physics_process(delta: float) -> void:
    if abs(global_position.x - start_x) >= patrol_range:
        direction *= -1
        start_x = global_position.x

    velocity.x = direction * speed
    velocity.y += 700.0 * delta

    move_and_slide()

    if is_on_wall():
        direction *= -1
        start_x = global_position.x
