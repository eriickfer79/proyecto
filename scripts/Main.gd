extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var label: Label = $CanvasLayer/Label

var respawn_position: Vector2 = Vector2(140, 520)

func _ready() -> void:
    player.hit_enemy.connect(_on_player_hit_enemy)
    label.text = "Hollow Knight Inspired"

func _on_player_hit_enemy() -> void:
    player.global_position = respawn_position
    player.velocity = Vector2.ZERO
    label.text = "Respawneo"
    var timer := get_tree().create_timer(0.7)
    await timer.timeout
    label.text = "Hollow Knight Inspired"
