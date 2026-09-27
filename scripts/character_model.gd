extends Node3D

var robe: StandardMaterial3D
var robe_light: StandardMaterial3D
var inner: StandardMaterial3D
var trim: StandardMaterial3D
var hair: StandardMaterial3D
var skin: StandardMaterial3D
var leather: StandardMaterial3D
var eyes: StandardMaterial3D
var left_leg: Node3D
var right_leg: Node3D
var left_knee: Node3D
var right_knee: Node3D
var left_arm: Node3D
var right_arm: Node3D
var cloak_tails: Array[MeshInstance3D] = []
var walk_phase := 0.0
var idle_phase := 0.0
var long_hair: MeshInstance3D

func _ready() -> void:
    robe = _mat(Color("#171c2b"), 0.9)
    robe_light = _mat(Color("#29344c"), 0.88)
    inner = _mat(Color("#3d4b68"), 0.86)
    trim = _mat(Color("#a48c68"), 0.72)
    hair = _mat(Color("#10131d"), 0.76)
    skin = _mat(Color("#c99e82"), 0.82)
    leather = _mat(Color("#211f24"), 0.93)
    eyes = _mat(Color("#c0b8ad"), 0.56)

    # Long layered robe, slightly flared toward the hem.
    var skirt := CylinderMesh.new()
    skirt.top_radius = 0.29
    skirt.bottom_radius = 0.48
    skirt.height = 0.9
    skirt.radial_segments = 16
    _piece(self, "Long outer robe", skirt, Vector3(0, 0.72, 0), robe)
    _piece(self, "Inner tunic", _capsule(0.27, 1.05), Vector3(0, 1.41, 0), inner)
    _piece(self, "Blue hanging sash", _box(Vector3(0.12, 0.9, 0.07)), Vector3(0.22, 0.79, -0.402), inner, Vector3.ONE, Vector3(0, 0, -0.12))

    var belt := CylinderMesh.new()
    belt.top_radius = 0.34
    belt.bottom_radius = 0.34
    belt.height = 0.13
    belt.radial_segments = 16
    _piece(self, "Wide dark belt", belt, Vector3(0, 1.31, 0), leather)
    _piece(self, "Belt clasp", _box(Vector3(0.17, 0.2, 0.055)), Vector3(0, 1.31, -0.354), trim)
    for side in [-1.0, 1.0]:
        _piece(self, "Belt rivet", _sphere(0.045), Vector3(side * 0.24, 1.31, -0.3), trim)
        _piece(self, "Crossed robe trim", _box(Vector3(0.095, 0.62, 0.07)), Vector3(side * 0.12, 1.67, -0.266), trim, Vector3.ONE, Vector3(0, 0, side * -0.33))

    # Embroidered shoulder mantle layered over the robe collar.
    for side in [-1.0, 1.0]:
        _piece(self, "Shoulder mantle", _sphere(0.31), Vector3(side * 0.37, 1.84, 0.015), robe_light, Vector3(1.28, 0.52, 0.94))
        _piece(self, "Shoulder filigree", _box(Vector3(0.32, 0.025, 0.02)), Vector3(side * 0.37, 1.91, -0.225), trim, Vector3.ONE, Vector3(0, 0, side * -0.08))
        for mark in range(3):
            _piece(self, "Shoulder stitch", _sphere(0.025), Vector3(side * (0.28 + mark * 0.09), 1.84, -0.275), trim)

    # Two-part legs let the knees and boots follow each stride visibly.
    left_leg = _limb("Left leg", Vector3(-0.17, 0.76, 0), 0.13, 0.58, leather)
    right_leg = _limb("Right leg", Vector3(0.17, 0.76, 0), 0.13, 0.58, leather)
    _piece(left_leg, "Left split robe panel", _box(Vector3(0.24, 0.84, 0.055)), Vector3(0.045, 0.12, -0.46), robe_light, Vector3.ONE, Vector3(0, 0, -0.06))
    _piece(right_leg, "Right split robe panel", _box(Vector3(0.24, 0.84, 0.055)), Vector3(-0.045, 0.12, -0.46), robe_light, Vector3.ONE, Vector3(0, 0, 0.06))
    left_knee = Node3D.new()
    left_knee.name = "Left knee"
    left_knee.position = Vector3(0, -0.27, 0)
    left_leg.add_child(left_knee)
    right_knee = Node3D.new()
    right_knee.name = "Right knee"
    right_knee.position = Vector3(0, -0.27, 0)
    right_leg.add_child(right_knee)
    _piece(left_knee, "Left shin", _capsule(0.105, 0.46), Vector3(0, -0.16, 0), leather)
    _piece(right_knee, "Right shin", _capsule(0.105, 0.46), Vector3(0, -0.16, 0), leather)
    _piece(left_knee, "Left boot", _box(Vector3(0.25, 0.2, 0.4)), Vector3(0, -0.4, -0.08), leather)
    _piece(right_knee, "Right boot", _box(Vector3(0.25, 0.2, 0.4)), Vector3(0, -0.4, -0.08), leather)
    _piece(left_knee, "Left boot wrap", _box(Vector3(0.28, 0.1, 0.35)), Vector3(0, -0.29, -0.06), trim)
    _piece(right_knee, "Right boot wrap", _box(Vector3(0.28, 0.1, 0.35)), Vector3(0, -0.29, -0.06), trim)

    # Sleeves hang from the shoulders; hands are children so they cannot float
    # in place while the arms swing.
    left_arm = _limb("Left sleeve", Vector3(-0.43, 1.72, 0), 0.16, 0.68, robe_light)
    right_arm = _limb("Right sleeve", Vector3(0.43, 1.72, 0), 0.16, 0.68, robe_light)
    _piece(left_arm, "Left hand", _sphere(0.12), Vector3(0, -0.43, -0.025), skin)
    _piece(right_arm, "Right hand", _sphere(0.12), Vector3(0, -0.43, -0.025), skin)
    _piece(left_arm, "Left cuff", _box(Vector3(0.31, 0.1, 0.31)), Vector3(0, -0.31, 0), inner)
    _piece(right_arm, "Right cuff", _box(Vector3(0.31, 0.1, 0.31)), Vector3(0, -0.31, 0), inner)
    for side in [-1.0, 1.0]:
        _piece(self, "Sleeve cuff", _capsule(0.19, 0.18), Vector3(side * 0.72, 1.72, 0), inner, Vector3.ONE, Vector3(0, 0, side * PI * 0.5))

    # Neck and young, narrow face with visible brows and eyes.
    _piece(self, "Neck", _cylinder(0.12, 0.2), Vector3(0, 1.91, 0), skin)
    _piece(self, "Face", _sphere(0.235), Vector3(0, 2.12, -0.015), skin, Vector3(0.9, 1.18, 0.82))
    for side in [-1.0, 1.0]:
        _piece(self, "Eye", _sphere(0.027), Vector3(side * 0.082, 2.145, -0.194), eyes, Vector3(1.0, 0.72, 0.55))
        _piece(self, "Pupil", _sphere(0.012), Vector3(side * 0.082, 2.145, -0.213), hair)
        _piece(self, "Lower lid", _box(Vector3(0.07, 0.009, 0.012)), Vector3(side * 0.082, 2.119, -0.198), trim, Vector3.ONE, Vector3(0, 0, side * 0.04))
        _piece(self, "Brow", _box(Vector3(0.085, 0.024, 0.025)), Vector3(side * 0.082, 2.195, -0.188), hair, Vector3.ONE, Vector3(0, 0, side * 0.12))
    _piece(self, "Nose", _sphere(0.035), Vector3(0, 2.105, -0.213), skin, Vector3(0.7, 1.0, 0.75))
    _piece(self, "Mouth", _box(Vector3(0.07, 0.012, 0.012)), Vector3(0, 2.035, -0.205), leather)
    _piece(self, "Subtle cheek scar", _box(Vector3(0.009, 0.055, 0.009)), Vector3(-0.135, 2.095, -0.164), trim, Vector3.ONE, Vector3(0, 0, -0.24))

    # Half-tied charcoal hair with a long back fall and loose strands.
    _piece(self, "Hair cap", _sphere(0.25), Vector3(0, 2.29, 0.01), hair, Vector3(1.04, 0.72, 0.95))
    _piece(self, "High tie", _sphere(0.12), Vector3(0, 2.43, 0.08), hair, Vector3(0.9, 1.0, 0.9))
    _piece(self, "Long tied hair", _capsule(0.105, 1.0), Vector3(0, 1.76, 0.23), hair, Vector3(1.0, 1.0, 1.15), Vector3(-0.18, 0, 0))
    _piece(self, "Loose left lock", _capsule(0.055, 0.62), Vector3(-0.17, 1.98, 0.13), hair, Vector3(1.0, 1.0, 1.0), Vector3(0.12, 0, -0.13))
    _piece(self, "Loose right lock", _capsule(0.05, 0.55), Vector3(0.18, 1.98, 0.12), hair, Vector3(1.0, 1.0, 1.0), Vector3(-0.1, 0, 0.15))
    for strand in range(4):
        var strand_x := -0.12 + strand * 0.08
        _piece(self, "Back hair strand", _capsule(0.026, 0.78 - strand * 0.07), Vector3(strand_x, 1.61, 0.29 + absf(strand_x)), hair, Vector3.ONE, Vector3(-0.16, 0, strand_x * 0.45))
    _piece(self, "Wind-swept fringe", _capsule(0.055, 0.45), Vector3(-0.08, 2.24, -0.16), hair, Vector3(1.0, 1.0, 0.8), Vector3(0, 0, -0.42))

    # Fine embroidery and loose cloth tabs that catch the light.
    for i in range(4):
        var y := 1.09 - i * 0.16
        _piece(self, "Robe embroidery", _box(Vector3(0.13, 0.025, 0.014)), Vector3(-0.25, y, -0.393), trim, Vector3.ONE, Vector3(0, 0, -0.16))
        _piece(self, "Robe embroidery", _box(Vector3(0.13, 0.025, 0.014)), Vector3(0.25, y, -0.393), trim, Vector3.ONE, Vector3(0, 0, 0.16))
    for side in [-1.0, 1.0]:
        var tail := _piece(self, "Trailing sash", _box(Vector3(0.16, 0.86, 0.045)), Vector3(side * 0.31, 0.85, 0.31), inner, Vector3.ONE, Vector3(0, 0, side * -0.12))
        cloak_tails.append(tail)

    # Gold hem studs, cord toggles and an embroidered back motif.
    for i in range(9):
        var angle := -1.05 + i * 0.2625
        _piece(self, "Gold hem stud", _sphere(0.025), Vector3(sin(angle) * 0.46, 0.38, cos(angle) * 0.46), trim)
    for i in range(5):
        _piece(self, "Front cord toggle", _sphere(0.028), Vector3(0.0, 1.76 - i * 0.11, -0.31), trim)
    _piece(self, "Back crest", _sphere(0.14), Vector3(0, 1.67, 0.42), trim, Vector3(1.0, 1.2, 0.24))
    _piece(self, "Crest center", _sphere(0.075), Vector3(0, 1.67, 0.465), robe_light, Vector3(1.0, 1.0, 0.3))

    # A sheathed sword across the back, visible when the camera circles him.
    _piece(self, "Sword sheath", _box(Vector3(0.14, 1.42, 0.12)), Vector3(0.06, 1.42, 0.34), leather, Vector3.ONE, Vector3(0, 0, -0.43))
    _piece(self, "Sword pommel", _sphere(0.09), Vector3(-0.24, 2.08, 0.34), trim)
    _piece(self, "Sword grip", _capsule(0.065, 0.38), Vector3(-0.16, 1.99, 0.35), leather, Vector3.ONE, Vector3(0, 0, -0.43))
    _piece(self, "Sword guard", _box(Vector3(0.48, 0.075, 0.14)), Vector3(0.37, 0.78, 0.34), trim, Vector3.ONE, Vector3(0, 0, -0.43))
    _piece(self, "Sheath ring", _box(Vector3(0.18, 0.07, 0.15)), Vector3(0.23, 1.55, 0.27), trim, Vector3.ONE, Vector3(0, 0, -0.43))

