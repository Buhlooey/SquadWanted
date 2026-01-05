extends Area2D

func _on_body_entered(body:Node2D) -> void:
	if body.is_in_group("Face"):
		body.screenWrap(get_name())
