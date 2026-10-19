extends CanvasLayer

signal piece_chosen(piece:String)


func _on_knight_button_pressed() -> void:
	piece_chosen.emit("knight")

func _on_bishop_button_pressed() -> void:
	piece_chosen.emit("bishop")

func _on_queen_button_pressed() -> void:
	piece_chosen.emit("queen")

func _on_castle_button_pressed() -> void:
	piece_chosen.emit("castle")