func _process(delta: float) -> void:
    var actor := get_parent() as CharacterBody3D
    if actor == null:
        return
    var horizontal_speed := Vector2(actor.velocity.x, actor.velocity.z).length()
    var blend := clampf(horizontal_speed / 10.5, 0.0, 1.0)
    var gait_strength := clampf(horizontal_speed / 7.0, 0.0, 1.0)
    if gait_strength > 0.03:
        walk_phase += delta * lerpf(4.4, 9.5, blend)
    else:
        idle_phase += delta
    var stride := sin(walk_phase)
    var swing := stride * lerpf(0.7, 1.05, blend) * gait_strength
    var airborne := not actor.is_on_floor()
    var rising := clampf(actor.velocity.y / 8.0, 0.0, 1.0) if airborne else 0.0
    var landing: float = actor.get("landing_impact")
    var attack: float = actor.get("attack_anim")
    var attack_phase := sin((1.0 - attack) * PI) if attack > 0.0 else 0.0
    var jump_pose := 0.2 * rising
    left_leg.rotation.x = lerpf(left_leg.rotation.x, swing - jump_pose + landing * 0.52, delta * 16.0)
    right_leg.rotation.x = lerpf(right_leg.rotation.x, -swing - jump_pose + landing * 0.52, delta * 16.0)
    var left_kick := maxf(0.0, -stride) * lerpf(0.52, 1.05, blend) * gait_strength
    var right_kick := maxf(0.0, stride) * lerpf(0.52, 1.05, blend) * gait_strength
    left_knee.rotation.x = lerpf(left_knee.rotation.x, left_kick + jump_pose * 1.5, delta * 18.0)
    right_knee.rotation.x = lerpf(right_knee.rotation.x, right_kick + jump_pose * 1.5, delta * 18.0)
    left_arm.rotation.x = lerpf(left_arm.rotation.x, -swing * 1.05 - attack_phase * 0.55, delta * 13.0)
    right_arm.rotation.x = lerpf(right_arm.rotation.x, swing * 1.05 - attack_phase * 1.8, delta * 16.0)
    left_arm.rotation.z = lerpf(left_arm.rotation.z, jump_pose + sin(walk_phase + PI * 0.5) * 0.1 * gait_strength + landing * 0.18, delta * 11.0)
    right_arm.rotation.z = lerpf(right_arm.rotation.z, -jump_pose + sin(walk_phase + PI * 0.5) * -0.1 * gait_strength - attack_phase * 0.2, delta * 12.0)
    var bob := sin(walk_phase * 2.0) * lerpf(0.018, 0.065, blend) * blend
    bob += sin(idle_phase * 2.0) * 0.012 * (1.0 - blend)
    position.y = lerpf(position.y, bob + clampf(actor.velocity.y * 0.006, -0.035, 0.035) - landing * 0.1, delta * 12.0)
    var dodge_lean: Vector3 = actor.get("dodge_lean")
    var turn_lean: float = actor.get("turn_lean")
    rotation.x = lerpf(rotation.x, -0.1 * blend + (0.1 if airborne else 0.0) + dodge_lean.x - landing * 0.08, delta * 14.0)
    rotation.z = lerpf(rotation.z, dodge_lean.z + turn_lean + attack_phase * -0.12, delta * 14.0)
    for index in range(cloak_tails.size()):
        var tail := cloak_tails[index]
        tail.rotation.z = sin(walk_phase * 0.75 + float(index)) * 0.15 * blend
        tail.rotation.x = sin(walk_phase * 0.5 + float(index)) * 0.1 * blend
    if long_hair:
        long_hair.rotation.x = -0.18 + sin(walk_phase * 0.55 + idle_phase) * (0.12 if blend > 0.03 else 0.025)
        long_hair.rotation.z = sin(walk_phase * 0.8 + idle_phase) * (0.09 if blend > 0.03 else 0.025)

