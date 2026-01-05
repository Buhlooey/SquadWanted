extends "Face.gd"

func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event.is_action_pressed("click"):
		get_viewport().set_input_as_handled()

		#respond to correct click
		print("AAAHH!!!!!!!")
		gameNode.incrementScore()
		gameNode.moveVelocity += 20
		gameNode.faces += 2
		gameNode.reinitializeGame()