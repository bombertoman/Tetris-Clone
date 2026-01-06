extends Control

@onready var game_over_label = $LabelGameOver
@onready var score_label = $LabelScore
@onready var next_sprite = $VBoxNextPiece/SpriteNextPiece

var is_game_over = false

func _ready() -> void:
	game_over_label.hide()

func update_score(score):
	score_label.text = "Score: " + str(score)

func _process(delta: float) -> void:
	if not is_game_over:
		return
	if Input.is_action_just_pressed("ui_select"):
		get_tree().reload_current_scene()

func game_over():
	is_game_over = true
	game_over_label.show()

func set_next(icon, color):
	next_sprite.texture = icon
	next_sprite.modulate = color
