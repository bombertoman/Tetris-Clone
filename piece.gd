extends Node2D

var active
var board
var type
var cell_size

var acceleration
var countdown_to_fall

var teleport_queued = false
var seconds_to_fall = 1.00
var fast_seconds_to_fall = .1

func type_allows_rotation():
	if not active:
		return false
	if "disable_rotation" in type:
		return not type.disable_rotation
	return true

func shape_collides(shape = type.shape, position_to_check = position / cell_size):
	for piece_cell in shape:
		var x = position_to_check.x + piece_cell.x
		var y = position_to_check.y + piece_cell.y
		if y >= board.rows or x < 0 or x >= board.columns or board.occupied_cells[x][y]:
			return true
	return false

func move(vector_movement):
	if not active:
		return
	var old_grid_position = position / cell_size
	var new_grid_position = old_grid_position + vector_movement
	if shape_collides(type.shape, new_grid_position):
		return false
	position = new_grid_position * cell_size
	return true

func set_type(type_to_set):
	type = type_to_set
	queue_redraw()

func set_cell_size(cell_size_param):
	cell_size = cell_size_param
	queue_redraw()

func rotate_piece():
	if not active:
		return
	var new_shape = []
	
	for point in type.shape:
		new_shape.append(Vector2(-point.y, point.x))
	var grid_position = position / cell_size
	
	var kicks = [
		Vector2.ZERO,
		Vector2(1,0),
		Vector2(-1,0),
		Vector2(0,-1),
		Vector2(2,0),
		Vector2(-2,0)
	]
	for kick in kicks:
		if not shape_collides(new_shape, grid_position + kick):
			position += kick * cell_size
			type.shape = new_shape
			queue_redraw()
			return

func init(initial_position):
	board = get_parent()
	countdown_to_fall = seconds_to_fall
	acceleration = false
	active = true
	position = initial_position
	
func detect_input():
	if Input.is_action_just_pressed("ui_up") and not teleport_queued:
		teleport_queued = true
		teleport_down()
		return
	if Input.is_action_just_pressed("ui_down") and not acceleration:
		acceleration = true
		countdown_to_fall = 0
		queue_redraw()
		return
	if Input.is_action_just_released("ui_down") and acceleration:
		acceleration = false
		return
	if Input.is_action_just_pressed("ui_right"):
		move(Vector2(1,0))
		queue_redraw()
	if Input.is_action_just_pressed("ui_left"):
		move(Vector2(-1,0))
		queue_redraw()
	if Input.is_action_just_pressed("ui_accept") and type_allows_rotation():
		rotate_piece()
	return

func _process(delta: float) -> void:
	if not active:
		return
	detect_input()
	countdown_to_fall -= delta
	if countdown_to_fall <= 0 and not teleport_queued:
		fall()

func fall():
	if not move(Vector2(0,1)):
		active = false  
		board.occupy_cells(position, type.shape)
		return true
	countdown_to_fall = seconds_to_fall if not acceleration else fast_seconds_to_fall
	queue_redraw()
	return false

func teleport_down():
	var i = 0
	var hit = false
	while not hit and i < board.rows:
		hit = fall()
		i += 1
	teleport_queued = false

func _draw() -> void:
	if not active:
		return	
	for coordinates in type.shape:
		var rect = Rect2(coordinates.x * cell_size, coordinates.y * cell_size, cell_size, cell_size)
		draw_rect(rect, type.color, true)
