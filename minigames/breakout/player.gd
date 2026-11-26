extends CharacterBody2D

@onready var animationPlayer: AnimatedSprite2D = $AnimatedSprite2D
@export var speedPlayerDefault: float = 260.0

var gamepad: Dictionary = {
	"right": KEY_D,
	"left": KEY_A
}
var deadPlayer: bool = false
var _last_status_msg: String = ""

func _ready() -> void:
	animationPlayer.play("Up")

func logPlayer(msg: String) -> void:
	if msg != _last_status_msg:
		print(msg)
		_last_status_msg = msg

func validationPlayer(limite_inferior_speed: float, limite_superior_speed: float) -> bool:
	if speedPlayerDefault <= limite_inferior_speed or speedPlayerDefault >= limite_superior_speed:
		logPlayer("Velocidad fuera de rango permitido (%.1f - %.1f)" % [limite_inferior_speed, limite_superior_speed])
		return false

	if not gamepad.has("left") or not gamepad.has("right"):
		logPlayer("Configure primero los controles para jugar")
		return false

	_last_status_msg = ""
	return true

func set_controls(left_key: Key, right_key: Key) -> void:
	gamepad["left"] = left_key
	gamepad["right"] = right_key

func _physics_process(_delta: float) -> void:
	if deadPlayer:
		lose()
		reset()
		return

	if not validationPlayer(50.5, 320.8):
		reset()
		return

	var dir := 0.0
	animationPlayer.play("Up")
	
	if Input.is_key_pressed(gamepad["right"]):
		animationPlayer.play("Walk_Right")
		dir += 1.0
	if Input.is_key_pressed(gamepad["left"]):
		animationPlayer.play("Walk_Left")
		dir -= 1.0

	velocity.x = dir * speedPlayerDefault
	velocity.y = 0.0
	move_and_slide()
	
func reset() -> void:
	velocity = Vector2.ZERO
	move_and_slide()
	
func lose() -> void:
	deadPlayer = true
	animationPlayer.play("Lose")
