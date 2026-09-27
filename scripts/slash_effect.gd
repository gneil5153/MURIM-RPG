extends Node2D

var elapsed := 0.0
var duration := 0.42
var current_style := 0

func restart(style: int = 0) -> void:
    current_style = style
    elapsed = 0.0
    duration = 0.49 if style == 2 else (0.43 if style == 1 else 0.40)
    visible = true
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= duration:
        visible = false
        set_process(false)
    else:
        queue_redraw()

func _draw() -> void:
    var progress := clampf(elapsed / duration, 0.0, 1.0)
    var sweep := clampf((progress - 0.07) / 0.63, 0.0, 1.0)
    if sweep <= 0.0:
        return
    var fade := minf(1.0, 1.35 * pow(1.0 - progress, 1.35)) * minf(1.0, sweep * 9.0)
    var gold := Color(1.0, 0.65, 0.24)
    var cyan := Color(0.26, 0.88, 0.98)
    var center := Vector2(0, -21)
    if current_style == 0:
        _draw_ground_wake(cyan, fade * 0.60, sweep)
        _draw_sweep(center, 68.0, 37.0, -2.55, -0.43, sweep, cyan, fade)
        _draw_sparks(center, 65.0, -2.55, -0.43, sweep, cyan, fade, 7)
    elif current_style == 1:
        _draw_ground_wake(gold, fade * 0.7, sweep)
        _draw_sweep(center + Vector2(0, -4), 79.0, 40.0, 0.07, -2.55, sweep, gold, fade)
        _draw_sparks(center + Vector2(0, -4), 76.0, 0.07, -2.55, sweep, gold, fade, 9)
    else:
        var burst := clampf((progress - 0.13) / 0.65, 0.0, 1.0)
        _draw_ground_wake(cyan, fade, burst)
        _draw_sweep(Vector2(0, -13), 81.0, 45.0, -2.85, 2.85, burst, cyan, fade)
        _draw_sweep(Vector2(0, -13), 73.0, 48.0, 0.3, 5.7, burst, gold, fade * 0.72)
        _draw_sparks(Vector2(0, -13), 80.0, -2.85, 2.85, burst, cyan, fade, 14)
        draw_circle(Vector2(0, -16), 25.0 + 17.0 * burst, Color(0.72, 0.96, 1.0, fade * 0.075))

func _draw_ground_wake(tint: Color, alpha: float, progress: float) -> void:
    draw_set_transform(Vector2(0, 5), 0.0, Vector2(1.0, 0.32))
    draw_circle(Vector2.ZERO, lerpf(25.0, 80.0, progress), Color(tint.r, tint.g, tint.b, alpha * 0.045))
    draw_circle(Vector2.ZERO, lerpf(18.0, 51.0, progress), Color(tint.r, tint.g, tint.b, alpha * 0.08))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_sweep(center: Vector2, outer_radius: float, inner_radius: float, start_angle: float, end_angle: float, progress: float, tint: Color, alpha: float) -> void:
    if progress < 0.025:
        return
    var tail := maxf(0.0, progress - 0.68)
    var beginning := lerpf(start_angle, end_angle, tail)
    var tip := lerpf(start_angle, end_angle, progress)
    # Translucent outer ribbons give the stroke a soft edge; its bright core
    # keeps the blade readable at phone resolution.
    for layer in range(4):
        var spread := float(3 - layer)
        var outer := outer_radius + spread * 7.0
        var inner := inner_radius - spread * 5.0
        var opacity: float = [0.045, 0.09, 0.22, 0.36][layer]
        var color := tint.lerp(Color.WHITE, float(layer) * 0.19)
        draw_colored_polygon(_band(center, outer, inner, beginning, tip, 28), Color(color.r, color.g, color.b, alpha * opacity))
    var blade_begin := lerpf(beginning, tip, 0.48)
    draw_colored_polygon(_band(center, outer_radius - 3.0, outer_radius - 9.0, blade_begin, tip, 16), Color(1.0, 1.0, 0.94, alpha * 0.78))
    draw_polyline(_arc(center, outer_radius - 1.0, blade_begin, tip, 16), Color(1.0, 1.0, 0.95, alpha * 0.84), 2.4, false)
    var tip_strength := clampf((0.86 - progress) * 8.0, 0.0, 1.0)
    if tip_strength > 0.01:
        var direction := Vector2(cos(tip), sin(tip))
        var tangent := Vector2(-direction.y, direction.x)
        var point := center + direction * outer_radius
        var shard := PackedVector2Array([point + direction * 12.0, point + tangent * 7.0, point - direction * 7.0, point - tangent * 7.0])
        draw_colored_polygon(shard, Color(0.94, 1.0, 0.94, alpha * 0.74 * tip_strength))
        draw_circle(point, 10.0, Color(tint.r, tint.g, tint.b, alpha * 0.16 * tip_strength))

func _band(center: Vector2, outer: float, inner: float, start_angle: float, end_angle: float, segments: int) -> PackedVector2Array:
    var points := PackedVector2Array()
    for i in range(segments + 1):
        var t := float(i) / float(segments)
        var angle := lerpf(start_angle, end_angle, t)
        var edge := sin(t * PI) * 3.0
        points.append(center + Vector2(cos(angle), sin(angle)) * (outer + edge))
    for i in range(segments, -1, -1):
        var t := float(i) / float(segments)
        var angle := lerpf(start_angle, end_angle, t)
        points.append(center + Vector2(cos(angle), sin(angle)) * (inner + sin(t * PI) * 2.0))
    return points

func _arc(center: Vector2, radius: float, start_angle: float, end_angle: float, segments: int) -> PackedVector2Array:
    var points := PackedVector2Array()
    for i in range(segments + 1):
        var angle := lerpf(start_angle, end_angle, float(i) / float(segments))
        points.append(center + Vector2(cos(angle), sin(angle)) * radius)
    return points

func _draw_sparks(center: Vector2, radius: float, start_angle: float, end_angle: float, progress: float, tint: Color, alpha: float, count: int) -> void:
    if progress > 0.86:
        return
    for i in range(count):
        var t := float(i + 1) / float(count + 1)
        if t > progress + 0.06 or t < progress - 0.28:
            continue
        var angle := lerpf(start_angle, end_angle, t)
        var direction := Vector2(cos(angle), sin(angle))
        var tangent := Vector2(-direction.y, direction.x)
        var point := center + direction * (radius + float(i % 3) * 5.0)
        var strength := alpha * (1.0 - absf(progress - t) * 0.6)
        var width := 2.0 + float(i % 3)
        draw_circle(point, width * 3.5, Color(tint.r, tint.g, tint.b, strength * 0.10))
        draw_colored_polygon(PackedVector2Array([point + direction * (width * 2.7), point + tangent * width, point - direction * (width * 2.0), point - tangent * width]), Color(tint.r, tint.g, tint.b, strength * 0.58))
        draw_circle(point, width * 0.45, Color(1.0, 1.0, 0.95, strength * 0.9))
