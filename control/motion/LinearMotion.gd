extends Node
class_name LinearMotion, "res://icons/linear_motion_icon.png"

export(float) var acceleration = 1000.0
export(float) var damping = 1500.0
export(float) var max_speed = 200.0
export(float) var motion_scale = 1.0
export(bool) var rotate = true # Align rotation with velocity direction

onready var _parent = get_parent() as Node2D

var _velocity = Vector2()
var _acceleration = Vector2()
var _accumulated_forces = Vector2()

func _physics_process(delta):
  move(delta)

func move(delta:float):
  delta *= motion_scale
  _velocity += delta * _accumulated_forces
  if is_accelerating():
    _velocity += delta * _acceleration
  else:
    if is_moving():
      _velocity = _velocity.linear_interpolate(Vector2.ZERO, delta * damping)
  _velocity = _velocity.clamped(max_speed)
  _parent.translate(_velocity * delta);
  _accumulated_forces = Vector2.ZERO
  if rotate and not _velocity.is_equal_approx(Vector2.ZERO):
    _parent.set_rotation(_velocity.angle())

func is_moving() -> bool:
  return _velocity.length_squared() > 0.0

func is_accelerating()-> bool:
  return _acceleration != Vector2.ZERO

func apply_force(force:Vector2):
  _accumulated_forces += force

func start_moving_towards(target:Vector2):
  _acceleration = _parent.global_position.direction_to(target) * acceleration

func start_moving_along(direction:Vector2):
  _acceleration = direction.normalized() * acceleration

func stop_moving():
  _acceleration = Vector2.ZERO

func get_velocity() -> Vector2:
  return _velocity

func set_velocity(value:Vector2):
  _velocity = value

func set_speed(value:float):
  if _velocity != Vector2.ZERO:
    _velocity = _velocity.normalized() * value
  else:
    _velocity = Vector2.RIGHT * value
  _velocity = _velocity.clamped(max_speed)
