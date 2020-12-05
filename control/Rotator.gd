extends Spatial

export var speed:Vector3 = Vector3(0.0, 1.0, 0.0)

func _process(delta):
  rotation += speed * delta