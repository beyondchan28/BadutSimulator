class_name Game extends Node3D

const _MAX_DIALOGUE_DONE_TO_END: int = 4
const _MAX_ASIK_VALUE :int = 3 * 7

@onready var _asik_meter_ui: TextureProgressBar = $CanvasLayer/AsikMeter

var _dialogue_done_count :int = 0
var _asik_meter :int = 0

var _sfx := {
	1: preload("res://assets/audio/SFX/emosi salah.mp3"),
	2: preload("res://assets/audio/SFX/emosi salah.mp3"),
	3: preload("res://assets/audio/SFX/emosi benar.mp3")
}

var _ending_sfx := {
	0: preload("res://assets/audio/SFX/sok asik ED.mp3"),
	1: preload("res://assets/audio/SFX/Biasa aja ED.mp3"),
	2: preload("res://assets/audio/SFX/asik banget ED.mp3")
}

func _ready() -> void:
	$CanvasLayer/EndResult.hide()
	$CanvasLayer/EndResult/Buttons/Exit.pressed.connect(_on_exit_pressed)
	$CanvasLayer/EndResult/Buttons/Restart.pressed.connect(_on_restart_pressed)
	$CanvasLayer/EndResult/Buttons/BackMainMenu.pressed.connect(_on_back_main_menu_pressed)
	
	AudioManager.play_sfx(load("res://assets/audio/SFX/bell sekolah.mp3"))

func _on_exit_pressed() -> void:
	self.get_tree().quit()

func _on_restart_pressed() -> void:
	self.get_tree().reload_current_scene()

func _on_back_main_menu_pressed() -> void:
	self.get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func set_report_circle(npc: ChatBubble.Speaker, weight: int) -> void:
	var text: String
	match weight:
		1:
			text = "Kamu sok asik sama circle " + (ChatBubble.Speaker.keys()[npc] as String).capitalize()
		2:
			text = "Kamu biasa aja sama circle " + (ChatBubble.Speaker.keys()[npc] as String).capitalize()
		3:
			text = "Kamu asik sama circle " + (ChatBubble.Speaker.keys()[npc] as String).capitalize()
	AudioManager.play_sfx(_sfx[weight])
	
	var npc_as_string :String = (ChatBubble.Speaker.keys()[npc] as String).capitalize()
	var label: Label = $CanvasLayer/EndResult/Board/LabelContainer.get_node(npc_as_string)
	label.text = text


func _set_report_conclusion() -> void:
	var text: String
	if _asik_meter >= 18:
		text = "Kamu orangnya sok asik"
		AudioManager.play_sfx(_ending_sfx[0])
	elif _asik_meter >= 9:
		text = "Kamu orangnya biasa aja"
		AudioManager.play_sfx(_ending_sfx[1])
	elif _asik_meter < 9:
		text = "Kamu orangnya sok asik"
		AudioManager.play_sfx(_ending_sfx[2])
	$CanvasLayer/EndResult/Board/Conclution.text =  text

# End game here
func increase_dialogue_done() -> void:
	_dialogue_done_count += 1
	if _dialogue_done_count == _MAX_DIALOGUE_DONE_TO_END:
		_set_report_conclusion()
		$CanvasLayer/EndResult.show()
		$Player.set_activation(false)
		print("[INFO] Game done")

func increase_asik_meter(weight: int) -> void:
	# bobotnya 3 (benar), 2, 1
	var tween := self.create_tween()
	tween.tween_property(_asik_meter_ui, "value", _asik_meter + weight, 0.3)
	await tween.finished
	_asik_meter += weight

func _unhandled_input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		if $CanvasLayer/EndResult.is_visible():
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			$CanvasLayer/EndResult.hide()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			$CanvasLayer/EndResult.show()
			
