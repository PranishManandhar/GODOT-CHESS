extends Node2D

@export var movable_layer: TileMapLayer

#piecemovement info
func get_pawn_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var possible_movement_cells: Array[Vector2i] = []
	var data = movable_layer.get_cell_tile_data(cell)
	var dir: Vector2i
	
	if CHESS_UTILITY.get_piece_data(cell) != "pawn":
		return []
	
	if data.get_custom_data("P1"):
		dir = Vector2i.UP
	elif data.get_custom_data("P2"):
		dir = Vector2i.DOWN
	else:
		return []

	var forward := cell + dir
	if CHESS_UTILITY.is_empty(forward):
		possible_movement_cells.append(forward)

	for sides in [Vector2i.LEFT, Vector2i.RIGHT]:
		var target = forward + sides
		
		if CHESS_UTILITY.is_enemy(target, data):
			possible_movement_cells.append(target)
		
	return possible_movement_cells

func get_castle_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var dir := [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var possible_movement_cells: Array[Vector2i] = []
	var data = movable_layer.get_cell_tile_data(cell)
	var next_cell: Vector2i
	
	if CHESS_UTILITY.get_piece_data(cell) != "castle":
		return []
	
	for direction in dir:
		next_cell = cell + direction
		
		while not CHESS_UTILITY.is_unmovable(next_cell) and CHESS_UTILITY.is_empty(next_cell):
			possible_movement_cells.append(next_cell)
			next_cell += direction
			
		if CHESS_UTILITY.is_enemy(next_cell, data):
			possible_movement_cells.append(next_cell)
	
	return possible_movement_cells

func get_bishop_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var V_dir := [Vector2i.UP, Vector2i.DOWN]
	var H_dir := [Vector2i.LEFT, Vector2i.RIGHT]
	var possible_movement_cells: Array[Vector2i] = []
	var data = movable_layer.get_cell_tile_data(cell)
	
	var next_cell: Vector2i

	if CHESS_UTILITY.get_piece_data(cell) != "bishop":
		return []
	
	for V_direction in V_dir:
		for H_direction in H_dir:
			next_cell = cell + (V_direction + H_direction)
			
			while not CHESS_UTILITY.is_unmovable(next_cell) and CHESS_UTILITY.is_empty(next_cell):
				possible_movement_cells.append(next_cell)
				next_cell += (V_direction + H_direction)
			
			if CHESS_UTILITY.is_enemy(next_cell, data):
				possible_movement_cells.append(next_cell)

	return possible_movement_cells

func get_knight_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var possible_movement_cells: Array[Vector2i] = []
	var data = movable_layer.get_cell_tile_data(cell)
	var offsets: Array[Vector2i] = [
		Vector2i(1, -2), Vector2i(-1, -2),
		Vector2i(1, 2), Vector2i(-1, 2),
		Vector2i(2, -1), Vector2i(2, 1),
		Vector2i(-2, -1), Vector2i(-2, 1),
	]
	
	var next_cell: Vector2i
	
	if CHESS_UTILITY.get_piece_data(cell) != "knight":
		return[]
	
	for offset in offsets:
		next_cell = cell + offset
		
		if (CHESS_UTILITY.is_empty(next_cell) or CHESS_UTILITY.is_enemy(next_cell,data)):
			possible_movement_cells.append(next_cell)

		
	return possible_movement_cells

func get_king_movement_data(cell: Vector2i) ->Array[Vector2i]:
	var possible_movement_cells: Array[Vector2i] = []
	var data = movable_layer.get_cell_tile_data(cell)
	var offset: Array[Vector2i] = [
		Vector2i(1,1),Vector2i(1,-1),
		Vector2i(-1,1),Vector2i(-1,-1),
		Vector2i(0,1),Vector2i(0,-1),
		Vector2i(-1,0),Vector2i(1,0)
	]

	
	return possible_movement_cells

func move_piece(from: Vector2i, to: Vector2i):
	var src = movable_layer.get_cell_source_id(from)
	var atlas = movable_layer.get_cell_atlas_coords(from)
	
	movable_layer.erase_cell(from)
	movable_layer.set_cell(to, src, atlas)

func _ready() -> void:
	CHESS_UTILITY.movable_layer = movable_layer
	
	for cell in movable_layer.get_used_cells():
		if CHESS_UTILITY.get_piece_data(cell) == "knight":
			print(cell, " -> ", get_knight_movement_data(cell))

#debug code
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var cell := movable_layer.local_to_map(movable_layer.get_local_mouse_position())
		print("clicked cell ", cell)
