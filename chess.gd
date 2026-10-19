extends Node2D

@export var movable_layer: TileMapLayer
@export var hint_layer: TileMapLayer
@onready var piece_movement: Piece_movement_data = $PieceMovement
@onready var promotion_ui = $Promotion_ui

var pending_promotion_cell: Vector2i
var waiting_for_promotion: bool = false
enum Turns {P1,P2}
var current_turn: Turns = Turns.P1

var is_checked: bool = false

var selected_cell: Vector2i
var has_selection: bool = false

var p1_atlas: Dictionary[String, Vector2i] = {
	"queen": Vector2i(16, 1),
	"knight": Vector2i(12, 1),
	"castle": Vector2i(10, 2),
	"bishop": Vector2i(14, 1),
}
var p2_atlas: Dictionary[String, Vector2i] = {
	"queen": Vector2i(16, 5),
	"knight": Vector2i(12, 5),
	"castle": Vector2i(10, 6),
	"bishop": Vector2i(14, 5),
}


func show_hints(cell: Vector2i):
	var src:= 0
	var atlas:= Vector2i(0,0)
	for target in get_moves(cell):
		hint_layer.set_cell(target,src,atlas)

func clear_hints():
	hint_layer.clear()

func promote_pawn(cell: Vector2i,promote_to: Vector2i):
	var src = movable_layer.get_cell_source_id(cell)
	if CHESS_UTILITY.get_piece_data(cell) == "pawn":
		movable_layer.set_cell(cell,src,promote_to)

func belongs_to_turn(cell: Vector2i, turn: Turns) -> bool:
	var data = movable_layer.get_cell_tile_data(cell)
	if CHESS_UTILITY.is_empty(cell):
		return false
	
	if turn == Turns.P1:
		return data.get_custom_data("P1")
	return data.get_custom_data("P2")

func switch_turn() -> Turns:
	current_turn = Turns.P2 if current_turn == Turns.P1 else Turns.P1
	return current_turn

func check_detection() ->bool:
	for target_cell in movable_layer.get_used_cells():
		if CHESS_UTILITY.is_unmovable(target_cell):
			continue
		
		for cell in get_moves(target_cell):
			if CHESS_UTILITY.get_piece_data(cell) == "king" and belongs_to_turn(cell, current_turn):
				return true
	return false

func move_piece(from: Vector2i, to: Vector2i) -> bool:
	if not get_moves(from).has(to):
		return false

	var src = movable_layer.get_cell_source_id(from)
	var atlas = movable_layer.get_cell_atlas_coords(from)

	movable_layer.erase_cell(from)
	movable_layer.set_cell(to, src, atlas)
	return true

	
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
	promotion_ui.piece_chosen.connect(_on_piece_chosen)


func _on_piece_chosen(piece: String):
	var side_atlas: Dictionary[String,Vector2i]
	
	if current_turn == Turns.P1:
		side_atlas = p1_atlas
	else:
		side_atlas = p2_atlas

	promote_pawn(pending_promotion_cell,side_atlas[piece])
	waiting_for_promotion = false
	promotion_ui.visible = false
	
	switch_turn()	

func _physics_process(delta: float) -> void:
	is_checked = check_detection()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		get_tree().reload_current_scene()

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("click"):
		return

	var clicked_cell := movable_layer.local_to_map(movable_layer.get_local_mouse_position())
	var promotion_offset: Vector2i
	
	if current_turn == Turns.P1:
		promotion_offset = Vector2i(0,-1)
	elif current_turn == Turns.P2:
		promotion_offset = Vector2i(0,1)
		
	if not has_selection:
		if belongs_to_turn(clicked_cell,current_turn):
			selected_cell = clicked_cell
			has_selection = true
			show_hints(selected_cell)
	else:
		hint_layer.clear()
		if move_piece(selected_cell, clicked_cell):
			if CHESS_UTILITY.is_unmovable(clicked_cell + promotion_offset) and CHESS_UTILITY.get_piece_data(clicked_cell) == "pawn":
				pending_promotion_cell = clicked_cell
				waiting_for_promotion = true
				promotion_ui.visible = true
			else:
				switch_turn()
		has_selection = false
