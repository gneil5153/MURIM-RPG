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
    var center: Vector2 = controls.get_global_transform_with_canvas() * controls.stick_center()
    var start: Vector2 = player.position
    touch(0, center + Vector2(0,-40), true)
    for i in range(24): await physics_frame
    if player.position.y >= start.y - 18 or not player.sprite.animation.begins_with("walk_up"):
        fail("Joystick did not move and animate the pixel character")
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
    player.global_position = Vector2.ZERO
    player.velocity = Vector2.ZERO
    player.facing = Vector2.UP
    dummy.position = Vector2(0,-78)
    for i in range(3): await physics_frame
    var attack_point: Vector2 = controls.get_global_transform_with_canvas() * (controls.get_node("Attack").position + controls.get_node("Attack").size/2.0)
    touch(1,attack_point,true)
    if dummy.health >= 100.0 or dummy.hits != 1 or not player.attack_visual.visible:
        fail("Attack did not animate and damage the training target")
        return
    touch(1,attack_point,false)
    player.attack_cooldown=0.0
    player.facing=Vector2.DOWN
    var before_dodge := player.position
    player.dodge()
    for i in range(10): await physics_frame
    if player.position.y <= before_dodge.y + 35:
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
    print("PASS: 2D pixel sprite, joystick walking/running, attack, dodge, hop and camera zoom")
    quit(0)
