extends Node3D

enum Speaker {
	ZAKI, NERD, PREMAN, GAUL, WIBU
}

@export var _emotion_show_index :Array[int]
@export var _speaker_order: Array[Speaker]

@onready var _label: Label3D = $Background/Label3D
@onready var _background: MeshInstance3D = $Background
@onready var _input_area: Area3D = $Background/InputArea
@onready var _starter_area: Area3D = $StarterArea

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

func _ready() -> void:
	_starter_area.area_entered.connect(_on_area_entered_starter_area)
	_input_area.input_event.connect(_on_click_background)
	_background.hide()
	_load_dialogue_data()
	_change_dialogue()

func _on_click_background(_cam: Node, event: InputEvent, _event_pos: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		_change_dialogue()

func _on_area_entered_starter_area(area: Area3D) -> void:
	print(area.name)

func _check_option() -> void:
	pass

func _change_dialogue() -> void:
	_background.hide()
	
	var current_speaker: Speaker = _speaker_order[_speaker_order_index]
	var data_key: String = (Speaker.keys()[current_speaker] as String).to_upper()
	
	# Set position and label text
	if current_speaker == Speaker.ZAKI:
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
	else:
		_input_area.input_event.disconnect(_on_click_background)
		await self.get_tree().create_timer(3.0).timeout
		_background.hide()
		print("[INFO] Dialogue is finished")
