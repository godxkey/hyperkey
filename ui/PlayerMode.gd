extends Label

# Called when the node enters the scene tree for the first time.
func _ready():
  var player = get_tree().get_root().find_node("Player", true, false)
  player.connect("mode_changed", self, "update_mode_text")
  update_mode_text(player.mode)

func update_mode_text(player_mode):
  match player_mode:
    Player.Mode.NAVIGATE:
      text = "NAV"
    Player.Mode.ENGAGE:
      text = "ENG"

