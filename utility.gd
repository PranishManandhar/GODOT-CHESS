extends Node

var movable_layer: TileMapLayer

func is_enemy(cell: Vector2i,my_data:TileData) -> bool:
	var other = movable_layer.get_cell_tile_data(cell)
	
	if other == null:
		return false

	if my_data.get_custom_data("P1"):
		return other.get_custom_data("P2")
	return other.get_custom_data("P1")

func is_empty(cell:Vector2i) -> bool:
	return movable_layer.get_cell_source_id(cell) == -1

func is_unmovable(cell: Vector2i)-> bool:
	var data = movable_layer.get_cell_tile_data(cell)
	return data!=null and data.get_custom_data("unmovable")

func get_piece_data(cell: Vector2i) -> String:
	var data = movable_layer.get_cell_tile_data(cell)
	var piece_type:= ["pawn","king","queen","bishop","knight","castle"]
	
	for piece in piece_type:
		if data != null and data.get_custom_data(piece):
			return piece	
	return ""
