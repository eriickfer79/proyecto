extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var label: Label = $CanvasLayer/Label
var score: int = 0
var game_over: bool = false

func _ready() -> void:
    label.text = "Puntos: 0"
    player.hit_enemy.connect(_on_player_hit_enemy)

    for coin in get_tree().get_nodes_in_group("coin"):
        coin.collected.connect(_on_coin_collected)

func _on_coin_collected() -> void:
    if game_over:
        return
    score += 1
    label.text = "Puntos: %d" % score

func _on_player_hit_enemy() -> void:
    if game_over:
        return
    game_over = true
    label.text = "Game Over - Puntos: %d" % score
