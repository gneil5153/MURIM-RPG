extends Control

@export var player_path: NodePath
var player: CharacterBody2D
var move_touch := -1
var camera_touches: Dictionary = {}
var action_touches: Dictionary = {}
var stick_vector := Vector2.ZERO
var stick_sprinting := false
const STICK_RADIUS := 72.0

func _ready() -> void:
    player = get_node(player_path) as CharacterBody2D
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    queue_redraw()
func stick_center() -> Vector2:
    return Vector2(132.0, size.y - 125.0)
func _draw() -> void:
    var base := stick_center()
    var tint := Color(0.95, 0.72, 0.3, 0.88) if stick_sprinting else Color(0.78, 0.83, 0.84, 0.7)
    draw_circle(base, STICK_RADIUS + 3.0, Color(0.04,0.07,0.09,0.5))
    draw_arc(base, STICK_RADIUS, 0.0, TAU, 36, tint, 3.0, true)
    draw_circle(base + stick_vector * STICK_RADIUS, 21.0, tint)
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
        if not event.pressed:
            if action_touches.has(event.index):
                if action_touches[event.index] == "Jump": player.jump_released()
                action_touches.erase(event.index)
                get_viewport().set_input_as_handled()
                return
            if camera_touches.has(event.index):
                camera_touches.erase(event.index)
                get_viewport().set_input_as_handled()
                return
            if event.index == move_touch:
                release_stick()
                get_viewport().set_input_as_handled()
                return
        else:
            for name in ["Attack", "Dodge", "Jump", "Special"]:
                var button := get_node(name) as Button
                if Rect2(button.position, button.size).has_point(point):
                    action_touches[event.index] = name
                    if name == "Attack": player.attack()
                    elif name == "Dodge": player.dodge()
                    elif name == "Jump": player.jump()
                    else: player.special_attack()
                    get_viewport().set_input_as_handled()
                    return
            if move_touch == -1 and point.distance_to(stick_center()) <= STICK_RADIUS + 28.0:
                move_touch = event.index
                _move_stick(point)
                get_viewport().set_input_as_handled()
                return
            if point.x >= size.x * 0.4:
                camera_touches[event.index] = point
                get_viewport().set_input_as_handled()
                return
    elif event is InputEventScreenDrag:
        if action_touches.has(event.index):
            get_viewport().set_input_as_handled()
        elif event.index == move_touch:
            var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
            _move_stick(point)
            get_viewport().set_input_as_handled()
        elif camera_touches.has(event.index):
            var point: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
            var prior: Vector2 = camera_touches[event.index]
            var old_points: Array = camera_touches.values()
            camera_touches[event.index] = point
            if camera_touches.size() >= 2:
                var new_points: Array = camera_touches.values()
                var before_distance: float = old_points[0].distance_to(old_points[1])
                var after_distance: float = new_points[0].distance_to(new_points[1])
                if before_distance > 1.0:
                    var factor := after_distance / before_distance
                    player.camera.zoom = (player.camera.zoom * factor).clamp(Vector2(0.65,0.65), Vector2(1.6,1.6))
            else:
                player.camera.offset -= (point - prior) / player.camera.zoom.x
            get_viewport().set_input_as_handled()
func _move_stick(point: Vector2) -> void:
    stick_vector = ((point - stick_center()) / STICK_RADIUS).limit_length(1.0)
    stick_sprinting = stick_vector.length() >= 0.58
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
        camera_touches.clear()
        action_touches.clear()
func _process(_delta: float) -> void:
    $Attack.modulate = Color(1.0,0.75,0.3) if player.attack_cooldown > 0.0 else Color.WHITE
    $Dodge.modulate = Color(0.4,0.8,1.0) if player.dodge_cooldown > 0.0 else Color.WHITE
    $Jump.modulate = Color(0.55,1.0,0.65) if player.jump_anim > 0.2 else Color.WHITE
    $Special.modulate = Color(0.55,0.62,0.7) if player.special_cooldown > 0.0 or player.qi < player.SPECIAL_QI_COST else Color.WHITE
    $Status.text = "QI  %d / 100" % int(player.qi)
func _on_attack_pressed() -> void: player.attack()
func _on_dodge_pressed() -> void: player.dodge()
func _on_jump_pressed() -> void: player.jump()
func _on_special_pressed() -> void: player.special_attack()
