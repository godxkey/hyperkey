extends Area2D

func _on_Shield_area_entered(other):
  if other.is_in_group("BaseActor"):
    other.get_node("Health").instakill()