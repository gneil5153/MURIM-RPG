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
    var character_model = player.get_node("Mesh")
    if character_model.get_child_count() < 30 or character_model.get_node_or_null("Hair cap") == null or character_model.get_node_or_null("Sword sheath") == null:
        fail("Stylized wuxia character model was not built")
        return
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
    if character_model.walk_phase < 0.2:
        fail("Character did not animate while walking")
        return
    var drag := InputEventScreenDrag.new()
    drag.index = 0
    drag.position = center + Vector2(0, -46)
    root.push_input(drag, true)
    for i in range(30):
        await physics_frame
    var mid_speed: float = Vector2(player.velocity.x, player.velocity.z).length()
    if mid_speed <= walk_speed + 1.0:
        fail("Joystick extension did not smoothly increase movement speed")
        return
    var yaw_before_turn: float = player.get_node("Mesh").rotation.y
    drag.position = center + Vector2(60, 0)
    root.push_input(drag, true)
    if absf(wrapf(player.get_node("Mesh").rotation.y - yaw_before_turn, -PI, PI)) > 0.01:
        fail("Character rotation snapped immediately on joystick direction change")
        return
    await physics_frame
    var turn_amount: float = absf(wrapf(player.get_node("Mesh").rotation.y - yaw_before_turn, -PI, PI))
    if turn_amount <= 0.01 or turn_amount > 0.5:
        fail("Character turn was not smooth and responsive")
        return
    drag.position = center + Vector2(0, -65)
    root.push_input(drag, true)
    for i in range(30):
        await physics_frame
    if not controls.stick_sprinting or Vector2(player.velocity.x, player.velocity.z).length() <= mid_speed + 1.5:
        fail("Outer joystick did not reach a faster sprint")
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
    print("PASS: joystick extension scales speed; sprint and turns blend smoothly; independent fingers; release brakes")
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
    if player.position.z < start.z + 2.0:
        fail("Neutral joystick dodge should move backward")
        return
    for stick_direction in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
        for i in range(36):
            await physics_frame
        player.position = Vector3(0, 0.05, 0)
        player.velocity = Vector3.ZERO
        player.qi = player.max_qi
        player.dodge_cooldown = 0.0
        player.facing = Vector3.FORWARD
        player.get_node("Mesh").rotation = Vector3.ZERO
        var expected_forward: Vector3 = -player.camera_pivot.global_transform.basis.z
        expected_forward.y = 0.0
        expected_forward = expected_forward.normalized()
        var expected_right: Vector3 = player.camera_pivot.global_transform.basis.x
        expected_right.y = 0.0
        expected_right = expected_right.normalized()
        var expected_direction: Vector3 = (expected_right * stick_direction.x - expected_forward * stick_direction.y).normalized()
        var stick_point: Vector2 = center + stick_direction * 45.0
        touch(0, stick_point, true)
        var direction_start: Vector3 = player.position
        touch(1, dodge_point, true)
        if player.dodge_direction.dot(expected_direction) < 0.98:
            fail("Dodge direction did not match joystick vector " + str(stick_direction))
            return
        for i in range(15):
            await physics_frame
        var displacement: Vector3 = player.position - direction_start
        displacement.y = 0.0
        if displacement.dot(expected_direction) < 2.0:
            fail("Dodge movement did not follow joystick vector " + str(stick_direction))
            return
        touch(1, dodge_point, false)
        touch(0, center, false)
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
    var initial_zoom: float = camera.position.z
    touch(4, Vector2(800, 300), true)
    touch(5, Vector2(1000, 300), true)
    var pinch_drag := InputEventScreenDrag.new()
    pinch_drag.index = 5
    pinch_drag.position = Vector2(1050, 300)
    root.push_input(pinch_drag, true)
    if camera.position.z >= initial_zoom - 0.3:
        fail("Pinch out did not zoom camera in")
        return
    touch(4, Vector2(800, 300), false)
    touch(5, Vector2(1050, 300), false)
    player.position = Vector3(0, 0.05, 0)
    player.velocity = Vector3.ZERO
    for i in range(3):
        await physics_frame
    if not player.is_on_floor():
        fail("Player did not settle on floor before jump test")
        return
    var jump_point: Vector2 = controls.get_global_transform_with_canvas() * (controls.get_node("Jump").position + controls.get_node("Jump").size / 2.0)
    var jump_start: float = player.position.y
    touch(6, jump_point, true)
    if player.jump_buffer <= 0.0:
        fail("Jump button touch was not received")
        return
    touch(6, jump_point, false)
    for i in range(6):
        await physics_frame
    if player.position.y <= jump_start + 0.5:
        fail("Jump input did not lift player")
        return
    var air_start: Vector3 = player.position
    var airborne_forward: Vector3 = -player.camera_pivot.global_transform.basis.z
    airborne_forward.y = 0.0
    airborne_forward = airborne_forward.normalized()
    var airborne_right: Vector3 = player.camera_pivot.global_transform.basis.x
    airborne_right.y = 0.0
    airborne_right = airborne_right.normalized()
    var air_move := InputEventScreenTouch.new()
    air_move.index = 7
    air_move.position = center + Vector2(55, 0)
    air_move.pressed = true
    root.push_input(air_move, true)
    for i in range(12):
        await physics_frame
    var air_displacement: Vector3 = player.position - air_start
    air_displacement.y = 0.0
    if air_displacement.dot(airborne_right) < 0.2:
        fail("Joystick did not steer the character while airborne")
        return
    touch(7, center, false)
    var saved_checkpoint: Vector3 = player.checkpoint_position
    player.global_position = Vector3(saved_checkpoint.x + 2.0, -7.0, saved_checkpoint.z)
    player.velocity = Vector3.DOWN
    await physics_frame
    if player.global_position.y < saved_checkpoint.y - 0.1:
        fail("Falling below the world did not return player to last safe ground")
        return
    print("PASS: backward neutral dodge, all four joystick directions, recovery after falling, animated character, camera zoom and jump")
    quit(0)
