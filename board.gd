extends Node2D

@onready var ui = $UI
var score = 0

var columns = 10
var rows = 20
var cell_size = 30
var occupied_cells = []
var floor_color = Color.DARK_GRAY

var piece
var next_type

var all_types = [
	# Square
	{
		"disable_rotation": true,
		"shape": [
			Vector2(0,0),
			Vector2(1,0),
			Vector2(0,1),
			Vector2(1,1)
		],
		"color": Color.BLUE,
		"icon": preload("res://shapes/square.png") 
	},
	# Straight
	{
		"shape": [
			Vector2(-1,0),
			Vector2(0,0),
			Vector2(1,0),
			Vector2(2,0)
		],
		"color": Color.RED,
		"icon": preload("res://shapes/straight.png") 
	},
	# L
	{
		"shape": [
			Vector2(-1,0),
			Vector2(0,0),
			Vector2(1,0),
			Vector2(-1,1)
		],
		"color": Color.PURPLE,
		"icon": preload("res://shapes/L.png") 
	},
	# J
	{
		"shape": [
			Vector2(-1,0),
			Vector2(0,0),
			Vector2(1,0),
			Vector2(1,1)
		],
		"color": Color.YELLOW,
		"icon": preload("res://shapes/J.png") 
	},
	# s
	{
		"shape": [
			Vector2(0,0),
			Vector2(1,0),
			Vector2(-1,1),
			Vector2(0,1)
		],
		"color": Color.WEB_GREEN,
		"icon": preload("res://shapes/s.png") 
	},
	# z
	{
		"shape": [
			Vector2(-1,0),
			Vector2(0,0),
			Vector2(0,1),
			Vector2(1,1)
		],
		"color": Color.CYAN,
		"icon": preload("res://shapes/z.png") 
	},
	# T
	{
		"shape": [
			Vector2(-1,0),
			Vector2(0,0),
			Vector2(1,0),
			Vector2(0,1)
		],
		"color": Color.SADDLE_BROWN,
		"icon": preload("res://shapes/T.png") 
	}
]

func _ready() -> void:
	# Center horizontally
	var screen_width = get_viewport_rect().size.x
	var board_width = columns * cell_size
	position.x = (screen_width - board_width) / 2
	position.y = 150
	
	for x in range(columns):
		occupied_cells.append([])
		for y in range(rows):
			occupied_cells[x].append(false)
	var piece_scene = preload("res://piece.tscn")
	piece = piece_scene.instantiate()
	piece.set_cell_size(cell_size)
	add_child(piece)
	generate_next_type()
	new_piece()

func clear_line(row):
	for y in range(row - 1, -1, -1):
		for x in range(columns):
			occupied_cells[x][y + 1] = occupied_cells[x][y]
	for x in range(columns):
		occupied_cells[x][0] = false
	score += 1
	ui.update_score(score)
	queue_redraw()

func line_clear_check():
	for y in range(rows - 1, -1, -1):
		var cleared = true
		for x in range(columns):
			if not occupied_cells[x][y]:
				cleared = false
				break
		if cleared:
			clear_line(y)
			return line_clear_check()

func occupy_cells(cells_position, shape):
	for cell in shape:
		var x = cells_position.x / cell_size + cell.x
		var y = cells_position.y / cell_size + cell.y
		occupied_cells[x][y] = true
	line_clear_check()
	for x in range(columns):
		if occupied_cells[x][0]:
			return ui.game_over()
	new_piece()
	queue_redraw()

func generate_next_type():
	next_type = all_types[randi() % all_types.size()].duplicate(true)
	ui.set_next(next_type.icon, next_type.color)

func new_piece():
	piece.set_type(next_type)
	generate_next_type()
	piece.init(Vector2((columns/2) * cell_size, 0))

func _draw() -> void:
	for x in range(columns):
		for y in range(rows):
			var rect = Rect2(x * cell_size, y * cell_size, cell_size, cell_size)
			draw_rect(rect, floor_color, occupied_cells[x][y])
