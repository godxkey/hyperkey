extends Node
class_name RadialMotion

# The angle around the orbit from the center
export(float) var angle = 0.0

# How quickly the object starts picking up speed around the orbit
export(float) var angular_acceleration = 1.0

# Slows down the object around the orbit
export(float) var angular_damping = 1.0

export(float) var max_angular_speed = 1.0
export(float) var orbit_radius = 100.0
export(Vector2) var orbit_center := Vector2()

onready var _parent = get_parent() as Node2D
var _angular_speed: float = 0.0
var _angular_acceleration: float = 0.0

func _physics_process(delta):
  move(delta)

func move(delta:float):
  if is_accelerating():
    _angular_speed += delta * _angular_acceleration
    _angular_speed = clamp(_angular_speed, -max_angular_speed, max_angular_speed)
  else:
    if is_moving():
      _angular_speed = lerp(_angular_speed, 0.0, delta * angular_damping)

  angle += delta * _angular_speed
  _parent.position = _orbital_position()

func is_moving() -> bool:
  return _angular_speed != 0.0

func is_accelerating()-> bool:
  return _angular_acceleration != 0.0

func start_moving_clockwise():
  _angular_acceleration = angular_acceleration

func start_moving_counterclockwise():
  _angular_acceleration = -angular_acceleration

func stop_moving():
  _angular_acceleration = 0.0

func to_origin() -> Vector2:
  return _parent.position.direction_to(orbit_center)

func _orbital_position() -> Vector2:
  var x = cos(angle) * orbit_radius
  var y = sin(angle) * orbit_radius
  return Vector2(x, y) + orbit_center
