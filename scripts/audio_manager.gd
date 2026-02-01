extends Node

var _bgm := AudioStreamPlayer.new()

func _ready() -> void:
	_bgm.stream = load("res://assets/audio/BGM/BGM Badut Kelas.mp3")
	_bgm.autoplay = true
	self.add_child(_bgm)

func play_sfx(stream: AudioStream) -> void:
	var stream_player := AudioStreamPlayer.new()
	stream_player.stream = stream
	stream_player.autoplay = true
	stream_player.finished.connect(_on_sfx_finished.bind(stream_player))
	self.add_child(stream_player)

func _on_sfx_finished(sp: AudioStreamPlayer) -> void:
	sp.queue_free()
