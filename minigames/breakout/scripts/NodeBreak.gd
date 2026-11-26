extends Node2D

signal score_changed(current_score: int, max_score: int)
signal target_reached(final_score: int)

@export var trash_scene: PackedScene
@export var carton_scene: PackedScene
@onready var ball: Node = $Ball
@onready var ui = $CanvasLayer   

var finished := false

@export var rows: int = 3          # N (filas)
@export var cols: int = 8          # M (columnas)
@export var spacing: Vector2 = Vector2(40, 28)
@export var grid_origin: Vector2 = Vector2(120, 90)
@export var max_score: int = 100

var score: int = 0
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	ball.hit_bottom.connect(_on_ball_hit_bottom)
	target_reached.connect(_on_target_reached)

	rng.randomize()
	_generate_grid()
	print("Puntaje inicial: %d / %d" % [score, max_score])

func _on_ball_hit_bottom() -> void:
	if finished:
		return
	finished = true
	ui.show_game_over()

func _on_target_reached(_final_score: int) -> void:
	if finished:
		return
	finished = true
	ui.show_win()

func _generate_grid() -> void:
	max_score = 0
	print("Viewport: ", get_viewport_rect().size, " | Spacing: ", spacing)
	var viewport_width := get_viewport_rect().size.x
	var total_grid_width := (cols - 1) * spacing.x
	var centered_x := (viewport_width - total_grid_width) * 0.5

	for r in range(rows):
		for c in range(cols):
			var roll := rng.randi()
			var scene_to_use: PackedScene = trash_scene if (roll % 2 == 0) else carton_scene
			var pts: int = 2 if (roll % 2 == 0) else 1

			if scene_to_use == null:
				continue

			max_score += pts
			var obs := scene_to_use.instantiate() as Node2D
			var pos := Vector2(centered_x + c * spacing.x, grid_origin.y + r * spacing.y)
			obs.position = pos
			obs.add_to_group("obs")
			obs.set_meta("points", pts)
			obs.tree_exited.connect(_on_obs_destroyed.bind(pts))
			add_child(obs)

func _on_obs_destroyed(pts: int) -> void:
	if score >= max_score:
		return
	if finished:
		return

	score = min(score + pts, max_score)
	print("+%d pts -> Puntaje: %d / %d" % [pts, score, max_score])
	score_changed.emit(score, max_score)

	if score >= max_score:
		print("¡Meta alcanzada! Puntaje final: %d" % score)
		target_reached.emit(score)
