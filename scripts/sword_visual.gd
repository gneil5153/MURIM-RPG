extends Node2D

# The equipped weapon draws independently of the character's animation sheet.
# Other weapons can replace this node while keeping the movement animations.
var facing := Vector2.UP
var attacking := false
var attack_style := 0
var elapsed := 0.0
var duration := 0.45

func set_facing(direction: Vector2) -> void:
    if not attacking and direction.length_squared() > 0.01:
        facing = direction.normalized()
        queue_redraw()

func swing(style: int, direction: Vector2) -> void:
    attack_style = style
    if direction.length_squared() > 0.01:
        facing = direction.normalized()
    elapsed = 0.0
    duration = 0.47 if style == 2 else 0.45
    attacking = true
    queue_redraw()

func _process(delta: float) -> void:
    if not attacking:
        return
    elapsed += delta
    if elapsed >= duration:
        attacking = false
    queue_redraw()

func _draw() -> void:
    _draw_scabbard(not attacking)
    if not attacking:
        return
    var progress := clampf(elapsed / duration, 0.0, 1.0)
    var reach := clampf((progress - 0.025) / 0.18, 0.0, 1.0)
    if reach <= 0.01:
        return
    var swing_progress := clampf((progress - 0.08) / 0.62, 0.0, 1.0)
    swing_progress = swing_progress * swing_progress * (3.0 - 2.0 * swing_progress)
    var begin_angle := -1.35 if attack_style == 0 else (1.22 if attack_style == 1 else -1.40)
    var end_angle := 1.08 if attack_style == 0 else (-1.38 if attack_style == 1 else 4.60)
    var forward_angle := facing.angle() + PI * 0.5
    var hilt := Vector2(0, -31) + Vector2(11, 0).rotated(forward_angle)
    draw_set_transform(hilt, forward_angle + lerpf(begin_angle, end_angle, swing_progress), Vector2.ONE)
    _draw_sword(reach)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_scabbard(show_hilt: bool) -> void:
    var side := -1.0 if facing.x < -0.35 else 1.0
    var hip := Vector2(side * 11.0, -21.0)
    var tip := Vector2(side * 27.0, 23.0)
    draw_line(hip, tip, Color(0.02, 0.025, 0.055), 10.0, false)
    draw_line(hip, tip, Color(0.12, 0.19, 0.29), 6.0, false)
    draw_line(hip + Vector2(0, 3), hip + Vector2(side * 4, 14), Color(0.78, 0.54, 0.25), 3.0, false)
    draw_circle(tip, 4.0, Color(0.72, 0.48, 0.20))
    if show_hilt:
        var handle := hip + Vector2(-side * 7.0, -17.0)
        draw_line(hip, handle, Color(0.035, 0.05, 0.075), 7.0, false)
        draw_line(hip, handle, Color(0.43, 0.24, 0.12), 4.0, false)
        draw_circle(handle, 4.0, Color(0.90, 0.68, 0.30))
        draw_line(hip + Vector2(-side * 8.0, -2.0), hip + Vector2(side * 8.0, 2.0), Color(0.88, 0.68, 0.34), 4.0, false)

func _draw_sword(reach: float) -> void:
    var tip_y := -20.0 - 73.0 * reach
    var shoulder_y := tip_y + 13.0 * reach
    var outline := PackedVector2Array([
        Vector2(-8, -17), Vector2(8, -17), Vector2(7, shoulder_y),
        Vector2(0, tip_y), Vector2(-7, shoulder_y)
    ])
    draw_colored_polygon(outline, Color(0.025, 0.065, 0.10))
    draw_colored_polygon(PackedVector2Array([
        Vector2(-6, -20), Vector2(6, -20), Vector2(5, shoulder_y),
        Vector2(0, tip_y + 2), Vector2(-5, shoulder_y)
    ]), Color(0.68, 0.83, 0.89))
    draw_colored_polygon(PackedVector2Array([
        Vector2(-5, -20), Vector2(0, -20), Vector2(0, tip_y + 3),
        Vector2(-5, shoulder_y)
    ]), Color(0.94, 0.98, 0.95))
    draw_line(Vector2(5, -21), Vector2(4, shoulder_y), Color(0.32, 0.91, 0.98, 0.95), 2.5, false)
    draw_line(Vector2(0, -20), Vector2(0, shoulder_y), Color(0.76, 0.91, 0.96), 1.3, false)
    # Guard, wrapped grip and pommel remain readable when the blade is moving.
    draw_line(Vector2(-16, -16), Vector2(16, -16), Color(0.08, 0.06, 0.06), 7.0, false)
    draw_line(Vector2(-14, -17), Vector2(14, -17), Color(0.94, 0.72, 0.32), 4.0, false)
    draw_colored_polygon(PackedVector2Array([
        Vector2(-3, -14), Vector2(4, -14), Vector2(4, 13), Vector2(-3, 13)
    ]), Color(0.06, 0.07, 0.10))
    for y in [-8.0, 1.0, 10.0]:
        draw_line(Vector2(-3, y), Vector2(4, y - 3), Color(0.76, 0.52, 0.25), 2.0, false)
    draw_circle(Vector2(0, 16), 5.0, Color(0.94, 0.73, 0.35))
