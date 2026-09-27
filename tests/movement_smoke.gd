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
    var dummy = world.get_node("TrainingDummy")
    dummy.position.x = 20.0
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
    player.position = Vector3(0, 0.05, 0)
    player.velocity = Vector3.ZERO
    player.facing = Vector3.FORWARD
    dummy.position = Vector3(0, 0, -2.2)
    for i in range(5):
        await physics_frame
    var attack_point: Vector2 = controls.get_global_transform_with_canvas() * (controls.get_node("Attack").position + controls.get_node("Attack").size / 2.0)
    var dodge_point: Vector2 = controls.get_global_transform_with_canvas() * (controls.get_node("Dodge").position + controls.get_node("Dodge").size / 2.0)
    touch(2, attack_point, true)
    if dummy.health != 80.0 or dummy.hits != 1 or not player.attack_visual.visible:
        fail("Attack touch did not produce exactly one visible damaging hit")
        return
    touch(2, attack_point, false)
    touch(2, attack_point, true)
    touch(2, attack_point, false)
    if dummy.hits != 1:
        fail("Attack cooldown allowed a duplicate hit")
        return
    dummy.position.x = 20.0
    start = player.position
    var qi_before: float = player.qi
    touch(3, dodge_point, true)
    touch(3, dodge_point, false)
    if player.qi > qi_before - 14.0:
        fail("Dodge did not consume Qi")
        return
    for i in range(15):
        await physics_frame
    if player.position.z > start.z - 2.0:
        fail("Stationary dodge did not displace player")
        return
    for i in range(30):
        await physics_frame
    touch(0, center + Vector2(45, 0), true)
    for i in range(5):
        await physics_frame
    if player.facing.x < 0.9:
        fail("Joystick aim was not stored")
        return
    touch(0, center, false)
    start = player.position
    touch(1, dodge_point, true)
    touch(1, dodge_point, false)
    if controls.move_touch != -1 or player.touch_move.length() > 0.01:
        fail("Released joystick did not clear movement input")
        return
    for i in range(15):
        await physics_frame
    if player.position.x < start.x + 2.0:
        fail("Dodge did not preserve the last joystick direction after release")
        return
    touch(0, center + Vector2(45, 0), true)
    touch(2, attack_point, true)
    touch(2, attack_point, false)
    if controls.move_touch != 0 or not player.attack_visual.visible or player.facing.x < 0.9:
        fail("Attack did not aim along joystick direction during multitouch")
        return
    touch(0, center, false)
    var camera = player.camera_pivot.get_node("Camera3D")
    var initial_yaw: float = player.camera_pivot.rotation.y
    var initial_pitch: float = camera.rotation.x
    touch(0, center + Vector2(0, -35), true)
    touch(4, Vector2(900, 300), true)
    var camera_drag := InputEventScreenDrag.new()
    camera_drag.index = 4
    camera_drag.position = Vector2(950, 340)
    root.push_input(camera_drag, true)
    if absf(player.camera_pivot.rotation.y - initial_yaw) < 0.1 or absf(camera.rotation.x - initial_pitch) < 0.1:
        fail("Right-side touch drag did not rotate camera yaw and pitch")
        return
    if controls.move_touch != 0 or player.touch_move.length() < 0.5:
        fail("Camera drag interrupted movement joystick")
        return
    touch(4, Vector2(950, 340), false)
    touch(0, center, false)
    print("PASS: attack/dodge joystick aim, movement; simultaneous right-side camera orbit and pitch")
    quit(0)
