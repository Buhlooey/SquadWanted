extends "Face.gd"



func _on_input_event(viewport:Node, event:InputEvent, shape_idx:int) -> void:
	if event.is_action_pressed("click"):
		#respond to correct click
		print("AAAHH!!!!!!!")
		get_viewport().set_input_as_handled()