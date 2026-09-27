extends Node2D

const DURATION := 0.28
var elapsed := 0.0
var current_style := 0

func restart(style: int = 0) -> void:
    current_style = style
    elapsed = 0.0
    visible = true
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= DURATION:
        visible = false
        set_process(false)
    else:
        queue_redraw()

func _draw() -> void:
    var progress := clampf(elapsed / DURATION, 0.0, 1.0)
    var fade := pow(1.0 - progress, 1.15)
    var swell := sin(progress * PI)
    if current_style == 0:
        # Short cross-cut: a filled crescent with a hot edge and soft wake.
        _draw_sweep(Vector2(0, -20), 54.0, 37.0, -1.30, 1.04, Color(0.12, 0.88, 0.91), fade, 1.0)
        _draw_sweep(Vector2(2, -21), 44.0, 39.5, -1.20, 0.94, Color(0.80, 1.0, 0.95), fade * 0.88, 0.86)
        _draw_sparks(Vector2(0, -20), 48.0, -1.0, 0.82, 5, fade, Color(0.70, 1.0, 0.96))
    elif current_style == 1:
        # Rising cut: a longer, heavier gold slash with a bright inner blade.
        _draw_sweep(Vector2(0, -22), 68.0, 44.0, -2.48, 0.22, Color(1.0, 0.54, 0.19), fade, 1.14)
        _draw_sweep(Vector2(-1, -23), 57.0, 48.0, -2.35, 0.12, Color(1.0, 0.87, 0.48), fade * 0.90, 0.9)
        _draw_sparks(Vector2(0, -22), 62.0, -2.22, 0.02, 7, fade, Color(1.0, 0.90, 0.58))
    else:
        # Final Qi spin: two broad interleaved crescents wrap around the body.
        _draw_sweep(Vector2(0, -3), 74.0, 51.0, -0.35, 4.72, Color(0.22, 0.68, 0.94), fade, 1.0)
        _draw_sweep(Vector2(0, -5), 63.0, 53.0, 2.55, 7.28, Color(0.80, 0.95, 1.0), fade * 0.82, 0.78)
        for mote in range(9):
            var angle := TAU * float(mote) / 9.0 + progress * 0.55
            var point := Vector2(cos(angle), sin(angle)) * lerpf(57.0, 70.0, float(mote % 3) / 2.0)
            _draw_glow_dot(point, lerpf(5.0, 1.8, progress), fade * 0.85, Color(0.63, 0.91, 1.0))
    draw_circle(Vector2(0, -12), 15.0 + swell * 3.5, Color(0.66, 0.92, 1.0, fade * 0.055))

func _draw_sweep(center: Vector2, outer_radius: float, inner_radius: float, start_angle: float, end_angle: float, tint: Color, alpha: float, weight: float) -> void:
    var broad := _band_points(center, outer_radius + 10.0 * weight, maxf(outer_radius - 10.0 * weight, inner_radius - 8.0), start_angle, end_angle, 32)
    draw_colored_polygon(broad, Color(tint.r, tint.g, tint.b, alpha * 0.055))
    var body := _band_points(center, outer_radius, inner_radius, start_angle, end_angle, 32)
    draw_colored_polygon(body, Color(tint.r, tint.g, tint.b, alpha * 0.34))
    var lit := _band_points(center, outer_radius - 4.0 * weight, inner_radius + 4.0 * weight, start_angle + 0.035, end_angle - 0.035, 32)
    draw_colored_polygon(lit, Color(minf(1.0, tint.r * 0.72 + 0.28), minf(1.0, tint.g * 0.72 + 0.28), minf(1.0, tint.b * 0.72 + 0.28), alpha * 0.40))
    var core := _band_points(center, outer_radius - 8.0 * weight, inner_radius + 8.0 * weight, start_angle + 0.07, end_angle - 0.07, 32)
    draw_colored_polygon(core, Color(0.96, 1.0, 0.98, alpha * 0.48))
    var rim := _arc_points(center, outer_radius - 1.5, start_angle, end_angle, 32)
    draw_polyline(rim, Color(1.0, 1.0, 0.93, alpha * 0.68), maxf(1.0, 2.0 * weight), false)

func _band_points(center: Vector2, outer_radius: float, inner_radius: float, start_angle: float, end_angle: float, segments: int) -> PackedVector2Array:
    var points := PackedVector2Array()
    var safe_outer := maxf(outer_radius, inner_radius + 1.0)
    var safe_inner := maxf(1.0, inner_radius)
    for i in range(segments + 1):
        var t := float(i) / float(segments)
        var angle := lerpf(start_angle, end_angle, t)
        var swell := sin(t * PI) * 2.0
        points.append(center + Vector2(cos(angle), sin(angle)) * (safe_outer + swell))
    for i in range(segments, -1, -1):
        var t := float(i) / float(segments)
        var angle := lerpf(start_angle, end_angle, t)
        var swell := sin(t * PI) * 2.0
        points.append(center + Vector2(cos(angle), sin(angle)) * (safe_inner + swell))
    return points

func _arc_points(center: Vector2, radius: float, start_angle: float, end_angle: float, segments: int) -> PackedVector2Array:
    var points := PackedVector2Array()
    for i in range(segments + 1):
        var t := float(i) / float(segments)
        var angle := lerpf(start_angle, end_angle, t)
        points.append(center + Vector2(cos(angle), sin(angle)) * radius)
    return points

func _draw_sparks(center: Vector2, radius: float, start_angle: float, end_angle: float, count: int, alpha: float, tint: Color) -> void:
    for i in range(count):
        var t := float(i) / float(maxi(1, count - 1))
        var angle := lerpf(start_angle, end_angle, t)
        var point := center + Vector2(cos(angle), sin(angle)) * (radius + sin(t * PI) * 5.0)
        _draw_glow_dot(point, 5.0 - t * 1.4, alpha * (1.0 - t * 0.24), tint)

func _draw_glow_dot(point: Vector2, size: float, alpha: float, tint: Color) -> void:
    draw_circle(point, size * 2.3, Color(tint.r, tint.g, tint.b, alpha * 0.10))
    draw_circle(point, size, Color(tint.r, tint.g, tint.b, alpha * 0.35))
    draw_circle(point, size * 0.35, Color(1.0, 1.0, 0.92, alpha * 0.8))
