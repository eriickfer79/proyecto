extends CharacterBody2D

signal hit_enemy

@export var speed: float = 220.0

func _physics_process(_delta: float) -> void:
    var input_vector = Vector2.ZERO

    if Input.is_action_pressed("move_right"):
        input_vector.x += 1
    if Input.is_action_pressed("move_left"):
        input_vector.x -= 1
    if Input.is_action_pressed("move_down"):
        input_vector.y += 1
    if Input.is_action_pressed("move_up"):
        input_vector.y -= 1

    if input_vector != Vector2.ZERO:
        input_vector = input_vector.normalized()

    velocity = input_vector * speed
    move_and_slide()

    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        if collision and collision.get_collider() and collision.get_collider().is_in_group("enemy"):
            hit_enemy.emit()
