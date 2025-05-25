extends Control

@onready var text: RichTextLabel = $RichTextLabel

func _process(_delta):
	var character = get_parent().get_node("CharacterBody3D")
	if not character: return
	
	if character.global_transform.origin.y < -0.1:
		text.visible = true
		
