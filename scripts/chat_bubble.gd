extends Node3D

enum Speaker {
	ZAKI, NERD, PREMAN, GAUL, WIBU
}

enum Emotion {
	EXCITED, SARCASTIC, MOCKING, AMAZE, HUMBLE, FACE_SCREAMING, BIG_SMILE,
	SMILE, HAPPY, LAUGH, CRY, SURPRISE, WINK, STRAIGHT_FACE, TONGUE_TIED,
	CONFUSED, SKEPTIC, AWKWARD
}

@export var _emotion_show_index :Array[int]
@export var _speaker_order: Array[Speaker]

@onready var _player :Player = $"../Player"

@onready var _label: Label3D = $Background/Label3D
@onready var _background: MeshInstance3D = $Background
@onready var _next_dialogue_button: Area3D = $Background/InputArea
@onready var _starter_area: Area3D = $StarterArea
@onready var _options: Node3D = $Options

@export var _npc: Speaker
var _data: Dictionary

var _speaker_order_index: int = 0
var _npc_dialogue_index : int = 0
var _main_dialogue_index : int = 0


func _load_dialogue_data() -> void:
	var data_path :String = "res://dialogue_data/" + (Speaker.keys()[_npc] as String).to_lower() + ".json"
	var file = FileAccess.open(data_path, FileAccess.READ)
	var json_string = file.get_as_text() 
	_data = JSON.parse_string(json_string)
	print(_data)

func _setup_option_data() -> void:
	pass

func _ready() -> void:
	_starter_area.area_entered.connect(_on_area_entered_starter_area, CONNECT_ONE_SHOT)
	_background.hide()
	_options.hide()
	
	_setup_option_data()
	_load_dialogue_data()

func _on_area_entered_starter_area(area: Area3D) -> void:
	if area.name == "PlayerStarterArea":
		_next_dialogue_button.input_event.connect(_on_click_background)
		_change_dialogue()
		_player.set_activation(false)

func _check_option() -> void:
	if _main_dialogue_index in _emotion_show_index:
		for input_area: Area3D in _options.get_children():
			input_area.input_event.connect(_on_choosing_option.bind(input_area.get_index()))
		_set_dialogue_next_button_disabled(true)
		_options.show()
func _on_choosing_option(_cam: Node, event: InputEvent, _event_pos: Vector3, _normal: Vector3, _shape_idx: int, btn_index: int) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		print(btn_index)
		for input_area: Area3D in _options.get_children():
			input_area.input_event.disconnect(_on_choosing_option)
		_options.hide()
		_change_dialogue()
		_set_dialogue_next_button_disabled(false)

func _on_click_background(_cam: Node, event: InputEvent, _event_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_change_dialogue()
func _change_dialogue() -> void:
	_background.hide()
	
	var current_speaker: Speaker = _speaker_order[_speaker_order_index]
	var data_key: String = (Speaker.keys()[current_speaker] as String).to_upper()
	
	# Set position and label text
	if current_speaker == Speaker.ZAKI:
		_check_option()
		_background.position = $A.position
		_label.text = _data[data_key][_main_dialogue_index]
		if _main_dialogue_index + 1 < _data[data_key].size():
			_main_dialogue_index += 1
	else: 
		_background.position = $B.position
		_label.text = _data[data_key][_npc_dialogue_index]
		if _npc_dialogue_index + 1 < _data[data_key].size():
			_npc_dialogue_index += 1
	
	_background.show()
	
	if _speaker_order_index + 1 < _speaker_order.size():
		_speaker_order_index += 1
	
	# when dialogue done
	else:
		_next_dialogue_button.input_event.disconnect(_on_click_background)
		await self.get_tree().create_timer(3.0).timeout
		_background.hide()
		_player.set_activation(true)
		print("[INFO] Dialogue is finished")

func _set_dialogue_next_button_disabled(b: bool) -> void:
	(_next_dialogue_button.get_child(0) as CollisionShape3D).disabled = b
