extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var title_label: Label = $UI/Title
@onready var stats_label: Label = $UI/Stats
var defeated := 0
var total_enemies := 3
var respawn := Vector2(140, 500)

func _ready() -> void:
    player.hit_enemy.connect(_on_player_hurt)
    player.enemy_defeated.connect(_on_enemy_defeated)
    queue_redraw()

func _process(_delta: float) -> void:
    stats_label.text = "ENEMIGOS: %d/%d     A/D: MOVER   ESPACIO: SALTAR   SHIFT/Q: DASH   CLICK/J: ATACAR" % [defeated, total_enemies]

func _on_player_hurt() -> void:
    player.global_position = respawn
    player.velocity = Vector2.ZERO

func _on_enemy_defeated() -> void:
    defeated += 1
    if defeated >= total_enemies:
        title_label.text = "ZONA SUPERADA"

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color("#080b1d"))
    for i in range(12):
        var x := float(i * 130)
        var h := float(80 + (i % 4) * 35)
        draw_colored_polygon(PackedVector2Array([Vector2(x, 650), Vector2(x+35, 650-h), Vector2(x+70, 650), Vector2(x+105, 650-h*0.6), Vector2(x+130,650)]), Color("#111936"))
    for star in [Vector2(90,130), Vector2(240,210), Vector2(430,100), Vector2(710,170), Vector2(1060,120), Vector2(1170,250)]:
        draw_circle(star, 2.0, Color("#7984b7"))
    var platforms := [Rect2(0,650,1280,70), Rect2(280,540,220,24), Rect2(620,450,220,24), Rect2(940,350,220,24), Rect2(70,390,180,24)]
    for platform in platforms:
        draw_rect(platform, Color("#303658"))
        draw_line(platform.position, Vector2(platform.end.x, platform.position.y), Color("#8b91c0"), 3.0)
