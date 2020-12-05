extends Target

export var speed:float = 10.0
export var acceleration:float = 100.0
export var max_range:Vector3 = Vector3.ONE
export var bound_radius:float = 1.0

onready var _origin := translation

var _destination := GSAIAgentLocation.new()
var _acceleration := GSAITargetAcceleration.new()

var _agent := Agent.new(self)
var _arrive := GSAIArrive.new(_agent, _destination)
var _look := GSAIFace.new(_agent, _destination, true)
var _move := GSAIBlend.new(_agent)

func _ready():
  _agent.linear_speed_max = speed
  _agent.linear_acceleration_max = acceleration
  _agent.bounding_radius = bound_radius
  _agent.linear_drag_percentage = 0.1
  _agent.angular_acceleration_max = deg2rad(1000)
  _agent.angular_speed_max = deg2rad(1000)
  _agent.angular_drag_percentage = 0.1

  _arrive.arrival_tolerance = 0.1
  _arrive.deceleration_radius = 1.0

  _look.alignment_tolerance = deg2rad(2)
  _look.deceleration_radius = deg2rad(30)

  _move.add(_look, 1)
  _move.add(_arrive, 1)

  _pick_new_destination()

func _physics_process(delta):
  _move.calculate_steering(_acceleration)
  _agent._apply_steering(_acceleration, delta)

func _pick_new_destination():
  var x = rand_range(max_range.x / 2.0, max_range.x)
  var y = rand_range(max_range.y / 2.0, max_range.y)
  var z = rand_range(max_range.z / 2.0, max_range.z)
  var offset = Vector3(x, y, z)
  _destination.position = _origin + (offset if randf() > 0.5 else -offset)
