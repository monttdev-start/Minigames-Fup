extends CharacterBody2D
signal hit_bottom

@onready var animationPlayer: AnimatedSprite2D = $AnimatedSprite2D
@export var speed: float = 550.0
@export var spin_speed: float = 20.0 
var direction: Vector2 = Vector2(0.6, -0.8).normalized()

func _ready() -> void:
	if animationPlayer and animationPlayer.sprite_frames:
		var anim_names := animationPlayer.sprite_frames.get_animation_names()
		if anim_names.size() > 0:
			animationPlayer.play(anim_names[0])

func _physics_process(delta: float) -> void:
	var motion := direction * speed * delta
	var collision := move_and_collide(motion)

	if collision:
		var normal := collision.get_normal()
		direction = direction.bounce(normal)
		
		var collider := collision.get_collider()
		if collider != null and (collider.name == "Abajo" or (collider.get_parent() != null and collider.get_parent().name == "Abajo")):
			hit_bottom.emit()
			return

		if abs(direction.y) < 0.25:
			direction.y = -0.25 if direction.y <= 0.0 else 0.25

		if collider and collider.is_in_group("obs"):
			collider.queue_free()
		elif collider and collider.is_in_group("player"):
			var offset = (global_position.x - collider.global_position.x) / 40.0
			direction.x = clamp(direction.x + offset * 0.4, -0.9, 0.9)

		direction = direction.normalized()

	var spin_dir := 1.0 if direction.x >= 0.0 else -1.0
	rotation += spin_dir * spin_speed * delta