func _mat(color: Color, roughness: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material

func _piece(parent: Node3D, part_name: String, shape: Mesh, pos: Vector3, material: Material, scale := Vector3.ONE, rot := Vector3.ZERO) -> MeshInstance3D:
    var piece := MeshInstance3D.new()
    piece.name = part_name
    piece.mesh = shape
    piece.material_override = material
    piece.position = pos
    piece.scale = scale
    piece.rotation = rot
    parent.add_child(piece)
    return piece

func _limb(part_name: String, pos: Vector3, radius: float, height: float, material: Material) -> Node3D:
    var pivot := Node3D.new()
    pivot.name = part_name
    pivot.position = pos
    add_child(pivot)
    _piece(pivot, "Sleeve mesh", _capsule(radius, height), Vector3.ZERO, material)
    return pivot

func _capsule(radius: float, height: float) -> CapsuleMesh:
    var shape := CapsuleMesh.new()
    shape.radius = radius
    shape.height = height
    return shape

func _box(dimensions: Vector3) -> BoxMesh:
    var shape := BoxMesh.new()
    shape.size = dimensions
    return shape

func _sphere(radius: float) -> SphereMesh:
    var shape := SphereMesh.new()
    shape.radius = radius
    shape.height = radius * 2.0
    shape.radial_segments = 18
    shape.rings = 12
    return shape

func _cylinder(radius: float, height: float) -> CylinderMesh:
    var shape := CylinderMesh.new()
    shape.top_radius = radius
    shape.bottom_radius = radius
    shape.height = height
    return shape
