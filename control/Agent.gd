extends GSAISpecializedAgent

# Agent that only moves the position of the body. No physics.

class_name Agent

# The body to keep track of.
var body:Spatial setget _set_body
var _body_ref:WeakRef

var _last_position:Vector3

func _init(_body:Spatial) -> void:
  if not _body.is_inside_tree():
    yield(_body, "ready")

  self.body = _body

  # warning-ignore:return_value_discarded
  _body.get_tree().connect(
    "physics_frame", self, "_on_SceneTree_physics_frame"
  )

# Moves the agent's `body` by target `acceleration`.
# @tags - virtual
func _apply_steering(acceleration: GSAITargetAcceleration, delta: float) -> void:
  _applied_steering = true
  _apply_position_steering(acceleration.linear, delta)
  _apply_orientation_steering(acceleration.angular, delta)

func _apply_position_steering(accel: Vector3, delta: float) -> void:
  var _body:Spatial = _body_ref.get_ref()
  if not _body:
    return

  var velocity := GSAIUtils.clampedv3(linear_velocity + accel * delta, linear_speed_max)
  if apply_linear_drag:
    velocity = velocity.linear_interpolate(Vector3.ZERO, linear_drag_percentage)

  # _body.translate(velocity * delta)
  _body.global_transform.origin += velocity * delta

  if calculate_velocities:
    linear_velocity = velocity


func _apply_orientation_steering(angular_acceleration: float, delta: float) -> void:
  var _body:Spatial = _body_ref.get_ref()
  if not _body:
    return

  var velocity = clamp(
    angular_velocity + angular_acceleration * delta,
    -angular_acceleration_max,
    angular_acceleration_max
  )

  if apply_angular_drag:
    velocity = lerp(velocity, 0, angular_drag_percentage)

  _body.rotation.y += velocity * delta

  if calculate_velocities:
    angular_velocity = velocity


func _set_body(value:Spatial) -> void:
  body = value
  _body_ref = weakref(value)

  _last_position = value.transform.origin
  _last_orientation = value.rotation.y

  position = _last_position
  orientation = _last_orientation


func _on_SceneTree_physics_frame() -> void:
  var _body:Spatial = _body_ref.get_ref()
  if not _body:
    return

  var current_position := _body.transform.origin
  var current_orientation := _body.rotation.y

  position = current_position
  orientation = current_orientation

  if calculate_velocities:
    if _applied_steering:
      _applied_steering = false
    else:
      linear_velocity = GSAIUtils.clampedv3(
        current_position - _last_position, linear_speed_max
      )
      if apply_linear_drag:
        linear_velocity = linear_velocity.linear_interpolate(
          Vector3.ZERO, linear_drag_percentage
        )

      angular_velocity = clamp(
        _last_orientation - current_orientation,
        -angular_speed_max,
        angular_speed_max
      )

      if apply_angular_drag:
        angular_velocity = lerp(
          angular_velocity, 0, angular_drag_percentage
        )

      _last_position = current_position
      _last_orientation = current_orientation
