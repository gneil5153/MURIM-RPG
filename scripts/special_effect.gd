extends Node2D

var elapsed := 0.0
var duration := 0.72
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
    var radius := lerpf(12.0, max_radius, progress)
    var alpha := 1.0 - progress
    var burst := clampf((progress - 0.08) / 0.82, 0.0, 1.0)

    # Expanding golden Geo field and its cool, luminous inner edge.
    draw_circle(Vector2.ZERO, radius * 0.84, Color(1.0, 0.72, 0.20, alpha * 0.075))
    draw_arc(Vector2.ZERO, radius, 0.0, TAU, 56, Color(1.0, 0.82, 0.34, alpha), 7.0, false)
    draw_arc(Vector2.ZERO, radius * 0.92, 0.0, TAU, 52, Color(0.65, 0.92, 1.0, alpha * 0.82), 3.0, false)

    # Faceted light rays spread from the character as the shockwave grows.
    for ray in range(16):
        var angle := TAU * float(ray) / 16.0
        var direction := Vector2(cos(angle), sin(angle))
        draw_line(direction * radius * 0.48, direction * radius * 0.86, Color(1.0, 0.94, 0.69, alpha * 0.78), 3.0, false)

    # Seven Geo crystal blossoms flare around the perimeter.
    var bloom_radius := radius * lerpf(0.34, 0.74, burst)
    for bloom in range(bloom_count):
        var angle := -PI * 0.5 + TAU * float(bloom) / float(bloom_count)
        var direction := Vector2(cos(angle), sin(angle))
        var center := direction * bloom_radius
        var size := lerpf(0.52, 1.12, burst)
        _draw_crystal(center, angle, size, alpha)
        var side := direction.rotated(PI * 0.5)
        _draw_crystal(center + side * 13.0 * size, angle - 0.28, size * 0.56, alpha * 0.88)
        _draw_crystal(center - side * 13.0 * size, angle + 0.28, size * 0.56, alpha * 0.88)

    # A compact alchemy-star flash remains visible beneath the player.
    draw_arc(Vector2.ZERO, radius * 0.16, 0.0, TAU, 28, Color(1.0, 0.9, 0.54, alpha), 3.0, false)
    for ray in range(8):
        var angle := TAU * float(ray) / 8.0
        var direction := Vector2(cos(angle), sin(angle))
        draw_line(direction * radius * 0.035, direction * radius * 0.15, Color(1.0, 0.98, 0.82, alpha), 2.0, false)
    draw_circle(Vector2.ZERO, 17.0 * alpha, Color(1.0, 0.99, 0.84, alpha * 0.8))

func _draw_crystal(center: Vector2, angle: float, scale: float, alpha: float) -> void:
    var shape := PackedVector2Array([
        Vector2(0, -20), Vector2(7, -5), Vector2(6, 9),
        Vector2(0, 21), Vector2(-6, 9), Vector2(-7, -5)
    ])
    var points := PackedVector2Array()
    for point in shape:
        points.append(center + point.rotated(angle) * scale)
    draw_colored_polygon(points, Color(0.9, 0.63, 0.2, alpha * 0.78))
    var outline := points.duplicate()
    outline.append(points[0])
    draw_polyline(outline, Color(1.0, 0.96, 0.73, alpha), 2.0, false)
    draw_line(points[0], points[3], Color(1.0, 0.98, 0.86, alpha * 0.86), 2.0, false)
