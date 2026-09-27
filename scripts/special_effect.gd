extends Node2D

var elapsed := 0.0
var duration := 0.86
var max_radius := 0.0
var bloom_count := 7

func _ready() -> void:
    set_process(false)

func restart(radius: float) -> void:
    max_radius = radius
    elapsed = 0.0
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
    var growth := ease(progress, 0.62)
    var fade := pow(1.0 - progress, 1.18)
    var radius := lerpf(12.0, max_radius, growth)
    var settle := clampf((progress - 0.14) / 0.66, 0.0, 1.0)

    draw_circle(Vector2.ZERO, radius * 0.79, Color(1.0, 0.57, 0.19, fade * 0.035))
    draw_circle(Vector2.ZERO, radius * 0.49, Color(1.0, 0.77, 0.32, fade * 0.055))
    draw_circle(Vector2.ZERO, radius * 0.22, Color(1.0, 0.9, 0.58, fade * 0.11))
    draw_circle(Vector2.ZERO, radius * 0.075, Color(1.0, 0.99, 0.84, fade * 0.34))

    var ring_radius := radius * lerpf(0.89, 1.0, settle)
    _soft_arc(ring_radius, 0.0, TAU, Color(1.0, 0.71, 0.31), fade, 7.5)
    _soft_arc(ring_radius * 0.94, 0.0, TAU, Color(1.0, 0.91, 0.63), fade * 0.8, 3.0)
    _soft_arc(radius * 0.74, 0.0, TAU, Color(0.83, 0.91, 1.0), fade * 0.40, 2.5)

    for bloom in range(bloom_count):
        var angle := -PI * 0.5 + TAU * float(bloom) / float(bloom_count)
        var direction := Vector2(cos(angle), sin(angle))
        var side := direction.rotated(PI * 0.5)
        var reach := radius * lerpf(0.74, 0.91, float((bloom * 3) % bloom_count) / float(bloom_count))
        var bend := 18.0 + float((bloom * 5) % 4) * 8.0
        var points := PackedVector2Array()
        var start := direction * radius * 0.07
        var control := direction * reach * 0.55 + side * bend
        var finish := direction * reach
        for sample in range(13):
            var t := float(sample) / 12.0
            var inverse := 1.0 - t
            points.append(start * inverse * inverse + control * 2.0 * inverse * t + finish * t * t)
        _soft_ribbon(points, Color(1.0, 0.68 + float(bloom % 3) * 0.07, 0.28), fade, lerpf(20.0, 9.0, progress))
        _soft_ribbon(points, Color(1.0, 0.93, 0.68), fade * 0.78, lerpf(5.5, 2.0, progress))

        var petal := direction * radius * lerpf(0.67, 0.78, settle) + side * bend * 0.45
        var petal_size := maxf(2.5, 12.0 * (1.0 - progress * 0.45))
        draw_circle(petal, petal_size * 2.4, Color(1.0, 0.64, 0.23, fade * 0.13))
        draw_circle(petal, petal_size, Color(1.0, 0.88, 0.53, fade * 0.45))
        draw_circle(petal, petal_size * 0.38, Color(1.0, 0.98, 0.82, fade * 0.7))

    for spark in range(18):
        var angle := float(spark) * 2.399 + progress * 1.7
        var distance := radius * (0.22 + 0.58 * float((spark * 7) % 19) / 18.0)
        var point := Vector2(cos(angle), sin(angle)) * distance
        var size := (1.5 + float(spark % 4)) * (1.0 - progress * 0.45)
        draw_circle(point, size * 2.0, Color(1.0, 0.78, 0.42, fade * 0.10))
        draw_circle(point, size, Color(1.0, 0.97, 0.78, fade * 0.55))
    _soft_arc(radius * 0.18, 0.0, TAU * 0.72, Color(1.0, 0.98, 0.8), fade, 2.2)

func _soft_arc(radius: float, start: float, finish: float, tint: Color, alpha: float, width: float) -> void:
    draw_arc(Vector2.ZERO, radius, start, finish, 64, Color(tint.r, tint.g, tint.b, alpha * 0.075), width * 4.0, false)
    draw_arc(Vector2.ZERO, radius, start, finish, 64, Color(tint.r, tint.g, tint.b, alpha * 0.20), width * 2.0, false)
    draw_arc(Vector2.ZERO, radius, start, finish, 64, Color(tint.r, tint.g, tint.b, alpha * 0.52), width, false)
    draw_arc(Vector2.ZERO, radius, start, finish, 64, Color(1.0, 0.99, 0.9, alpha * 0.78), maxf(1.0, width * 0.27), false)

func _soft_ribbon(points: PackedVector2Array, tint: Color, alpha: float, width: float) -> void:
    draw_polyline(points, Color(tint.r, tint.g, tint.b, alpha * 0.075), width * 3.8, false)
    draw_polyline(points, Color(tint.r, tint.g, tint.b, alpha * 0.19), width * 2.0, false)
    draw_polyline(points, Color(tint.r, tint.g, tint.b, alpha * 0.48), width, false)
