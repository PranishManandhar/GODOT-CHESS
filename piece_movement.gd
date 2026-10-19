class_name Piece_movement_data extends Node

func move_diagonal(H_dir: Array[Vector2i], V_dir: Array[Vector2i], data: TileData, possible_movement_cells: Array[Vector2i], cell: Vector2i) -> Array[Vector2i]:
	for V_direction in V_dir:
		for H_direction in H_dir:
			var next_cell = cell + (V_direction + H_direction)
			
			while not CHESS_UTILITY.is_unmovable(next_cell) and CHESS_UTILITY.is_empty(next_cell):
				possible_movement_cells.append(next_cell)
				next_cell += (V_direction + H_direction)
			
			if CHESS_UTILITY.is_enemy(next_cell, data):
				possible_movement_cells.append(next_cell)
		
	return possible_movement_cells

func move_straight(dir: Array[Vector2i], data: TileData, possible_movement_cells: Array[Vector2i], cell: Vector2i) -> Array[Vector2i]:
	for direction in dir:
		var next_cell = cell + direction
		
		while not CHESS_UTILITY.is_unmovable(next_cell) and CHESS_UTILITY.is_empty(next_cell):
			possible_movement_cells.append(next_cell)
			next_cell += direction
			
		if CHESS_UTILITY.is_enemy(next_cell, data):
			possible_movement_cells.append(next_cell)
	
	return possible_movement_cells


func get_pawn_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var possible_movement_cells: Array[Vector2i] = []
	var data = CHESS_UTILITY.get_tile_data(cell)
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
	var dir: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	var possible_movement_cells: Array[Vector2i] = []
	var data = CHESS_UTILITY.get_tile_data(cell)
	
	if CHESS_UTILITY.get_piece_data(cell) != "castle":
		return []
	
	return move_straight(dir, data, possible_movement_cells, cell)

func get_bishop_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var V_dir: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN]
	var H_dir: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT]
	var possible_movement_cells: Array[Vector2i] = []
	var data = CHESS_UTILITY.get_tile_data(cell)
	

	if CHESS_UTILITY.get_piece_data(cell) != "bishop":
		return []
	
	return move_diagonal(H_dir, V_dir, data, possible_movement_cells, cell)

func get_knight_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var possible_movement_cells: Array[Vector2i] = []
	var data = CHESS_UTILITY.get_tile_data(cell)
	var offsets: Array[Vector2i] = [
		Vector2i(1, -2), Vector2i(-1, -2),
		Vector2i(1, 2), Vector2i(-1, 2),
		Vector2i(2, -1), Vector2i(2, 1),
		Vector2i(-2, -1), Vector2i(-2, 1),
	]
	
	var next_cell: Vector2i
	
	if CHESS_UTILITY.get_piece_data(cell) != "knight":
		return []
	
	for offset in offsets:
		next_cell = cell + offset
		
		if (CHESS_UTILITY.is_empty(next_cell) or CHESS_UTILITY.is_enemy(next_cell, data)):
			possible_movement_cells.append(next_cell)
	
	return possible_movement_cells

func get_king_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var possible_movement_cells: Array[Vector2i] = []
	var data = CHESS_UTILITY.get_tile_data(cell)
	var offsets: Array[Vector2i] = [
		Vector2i(1, 1), Vector2i(1, -1),
		Vector2i(-1, 1), Vector2i(-1, -1),
		Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(1, 0)
	]
	var next_cell: Vector2i

	if CHESS_UTILITY.get_piece_data(cell) != "king":
		return []

	for offset in offsets:
		next_cell = cell + offset

		if not (CHESS_UTILITY.is_empty(next_cell) or CHESS_UTILITY.is_enemy(next_cell, data)):
			continue

		var near_enemy := false
		for offset1 in offsets:
			var beyond_cell: Vector2i = next_cell + offset1
			if CHESS_UTILITY.is_enemy(beyond_cell, data) and CHESS_UTILITY.get_piece_data(beyond_cell) == "king":
				near_enemy = true
				break

		if not near_enemy:
			possible_movement_cells.append(next_cell)

	return possible_movement_cells

func get_queen_movement_data(cell: Vector2i) -> Array[Vector2i]:
	var V_dir: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN]
	var H_dir: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT]
	var possible_movement_cells: Array[Vector2i] = []
	var data = CHESS_UTILITY.get_tile_data(cell)
	
	if CHESS_UTILITY.get_piece_data(cell) != "queen":
		return []
	
	move_diagonal(H_dir, V_dir, data, possible_movement_cells, cell)
	move_straight(H_dir + V_dir, data, possible_movement_cells, cell)

	return possible_movement_cells
