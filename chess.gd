extends Node2D

@export var movable_layer: TileMapLayer
@onready var piece_movement: Piece_movement_data = $PieceMovement

func move_piece(from: Vector2i, to: Vector2i):
	var src = movable_layer.get_cell_source_id(from)
	var atlas = movable_layer.get_cell_atlas_coords(from)
	
	movable_layer.erase_cell(from)
	movable_layer.set_cell(to, src, atlas)


#dispatcher
func get_moves(cell: Vector2i) -> Array[Vector2i]:
	match CHESS_UTILITY.get_piece_data(cell):
		"pawn": return piece_movement.get_pawn_movement_data(cell)
		"knight": return piece_movement.get_knight_movement_data(cell)
		"bishop": return piece_movement.get_bishop_movement_data(cell)
		"king": return piece_movement.get_king_movement_data(cell)
		"queen": return piece_movement.get_queen_movement_data(cell)
		"castle": return piece_movement.get_castle_movement_data(cell)
		_: return []

func _ready() -> void:
	CHESS_UTILITY.movable_layer = movable_layer

#debug code
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		var cell := movable_layer.local_to_map(movable_layer.get_local_mouse_position())
		print(get_moves(cell))
