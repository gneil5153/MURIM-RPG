extends SceneTree
func _initialize() -> void: call_deferred("run")
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
    var packed: PackedScene = load("res://scenes/main.tscn")
    if packed == null:
        fail("Pixel game scene did not load")
        return
    var world := packed.instantiate()
    root.add_child(world)
    current_scene = world
    for i in range(6): await physics_frame
    var controls = world.get_node("HUD/TouchControls")
    var player = world.get_node("Player")
    var dummy = world.get_node("TrainingDummy")
    if player is not CharacterBody2D or player.sprite.sprite_frames.get_animation_names().size() < 20:
        fail("Pixel character animations did not load")
        return
    var sheet: Image = Image.load_from_file("res://assets/pixel/hero_sheet.png")
    for row in range(4):
        for y in range(3):
            for x in range(sheet.get_width()):
                if sheet.get_pixel(x, row * 72 + y).a > 0.01:
                    fail("Sprite frame contains a detached fragment above the character")
                    return
    var center: Vector2 = controls.get_global_transform_with_canvas() * controls.stick_center()
    var start: Vector2 = player.position
    touch(0, center + Vector2(0,-40), true)
    for i in range(24): await physics_frame
    if player.position.y >= start.y - 18 or not player.sprite.animation.begins_with("walk_down"):
        fail("Joystick did not move and animate the pixel character")
        return
    if absf(player.sprite.rotation) < 0.025 or player.sprite.position.y > -20.5:
        fail("Walk cycle did not show a visible body stride")
        return
    if player.acceleration != 1812.5 or player.braking != 2187.5:
        fail("Movement acceleration and braking are not 25 percent firmer")
        return
    var walk_speed: float = player.velocity.length()
    var drag := InputEventScreenDrag.new()
    drag.index = 0
    drag.position = center + Vector2(0,-68)
    root.push_input(drag,true)
    for i in range(28): await physics_frame
    if player.velocity.length() <= walk_speed + 25:
        fail("Outer joystick did not trigger the faster run")
        return
    touch(0,center,false)
    for i in range(25): await physics_frame
    player.global_position = Vector2(700, 0)
    player.velocity = Vector2.ZERO
    await physics_frame
    if player.global_position.distance_to(Vector2(700, 0)) > 2.0:
        fail("Walking beyond the old radius incorrectly returned the character to spawn")
        return
    player.global_position = Vector2.ZERO
    player.velocity = Vector2.ZERO
    player.facing = Vector2.UP
    player._update_animation()
    if not player.sprite.animation.begins_with("idle_down"):
        fail("Moving upward did not use the inverted front-facing animation")
        return
    player.facing = Vector2.DOWN
    player._update_animation()
    if not player.sprite.animation.begins_with("idle_up"):
        fail("Moving downward did not use the inverted back-facing animation")
        return
    player.facing = Vector2.UP
    dummy.position = Vector2(0,-78)
    for i in range(3): await physics_frame
    var attack_point: Vector2 = controls.get_global_transform_with_canvas() * (controls.get_node("Attack").position + controls.get_node("Attack").size/2.0)
    touch(1,attack_point,true)
    if dummy.health >= 100.0 or dummy.hits != 1 or not player.attack_visual.visible:
        fail("Attack did not animate and damage the training target")
        return
    touch(1,attack_point,false)
    for i in range(10): await physics_frame
    if not player.sprite.animation.begins_with("attack_down") or player.sprite.frame < 2:
        fail("The attack did not visibly play the sword draw animation")
        return
    var after_first_attack: float = dummy.health
    player.attack_cooldown = 0.0
    player.attack()
    if player.attack_visual.current_style != 1 or dummy.health != after_first_attack - 25.0:
        fail("Second combo hit did not use the stronger rising cut")
        return
    player.attack_cooldown = 0.0
    dummy.position = Vector2(0, 65)
    var second_dummy := Node2D.new()
    second_dummy.set_script(load("res://scripts/training_dummy.gd"))
    second_dummy.position = Vector2(60, 0)
    world.add_child(second_dummy)
    player.attack()
    if player.attack_visual.current_style != 2 or dummy.health != after_first_attack - 57.0 or second_dummy.get("health") != 68.0:
        fail("Third combo hit did not perform the all-around Qi spin")
        return
    var far_dummy := Node2D.new()
    far_dummy.set_script(load("res://scripts/training_dummy.gd"))
    far_dummy.position = Vector2(400, 0)
    world.add_child(far_dummy)
    var special_point: Vector2 = controls.get_global_transform_with_canvas() * (controls.get_node("Special").position + controls.get_node("Special").size/2.0)
    var qi_before_special: float = player.qi
    touch(5, special_point, true)
    if not player.special_visual.visible or player.special_cooldown <= 0.0 or player.qi != qi_before_special - 30.0:
        fail("Special button did not create the radiant attack and consume Qi")
        return
    if dummy.health != 0.0 or second_dummy.get("health") != 23.0 or far_dummy.get("health") != 100.0 or absf(player.special_visual.max_radius - 324.0) > 1.0 or player.special_visual.bloom_count != 7:
        fail("Radiant special did not apply its three-character-height radius correctly")
        return
    touch(5, special_point, false)
    player.attack_cooldown=0.0
    player.facing=Vector2.DOWN
    var before_dodge: Vector2 = player.position
    player.dodge()
    for i in range(10): await physics_frame
    if player.position.y >= before_dodge.y - 35:
        fail("Neutral dodge did not move opposite the facing direction")
        return
    player.dodge_time=0.0
    player.dodge_cooldown=0.0
    player.position=Vector2.ZERO
    player.velocity=Vector2.ZERO
    var jump_point: Vector2 = controls.get_global_transform_with_canvas() * (controls.get_node("Jump").position + controls.get_node("Jump").size/2.0)
    touch(2,jump_point,true)
    if player.jump_anim <= 0.0:
        fail("Jump button did not start the hop animation")
        return
    touch(2,jump_point,false)
    for i in range(5): await physics_frame
    if player.sprite.position.y >= -5:
        fail("Hop did not lift the pixel sprite")
        return
    var initial_zoom: Vector2 = player.camera.zoom
    touch(3,Vector2(850,260),true)
    touch(4,Vector2(1030,260),true)
    var pinch := InputEventScreenDrag.new()
    pinch.index=4
    pinch.position=Vector2(1080,260)
    root.push_input(pinch,true)
    if player.camera.zoom.x <= initial_zoom.x:
        fail("Pinch did not zoom the 2D camera")
        return
    touch(3,Vector2(850,260),false)
    touch(4,Vector2(1080,260),false)
    print("PASS: 25% firmer movement, inverted vertical facing, combo attacks, radiant special, dodge, hop and camera zoom")
    quit(0)
