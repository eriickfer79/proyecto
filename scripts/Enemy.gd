extends CharacterBody2D

@export var speed: float = 100.0

func _physics_process(_delta: float) -> void:
    var player = get_tree().get_first_node_in_group("player")
    if player == null:
        return

    var direction = (player.global_position - global_position)
    if direction.length() > 0:
        direction = direction.normalized()
    velocity = direction * speed
    move_and_slide()

    for i in range(get_slide_collision_count()):
        var collision = get_slide_collision(i)
        if collision and collision.get_collider() and collision.get_collider().is_in_group("player"):
            player.hit_enemy.emit()
