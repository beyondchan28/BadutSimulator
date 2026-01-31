extends Control

func _ready() -> void:
	$HowToPlay.hide()
	$Back.hide()
	
	$LogoAndButtons/Buttons/Play.pressed.connect(_on_play)
	$LogoAndButtons/Buttons/Exit.pressed.connect(_on_exit)
	$LogoAndButtons/Buttons/HowToPlay.pressed.connect(_on_how_to_play)
	$Back.pressed.connect(_on_back)

func _on_play() -> void:
	self.get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_how_to_play() -> void:
	$LogoAndButtons.hide()
	$HowToPlay.show()
	$Back.show()

func _on_back() -> void:
	$LogoAndButtons.show()
	$Back.hide()
	$HowToPlay.hide()

func _on_exit() -> void:
	self.get_tree().quit()
