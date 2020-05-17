extends Area2D
class_name BaseActor, "res://icons/base_actor_icon.png"

onready var health = $Health as Health
onready var sprite = $Sprite as Sprite
onready var motion = $FollowTarget as FollowTarget