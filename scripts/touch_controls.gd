extends Control

@export var player_path: NodePath
var player: CharacterBody3D
var move_touch := -1
var camera_touch := -1
var camera_last_position := Vector2.ZERO
const CAMERA_DRAG_SENSITIVITY := 0.006
const CAMERA_PITCH_SENSITIVITY := 0.0045
var action_touches: Dictionary = {}
var stick_vector := Vector2.ZERO
var stick_sprinting := false
const STICK_RADIUS := 65.0

func _ready() -> void:
    player = get_node(player_path)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()

func stick_center() -> Vector2:
    return Vector2(112.0, size.y - 116.0)

func _draw() -> void:
    var base := stick_center()
    var tint := Color(0.95, 0.72, 0.3, 0.8) if stick_sprinting else Color(0.78, 0.83, 0.84, 0.6)
    draw_circle(base, STICK_RADIUS + 2.0, Color(0.04, 0.07, 0.09, 0.34))
    draw_arc(base, STICK_RADIUS, 0.0, TAU, 48, tint, 3.0)
    draw_circle(base + stick_vector * STICK_RADIUS, 22.0, tint)

func _input(event: InputEvent) -> void:
    # Read touch events before a full-screen GUI can consume them.
    if event is InputEventScreenTouch:
        var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
        if not event.pressed and action_touches.has(event.index):
            action_touches.erase(event.index)
            get_viewport().set_input_as_handled()
            return
        if not event.pressed and event.index == camera_touch:
            camera_touch = -1
            get_viewport().set_input_as_handled()
            return
        if event.pressed:
            for button_name in ["Attack", "Dodge"]:
                var button: Button = get_node(button_name)
                if Rect2(button.position, button.size).has_point(point):
                    if not action_touches.has(event.index):
                        action_touches[event.index] = button_name
                        if button_name == "Attack":
                            player.attack()
                        else:
                            player.dodge()
                    get_viewport().set_input_as_handled()
                    return
        if event.pressed and move_touch == -1 and point.distance_to(stick_center()) <= STICK_RADIUS + 28.0:
            move_touch = event.index
            _move_stick(point)
            get_viewport().set_input_as_handled()
        elif event.pressed and camera_touch == -1 and point.x >= size.x * 0.4:
            camera_touch = event.index
            camera_last_position = point
            get_viewport().set_input_as_handled()
        elif not event.pressed and event.index == move_touch:
            release_stick()
            get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag and action_touches.has(event.index):
        get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag and event.index == move_touch:
        var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
        _move_stick(point)
        get_viewport().set_input_as_handled()
    elif event is InputEventScreenDrag and event.index == camera_touch:
        var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
        var drag_delta: Vector2 = point - camera_last_position
        player.camera_pivot.rotation.y -= drag_delta.x * CAMERA_DRAG_SENSITIVITY
        var camera: Camera3D = player.camera_pivot.get_node("Camera3D")
        camera.rotation.x = clampf(camera.rotation.x - drag_delta.y * CAMERA_PITCH_SENSITIVITY, deg_to_rad(-55.0), deg_to_rad(10.0))
        camera_last_position = point
        get_viewport().set_input_as_handled()

func _move_stick(point: Vector2) -> void:
    stick_vector = ((point - stick_center()) / STICK_RADIUS).limit_length(1.0)
    stick_sprinting = stick_vector.length() >= 0.85
    player.set_move_vector(stick_vector)
    player.touch_sprinting = stick_sprinting
    queue_redraw()

func release_stick() -> void:
    move_touch = -1
    stick_vector = Vector2.ZERO
    stick_sprinting = false
    if is_instance_valid(player):
        player.set_move_vector(Vector2.ZERO)
        player.touch_sprinting = false
    queue_redraw()

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        release_stick()
        camera_touch = -1
        action_touches.clear()

func _process(_delta: float) -> void:
    $Attack.modulate = Color(1.0, 0.75, 0.3) if player.attack_cooldown > 0.0 else Color.WHITE
    $Dodge.modulate = Color(0.4, 0.8, 1.0) if player.dodge_cooldown > 0.0 else Color.WHITE
    $Status.text = "Qi: %d / 100" % int(player.qi)

func _on_attack_pressed() -> void:
    player.attack()

func _on_dodge_pressed() -> void:
    player.dodge()
