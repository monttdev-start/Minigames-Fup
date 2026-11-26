extends CanvasLayer

@onready var win_panel: Control = $WinPanel
@onready var lose_panel: Control = $LosePanel
@onready var win_anim: AnimatedSprite2D = $WinPanel/WinAnim
@onready var lose_anim: AnimatedSprite2D = $LosePanel/LoseAnim

@export var win_sound: AudioStream
@export var lose_sound: AudioStream

var sfx_player: AudioStreamPlayer

const LOGO := preload("res://breakout/assets/logoFup.jpg")

var end_screen: ColorRect
var title_label: Label

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_build_end_screen()
	_add_logo()
	
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	end_screen.hide()
	_setup_panel(win_panel, win_anim)
	_setup_panel(lose_panel, lose_anim)

func _play_sound(sound: AudioStream) -> void:
	if sound == null:
		return
	sfx_player.stream = sound
	sfx_player.play()

func _setup_panel(panel: Control, anim: AnimatedSprite2D) -> void:
	panel.hide()
	panel.z_index = 1 
	anim.scale = Vector2(6, 6)
	anim.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST  
	var screen_size := get_viewport().get_visible_rect().size
	anim.position = screen_size / 2 + Vector2(0, -140) 

func _build_end_screen() -> void:
	end_screen = ColorRect.new()
	end_screen.color = Color(0, 0, 0, 0.7)
	end_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(end_screen)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	end_screen.add_child(center)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 20)
	center.add_child(box)

	title_label = Label.new()
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 48)
	box.add_child(title_label)

	var restart_button := Button.new()
	restart_button.text = "Jugar de Nuevo?"
	restart_button.add_theme_font_size_override("font_size", 24)
	restart_button.pressed.connect(_on_restart_pressed)
	box.add_child(restart_button)

func show_win() -> void:
	if not is_inside_tree():
		return
	title_label.text = "YOU WIN!"
	end_screen.show()
	win_panel.show()
	_play_sound(win_sound)
	get_tree().paused = true

func show_game_over() -> void:
	if not is_inside_tree():
		return
	title_label.text = "GAME OVER"
	end_screen.show()
	lose_panel.show()
	_play_sound(lose_sound)
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _add_logo() -> void:
	var logo := TextureRect.new()
	logo.texture = LOGO
	logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	logo.size = Vector2(150, 150)  
	end_screen.add_child(logo)

	var screen_size := get_viewport().get_visible_rect().size
	logo.position = Vector2(screen_size.x - logo.size.x - 20, 20)  
