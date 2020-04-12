class_name Player

extends KinematicBody2D

enum Mode {NAVIGATE, ENGAGE}

export(float) var acceleration_strength = 1500.0
export(float) var brake_strength = 1000.0
export(float) var max_speed = 400.0
export(float) var rotation_smoothing = 12.0

onready var sprite := $Sprite as Sprite
var mode = Mode.NAVIGATE
var aimed_target:Node2D = null

var _acceleration := Vector2(0,0)
var _velocity := Vector2(0,0)

signal mode_changed
signal engage_shot_event

func _physics_process(delta):
  move(delta)

func _process(delta):
  _acceleration = acceleration_input()
  rotate_sprite(delta)

func _input(event):
  handle_player_mode(event)
  if mode == Mode.ENGAGE:
    emit_signal("engage_shot_event", event)

func handle_player_mode(event):
  if event.is_action_pressed("game_switch_mode"):
    match mode:
      Mode.NAVIGATE:
        mode = Mode.ENGAGE
      Mode.ENGAGE:
        mode = Mode.NAVIGATE
    emit_signal("mode_changed", mode)

func aim_rotation_angle() -> float:
  if mode == Mode.ENGAGE and aimed_target != null:
    return get_angle_to(aimed_target.position)
  if is_moving():
    return _velocity.angle()
  else:
    return sprite.rotation

func rotate_sprite(delta:float):
  if mode == Mode.ENGAGE or is_moving():
    var current_rotation = Transform2D(sprite.rotation, Vector2.ZERO)
    var target_rotation = Transform2D(aim_rotation_angle(), Vector2.ZERO)
    var rotation_step = current_rotation.interpolate_with(target_rotation, delta * rotation_smoothing)
    sprite.set_rotation(rotation_step.get_rotation())

func move(delta:float):
  if is_accelerating():
    _velocity += delta * _acceleration
    _velocity = _velocity.clamped(max_speed)
  else:
    if is_moving():
      _velocity = _velocity.move_toward(Vector2.ZERO, delta * brake_strength)
  _velocity = move_and_slide(_velocity)

func is_accelerating():
  return _acceleration != Vector2.ZERO

func is_moving() -> bool:
  return _velocity.length_squared() > 0.0

func acceleration_input() -> Vector2:
  if mode == Mode.NAVIGATE:
    var horizontal_direction = input_horizontal_direction()
    var vertical_direction = input_vertical_direction()
    return Vector2(horizontal_direction, vertical_direction).normalized() * acceleration_strength
  else:
    return Vector2.ZERO

func input_horizontal_direction() -> float:
  if Input.is_action_pressed("game_left"):
    return -1.0
  elif Input.is_action_pressed("game_right"):
    return 1.0
  return 0.0

func input_vertical_direction() -> float:
  if Input.is_action_pressed("game_up"):
    return -1.0
  elif Input.is_action_pressed("game_down"):
    return 1.0
  return 0.0
