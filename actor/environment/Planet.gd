extends StaticBody2D

onready var health = $Health as Health

func _ready():
  health.connect("no_health", self, "queue_free")
