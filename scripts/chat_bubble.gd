extends Node3D

enum Speaker {
	ZAKI, NERD, PREMAN, GAUL, WIBU
}

enum Emotion {
	EXCITED, SARCASTIC, MOCKING, AMAZE, HUMBLE, FACE_SCREAMING, BIG_SMILE,
	SMILE, HAPPY, LAUGH, CRY, SURPRISE, WINK, STRAIGHT_FACE, TONGUE_TIED,
}

@export var _emotion_show_index :Array[int]
@export var _speaker_order: Array[Speaker]

@onready var _player :Player = $"../Player"

@onready var _label: Label3D = $Background/Label3D
@onready var _background: MeshInstance3D = $Background
@onready var _next_dialogue_button: Area3D = $Background/InputArea
@onready var _starter_area: Area3D = $StarterArea
@onready var _options: Node3D = $Options
@onready var  _game: Game = $"../"


@export var _npc: Speaker
var _emotion_option_order: Array[Array]
var _emotion_order_index := 0

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
	match _npc:
		Speaker.WIBU:
			_emotion_option_order.append([
				Emotion.SARCASTIC,
				Emotion.AMAZE,
				Emotion.EXCITED
			])
			_emotion_option_order.append([
				Emotion.SARCASTIC,
				Emotion.SMILE,
				Emotion.BIG_SMILE
			])

func _check_option_weight(emo: Emotion) -> int:
	match _npc:
		Speaker.WIBU:
			if _emotion_order_index - 1 == 0:
				match emo:
					Emotion.SARCASTIC:
						return 2
					Emotion.AMAZE:
						return 1
					Emotion.EXCITED:
						return 3
					_:
						return 0
			elif _emotion_order_index - 1 == 1:
				match emo:
					Emotion.SARCASTIC:
						return 3
					Emotion.SMILE:
						return 2
					Emotion.BIG_SMILE:
						return 1
					_:
						return 0
			else:
				return 0
			
		_:
			return 0

func _ready() -> void:
	_starter_area.area_entered.connect(_on_area_entered_starter_area, CONNECT_ONE_SHOT)
	_background.hide()
	_options.hide()
	
	_setup_option_data()
	_load_dialogue_data()

func _load_emotion_texture() -> void:
	var folder_path = "res://assets/emoticons/"
	for i: int in range(3):
		var input_area: Area3D = _options.get_child(i)
		var emotion: Emotion = _emotion_option_order[_emotion_order_index][i]
		var emotion_as_string: String = (Emotion.keys()[emotion] as String).to_lower()
		print(emotion_as_string)
		input_area.set_meta("emo", emotion)
		var texture: CompressedTexture2D = load(folder_path + emotion_as_string + ".png")
		((input_area.get_child(1) as MeshInstance3D).get_surface_override_material(0) as StandardMaterial3D).albedo_texture = texture
	_emotion_order_index += 1

func _on_area_entered_starter_area(area: Area3D) -> void:
	print(area.name)
	if area.name == "PlayerStarterArea":
		_next_dialogue_button.input_event.connect(_on_click_background)
		_change_dialogue()
		_player.camera.set_current(false)
		$Camera3D.set_current(true)
		_player.set_activation(false)

func _check_option() -> void:
	if _main_dialogue_index in _emotion_show_index:
		for input_area: Area3D in _options.get_children():
			input_area.input_event.connect(_on_choosing_option.bind(input_area.get_index()))
		_set_dialogue_next_button_disabled(true)
		_load_emotion_texture()
		_options.show()
func _on_choosing_option(_cam: Node, event: InputEvent, _event_pos: Vector3, _normal: Vector3, _shape_idx: int, btn_index: int) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		
		# check wieght
		var emo: Emotion = _options.get_child(btn_index).get_meta("emo")
		var weight : int = _check_option_weight(emo)
		_game.increase_asik_meter(weight)
		
		# set mask
		var option_input_visual: MeshInstance3D = _options.get_child(btn_index).get_child(1)
		var texture: CompressedTexture2D = (option_input_visual.get_surface_override_material(0) as StandardMaterial3D).albedo_texture
		_player.set_mask(texture)
		
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
		_player.camera.set_current(true)
		$Camera3D.set_current(false)
		_player.set_activation(true)
		_player.set_mask(null)
		_game.increase_dialogue_done()
		print("[INFO] Dialogue is finished")
		self.queue_free()

func _set_dialogue_next_button_disabled(b: bool) -> void:
	(_next_dialogue_button.get_child(0) as CollisionShape3D).disabled = b
