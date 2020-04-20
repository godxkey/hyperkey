extends Node
class_name LinearMotion

export(float) var acceleration = 1000.0
export(float) var damping = 1500.0
export(float) var max_speed = 200.0

onready var _parent = get_parent() as Node2D

var _velocity = Vector2()
var _acceleration = Vector2()

func _physics_process(delta):
  move(delta)

func move(delta:float):
  if is_accelerating():
    _velocity += delta * _acceleration
    _velocity = _velocity.clamped(max_speed)
  else:
    if is_moving():
      _velocity = _velocity.linear_interpolate(Vector2.ZERO, delta * damping)
  _parent.translate(_velocity * delta);

func is_moving() -> bool:
  return _velocity.length_squared() > 0.0

func is_accelerating()-> bool:
  return _acceleration != Vector2.ZERO

func start_moving_towards(target:Vector2):
  _acceleration = _parent.position.direction_to(target) * acceleration

func start_moving_along(direction:Vector2):
  _acceleration = direction.normalized() * acceleration

func stop_moving():
  _acceleration = Vector2.ZERO

func get_velocity() -> Vector2:
  return _velocity
