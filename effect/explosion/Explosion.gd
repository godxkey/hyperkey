extends Node2D

export var sound_tag:String

func _ready():
  Sound.play(sound_tag)
  Effect.play_impact_camera_shake()
