extends Node2D

const DURATION := 0.24
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
    var fade := pow(1.0 - progress, 1.35)
    var sweep := lerpf(0.82, 1.12, progress)
    if current_style == 0:
        _soft_arc(Vector2(0, -19), 39.0 * sweep, -1.24, 1.15, Color(0.18, 0.91, 0.91), fade, 7.5)
        _soft_arc(Vector2(2, -21), 31.0 * sweep, -1.13, 0.96, Color(0.77, 1.0, 0.96), fade * 0.8, 3.0)
    elif current_style == 1:
        _soft_arc(Vector2(0, -24), 48.0 * sweep, -2.46, 0.20, Color(1.0, 0.62, 0.23), fade, 9.0)
        _soft_arc(Vector2(-1, -25), 40.0 * sweep, -2.31, 0.02, Color(1.0, 0.93, 0.62), fade * 0.86, 3.5)
        for spark in range(5):
            var t := float(spark) / 4.0
            var angle := lerpf(-2.15, -0.1, t)
            var point := Vector2(cos(angle), sin(angle)) * (45.0 * sweep)
            draw_circle(point, lerpf(4.0, 1.2, progress), Color(1.0, 0.84, 0.49, fade * (1.0 - t * 0.35)))
    else:
        _soft_arc(Vector2.ZERO, 61.0 * sweep, -0.3, TAU - 0.3, Color(0.35, 0.70, 1.0), fade, 10.0)
        _soft_arc(Vector2(0, -2), 52.0 * sweep, 0.2, TAU + 0.2, Color(0.85, 0.97, 1.0), fade * 0.88, 4.0)

func _soft_arc(center: Vector2, radius: float, start: float, finish: float, tint: Color, alpha: float, width: float) -> void:
    draw_arc(center, radius, start, finish, 24, Color(tint.r, tint.g, tint.b, alpha * 0.09), width * 3.6, false)
    draw_arc(center, radius, start, finish, 24, Color(tint.r, tint.g, tint.b, alpha * 0.21), width * 2.0, false)
    draw_arc(center, radius, start, finish, 24, Color(tint.r, tint.g, tint.b, alpha * 0.52), width, false)
    draw_arc(center, radius, start, finish, 24, Color(0.97, 1.0, 0.98, alpha * 0.9), maxf(1.0, width * 0.28), false)
