class_name Game extends Node3D

const _MAX_DIALOGUE_DONE_TO_END: int = 4
const _MAX_ASIK_VALUE :int = 3 * 7

@onready var _asik_meter_ui: ProgressBar = $CanvasLayer/AsikMeter

var _dialogue_done_count :int = 0
var _asik_meter :int = 0

# End game here
func increase_dialogue_done() -> void:
	_dialogue_done_count += 1
	if _dialogue_done_count == _MAX_DIALOGUE_DONE_TO_END:
		print("[INFO] Game done")

func increase_asik_meter(weight: int) -> void:
	# bobotnya 3 (benar), 2, 1
	var tween := self.create_tween()
	tween.tween_property(_asik_meter_ui, "value", _asik_meter + weight, 0.3)
	await tween.finished
	_asik_meter += weight
