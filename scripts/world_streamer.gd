extends Node3D
@export var player: Node3D
@export var sector_size := 80.0
@export var active_radius := 1
var current_sector := Vector2i(999999,999999)
func _process(_delta):
    if not player: return
    var s := Vector2i(floor(player.global_position.x/sector_size), floor(player.global_position.z/sector_size))
    if s != current_sector:
        current_sector = s
        # Hook for async sector loading/unloading. Keep only nearby sectors resident on Android.
