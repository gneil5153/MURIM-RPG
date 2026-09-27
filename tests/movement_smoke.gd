extends SceneTree

func _initialize() -> void:
    call_deferred("run")

func fail(message: String) -> void:
    push_error(message)
    quit(1)

func touch(index: int, point: Vector2, pressed: bool) -> void:
    var event := InputEventScreenTouch.new()
    event.index = index
    event.position = point
    event.pressed = pressed
    root.push_input(event, true)

func run() -> void:
    root.size = Vector2i(1280, 720)
    for path in ["res://scripts/player.gd", "res://scripts/touch_controls.gd"]:
        var script: Script = load(path)
        if script == null or not script.can_instantiate():
            fail("Script cannot run: " + path)
            return
    var packed: PackedScene = load("res://scenes/main.tscn")
    var world := packed.instantiate()
    root.add_child(world)
    current_scene = world
    for i in range(5):
        await process_frame
    var controls = world.get_node("HUD/TouchControls")
    var player = world.get_node("Player")
    var center: Vector2 = controls.get_global_transform_with_canvas() * controls.stick_center()
    var start: Vector3 = player.position
    touch(0, center + Vector2(0, -30), true)
    for i in range(30):
        await physics_frame
    if player.position.z >= start.z - 0.2:
        fail("Touch press did not move player forward")
        return
    if controls.stick_sprinting:
        fail("Inner joystick should walk")
        return
    var walk_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
    var drag := InputEventScreenDrag.new()
    drag.index = 0
    drag.position = center + Vector2(0, -65)
    root.push_input(drag, true)
    for i in range(30):
        await physics_frame
    if not controls.stick_sprinting or Vector2(player.velocity.x, player.velocity.z).length() <= walk_speed + 1.0:
        fail("Outer joystick did not sprint")
        return
    touch(1, center + Vector2(200, 0), false)
    if controls.move_touch != 0:
        fail("Unrelated finger released movement")
        return
    touch(0, center, false)
    for i in range(40):
        await physics_frame
    if player.touch_move.length() > 0.01 or player.touch_sprinting or Vector2(player.velocity.x, player.velocity.z).length() > 0.05:
        fail("Release did not stop player")
        return
    print("PASS: touch press moves forward; outer drag sprints; independent fingers; release stops")
    quit(0)
