extends Camera3D

var character : CharacterBody3D

func _ready():
	# ルートノードからCharacterBody3Dを探す
	character = get_parent().get_node("CharacterBody3D")

func _process(_delta):
	if not character: return

	look_at(character.global_transform.origin, Vector3.UP)

	if character.global_transform.origin.y < -0.1:
		# カメラの位置をキャラクターの位置に合わせる
		global_transform.origin = character.global_transform.origin + Vector3(0, 0.75, -1.5)
