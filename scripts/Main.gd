extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var title_label: Label = $CanvasLayer/Title
@onready var stats_label: Label = $CanvasLayer/Stats

var enemy_total := 3
var enemy_defeated := 0

func _ready() -> void:
    player.hit_enemy.connect(_on_player_hit)
    for enemy in get_tree().get_nodes_in_group("enemy"):
        enemy.defeated.connect(_on_enemy_defeated)
    _update_hud()

func _process(_delta: float) -> void:
    _update_hud()

func _update_hud() -> void:
    var hp := player.health if player != null else 0
    stats_label.text = "HP: %d | ENEMIES: %d/%d | A/D: MOVE | SPACE: JUMP | SHIFT: DASH | CLICK: ATTACK" % [hp, enemy_defeated, enemy_total]

func _on_player_hit() -> void:
    if player == null:
        return
    player.global_position = Vector2(160, 440)
    player.velocity = Vector2.ZERO
    title_label.text = "YOU FELL"
    await get_tree().create_timer(0.45).timeout
    title_label.text = "HEART OF DARKNESS"

func _on_enemy_defeated() -> void:
    enemy_defeated += 1
    if enemy_defeated >= enemy_total:
        title_label.text = "SECTOR CLEARED"
    _update_hud()
