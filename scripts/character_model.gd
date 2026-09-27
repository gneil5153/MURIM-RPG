extends Node3D

var robe: StandardMaterial3D
var robe_light: StandardMaterial3D
var inner: StandardMaterial3D
var trim: StandardMaterial3D
var hair: StandardMaterial3D
var skin: StandardMaterial3D
var leather: StandardMaterial3D
var eyes: StandardMaterial3D
var iris: StandardMaterial3D
var metal: StandardMaterial3D
var accent: StandardMaterial3D
var left_leg: Node3D
var right_leg: Node3D
var left_knee: Node3D
var right_knee: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_elbow: Node3D
var right_elbow: Node3D
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
    iris = _mat(Color("#7786a5"), 0.42)
    metal = _mat(Color("#d2b878"), 0.34)
    accent = _mat(Color("#8d4960"), 0.66)
    trim.metallic = 0.32
    trim.specular = 0.62
    metal.metallic = 0.72
    hair.specular = 0.48

    # Long layered robe, slightly flared toward the hem.
    var skirt := CylinderMesh.new()
    skirt.top_radius = 0.24
    skirt.bottom_radius = 0.36
    skirt.height = 0.9
    skirt.radial_segments = 16
    _piece(self, "Long outer robe", skirt, Vector3(0, 0.72, 0), robe)
    _piece(self, "Inner tunic", _capsule(0.23, 1.0), Vector3(0, 1.41, 0), inner)
    _piece(self, "Blue hanging sash", _box(Vector3(0.09, 0.82, 0.05)), Vector3(0.18, 0.79, -0.34), inner, Vector3.ONE, Vector3(0, 0, -0.12))
    _piece(self, "High collar", _capsule(0.19, 0.25), Vector3(0, 1.82, -0.025), robe_light, Vector3(1.0, 0.72, 0.78))
    _piece(self, "Front collar fold", _box(Vector3(0.13, 0.43, 0.045)), Vector3(-0.065, 1.73, -0.205), trim, Vector3.ONE, Vector3(0, 0, -0.22))
    _piece(self, "Inner collar fold", _box(Vector3(0.11, 0.36, 0.035)), Vector3(0.055, 1.74, -0.218), accent, Vector3.ONE, Vector3(0, 0, 0.19))

    var belt := CylinderMesh.new()
    belt.top_radius = 0.27
    belt.bottom_radius = 0.27
    belt.height = 0.12
    belt.radial_segments = 16
    _piece(self, "Wide dark belt", belt, Vector3(0, 1.31, 0), leather)
    _piece(self, "Belt clasp", _box(Vector3(0.13, 0.16, 0.045)), Vector3(0, 1.31, -0.285), metal)
    _piece(self, "Belt inset", _sphere(0.035), Vector3(0, 1.31, -0.317), accent, Vector3(1.0, 1.0, 0.25))
    for side in [-1.0, 1.0]:
        _piece(self, "Belt rivet", _sphere(0.032), Vector3(side * 0.19, 1.31, -0.24), metal)
        _piece(self, "Crossed robe trim", _box(Vector3(0.07, 0.55, 0.045)), Vector3(side * 0.1, 1.65, -0.205), trim, Vector3.ONE, Vector3(0, 0, side * -0.33))

    # Embroidered shoulder mantle layered over the robe collar.
    for side in [-1.0, 1.0]:
        _piece(self, "Shoulder mantle", _sphere(0.25), Vector3(side * 0.3, 1.84, 0.015), robe_light, Vector3(1.1, 0.45, 0.84))
        _piece(self, "Shoulder filigree", _box(Vector3(0.24, 0.02, 0.018)), Vector3(side * 0.3, 1.9, -0.19), trim, Vector3.ONE, Vector3(0, 0, side * -0.08))
        for mark in range(3):
            _piece(self, "Shoulder stitch", _sphere(0.018), Vector3(side * (0.22 + mark * 0.055), 1.84, -0.235), trim)

    # Two-part legs let the knees and boots follow each stride visibly.
    left_leg = _limb("Left leg", Vector3(-0.14, 0.76, 0), 0.115, 0.56, leather)
    right_leg = _limb("Right leg", Vector3(0.14, 0.76, 0), 0.115, 0.56, leather)
    _piece(left_leg, "Left split robe panel", _box(Vector3(0.19, 0.76, 0.045)), Vector3(0.035, 0.1, -0.36), robe_light, Vector3.ONE, Vector3(0, 0, -0.06))
    _piece(right_leg, "Right split robe panel", _box(Vector3(0.19, 0.76, 0.045)), Vector3(-0.035, 0.1, -0.36), robe_light, Vector3.ONE, Vector3(0, 0, 0.06))
    _piece(left_leg, "Panel gold piping", _box(Vector3(0.025, 0.56, 0.012)), Vector3(-0.045, 0.1, -0.389), metal)
    _piece(right_leg, "Panel gold piping", _box(Vector3(0.025, 0.56, 0.012)), Vector3(0.045, 0.1, -0.389), metal)
    left_knee = Node3D.new()
    left_knee.name = "Left knee"
    left_knee.position = Vector3(0, -0.27, 0)
    left_leg.add_child(left_knee)
    right_knee = Node3D.new()
    right_knee.name = "Right knee"
    right_knee.position = Vector3(0, -0.27, 0)
    right_leg.add_child(right_knee)
    _piece(left_knee, "Left shin", _capsule(0.09, 0.42), Vector3(0, -0.145, 0), leather)
    _piece(right_knee, "Right shin", _capsule(0.09, 0.42), Vector3(0, -0.145, 0), leather)
    _piece(left_knee, "Left boot", _box(Vector3(0.22, 0.16, 0.34)), Vector3(0, -0.36, -0.07), leather)
    _piece(right_knee, "Right boot", _box(Vector3(0.22, 0.16, 0.34)), Vector3(0, -0.36, -0.07), leather)
    _piece(left_knee, "Left boot wrap", _box(Vector3(0.24, 0.08, 0.3)), Vector3(0, -0.27, -0.055), trim)
    _piece(right_knee, "Right boot wrap", _box(Vector3(0.24, 0.08, 0.3)), Vector3(0, -0.27, -0.055), trim)
    _piece(left_knee, "Left boot clasp", _sphere(0.025), Vector3(-0.09, -0.27, -0.214), metal)
    _piece(right_knee, "Right boot clasp", _sphere(0.025), Vector3(0.09, -0.27, -0.214), metal)

    # Sleeves hang from the shoulders; hands are children so they cannot float
    # in place while the arms swing.
    left_arm = _limb("Left sleeve", Vector3(-0.35, 1.72, 0), 0.125, 0.46, robe_light)
    right_arm = _limb("Right sleeve", Vector3(0.35, 1.72, 0), 0.125, 0.46, robe_light)
    left_elbow = Node3D.new()
    left_elbow.name = "Left elbow"
    left_elbow.position = Vector3(0, -0.23, 0)
    left_arm.add_child(left_elbow)
    right_elbow = Node3D.new()
    right_elbow.name = "Right elbow"
    right_elbow.position = Vector3(0, -0.23, 0)
    right_arm.add_child(right_elbow)
    _piece(left_elbow, "Left forearm", _capsule(0.1, 0.43), Vector3(0, -0.12, 0), robe_light)
    _piece(right_elbow, "Right forearm", _capsule(0.1, 0.43), Vector3(0, -0.12, 0), robe_light)
    _piece(left_elbow, "Left hand", _sphere(0.09), Vector3(0, -0.35, -0.025), skin)
    _piece(right_elbow, "Right hand", _sphere(0.09), Vector3(0, -0.35, -0.025), skin)
    _piece(left_elbow, "Left cuff", _box(Vector3(0.22, 0.08, 0.22)), Vector3(0, -0.28, 0), inner)
    _piece(right_elbow, "Right cuff", _box(Vector3(0.22, 0.08, 0.22)), Vector3(0, -0.28, 0), inner)
    _piece(left_elbow, "Left cuff clasp", _sphere(0.022), Vector3(0, -0.28, -0.116), metal)
    _piece(right_elbow, "Right cuff clasp", _sphere(0.022), Vector3(0, -0.28, -0.116), metal)
    _piece(left_elbow, "Left thumb", _sphere(0.045), Vector3(-0.085, -0.34, -0.015), skin)
    _piece(right_elbow, "Right thumb", _sphere(0.045), Vector3(0.085, -0.34, -0.015), skin)

    # Neck and young, narrow face with visible brows and eyes.
    _piece(self, "Neck", _cylinder(0.1, 0.18), Vector3(0, 1.91, 0), skin)
    _piece(self, "Face", _sphere(0.22), Vector3(0, 2.12, -0.015), skin, Vector3(0.88, 1.2, 0.8))
    for side in [-1.0, 1.0]:
        _piece(self, "Ear", _sphere(0.065), Vector3(side * 0.192, 2.105, -0.005), skin, Vector3(0.52, 0.9, 0.48))
        _piece(self, "Ear inner", _sphere(0.027), Vector3(side * 0.207, 2.105, -0.028), accent, Vector3(0.45, 0.78, 0.35))
    for side in [-1.0, 1.0]:
        _piece(self, "Eye", _sphere(0.03), Vector3(side * 0.078, 2.145, -0.184), eyes, Vector3(1.0, 0.74, 0.55))
        _piece(self, "Iris", _sphere(0.018), Vector3(side * 0.078, 2.145, -0.205), iris, Vector3(0.8, 0.9, 0.5))
        _piece(self, "Pupil", _sphere(0.009), Vector3(side * 0.078, 2.145, -0.216), hair)
        _piece(self, "Eye highlight", _sphere(0.005), Vector3(side * 0.073, 2.153, -0.222), eyes)
        _piece(self, "Lower lid", _box(Vector3(0.065, 0.009, 0.012)), Vector3(side * 0.078, 2.119, -0.19), skin, Vector3.ONE, Vector3(0, 0, side * 0.04))
        _piece(self, "Brow", _capsule(0.014, 0.105), Vector3(side * 0.078, 2.197, -0.185), hair, Vector3(1.0, 0.62, 0.55), Vector3(0, 0, side * 0.12))
    _piece(self, "Nose bridge", _capsule(0.025, 0.12), Vector3(0, 2.13, -0.18), skin, Vector3(0.8, 1.0, 0.65))
    _piece(self, "Nose tip", _sphere(0.03), Vector3(0, 2.075, -0.204), skin, Vector3(0.8, 0.72, 0.75))
    _piece(self, "Mouth", _box(Vector3(0.06, 0.011, 0.01)), Vector3(0, 2.03, -0.19), accent)
    _piece(self, "Chin", _sphere(0.09), Vector3(0, 2.005, -0.015), skin, Vector3(0.8, 0.38, 0.66))
    _piece(self, "Subtle cheek scar", _box(Vector3(0.008, 0.05, 0.008)), Vector3(-0.132, 2.095, -0.147), trim, Vector3.ONE, Vector3(0, 0, -0.24))

    # Half-tied charcoal hair with a long back fall and loose strands.
    _piece(self, "Hair cap", _sphere(0.24), Vector3(0, 2.29, 0.01), hair, Vector3(1.04, 0.72, 0.95))
    _piece(self, "High tie", _sphere(0.12), Vector3(0, 2.43, 0.08), hair, Vector3(0.9, 1.0, 0.9))
    _piece(self, "Hair ribbon", _cylinder(0.105, 0.055), Vector3(0, 2.39, 0.08), accent)
    long_hair = _piece(self, "Long tied hair", _capsule(0.09, 1.0), Vector3(0, 1.76, 0.23), hair, Vector3(1.0, 1.0, 1.15), Vector3(-0.18, 0, 0))
    _piece(self, "Loose left lock", _capsule(0.055, 0.62), Vector3(-0.17, 1.98, 0.13), hair, Vector3(1.0, 1.0, 1.0), Vector3(0.12, 0, -0.13))
    _piece(self, "Loose right lock", _capsule(0.05, 0.55), Vector3(0.18, 1.98, 0.12), hair, Vector3(1.0, 1.0, 1.0), Vector3(-0.1, 0, 0.15))
    _piece(self, "Hair sideburn left", _capsule(0.035, 0.34), Vector3(-0.18, 2.04, -0.09), hair, Vector3.ONE, Vector3(0.05, 0, -0.12))
    _piece(self, "Hair sideburn right", _capsule(0.035, 0.34), Vector3(0.18, 2.04, -0.09), hair, Vector3.ONE, Vector3(0.05, 0, 0.12))
    _piece(self, "Gold hair pin", _box(Vector3(0.26, 0.025, 0.035)), Vector3(0, 2.36, -0.02), metal, Vector3.ONE, Vector3(0, 0, -0.06))
    for strand in range(4):
        var strand_x := -0.12 + strand * 0.08
        _piece(self, "Back hair strand", _capsule(0.026, 0.78 - strand * 0.07), Vector3(strand_x, 1.61, 0.29 + absf(strand_x)), hair, Vector3.ONE, Vector3(-0.16, 0, strand_x * 0.45))
    _piece(self, "Wind-swept fringe", _capsule(0.055, 0.45), Vector3(-0.08, 2.24, -0.16), hair, Vector3(1.0, 1.0, 0.8), Vector3(0, 0, -0.42))

    # Fine embroidery and loose cloth tabs that catch the light.
    for i in range(4):
        var y := 1.09 - i * 0.16
        _piece(self, "Robe embroidery", _box(Vector3(0.1, 0.022, 0.012)), Vector3(-0.18, y, -0.3), trim, Vector3.ONE, Vector3(0, 0, -0.16))
        _piece(self, "Robe embroidery", _box(Vector3(0.1, 0.022, 0.012)), Vector3(0.18, y, -0.3), trim, Vector3.ONE, Vector3(0, 0, 0.16))
    for side in [-1.0, 1.0]:
        var tail := _piece(self, "Trailing sash", _box(Vector3(0.16, 0.86, 0.045)), Vector3(side * 0.31, 0.85, 0.31), inner, Vector3.ONE, Vector3(0, 0, side * -0.12))
        cloak_tails.append(tail)

    # Gold hem studs, cord toggles and an embroidered back motif.
    for i in range(9):
        var angle := -1.05 + i * 0.2625
        _piece(self, "Gold hem stud", _sphere(0.02), Vector3(sin(angle) * 0.345, 0.31, cos(angle) * 0.345), trim)
    for i in range(5):
        _piece(self, "Front cord toggle", _sphere(0.028), Vector3(0.0, 1.76 - i * 0.11, -0.31), trim)
    _piece(self, "Back crest", _sphere(0.14), Vector3(0, 1.67, 0.42), trim, Vector3(1.0, 1.2, 0.24))
    _piece(self, "Crest center", _sphere(0.075), Vector3(0, 1.67, 0.465), robe_light, Vector3(1.0, 1.0, 0.3))

    # A sheathed sword across the back, visible when the camera circles him.
    _piece(self, "Sword sheath", _capsule(0.085, 1.46), Vector3(0.06, 1.42, 0.34), leather, Vector3(0.82, 1.0, 0.9), Vector3(0, 0, -0.43))
    for fitting_y in [1.08, 1.75]:
        _piece(self, "Scabbard metal fitting", _box(Vector3(0.16, 0.055, 0.13)), Vector3(0.06 + (1.42 - fitting_y) * -0.46, fitting_y, 0.34), metal, Vector3.ONE, Vector3(0, 0, -0.43))
    _piece(self, "Sword pommel", _sphere(0.075), Vector3(-0.24, 2.08, 0.34), metal)
    _piece(self, "Sword grip", _capsule(0.065, 0.38), Vector3(-0.16, 1.99, 0.35), leather, Vector3.ONE, Vector3(0, 0, -0.43))
    _piece(self, "Sword guard", _box(Vector3(0.42, 0.065, 0.12)), Vector3(0.37, 0.78, 0.34), metal, Vector3.ONE, Vector3(0, 0, -0.43))
    _piece(self, "Sheath ring", _box(Vector3(0.16, 0.055, 0.12)), Vector3(0.23, 1.55, 0.27), metal, Vector3.ONE, Vector3(0, 0, -0.43))
    _piece(self, "Sword tassel", _capsule(0.025, 0.34), Vector3(-0.31, 1.91, 0.4), accent, Vector3.ONE, Vector3(0.12, 0, -0.18))

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
    left_elbow.rotation.x = lerpf(left_elbow.rotation.x, 0.12 + maxf(0.0, stride) * 0.16 + jump_pose * 0.8, delta * 10.0)
    right_elbow.rotation.x = lerpf(right_elbow.rotation.x, 0.12 + maxf(0.0, -stride) * 0.16 + jump_pose * 0.8 + attack_phase * 0.72, delta * 14.0)
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
    material.specular = clampf(1.0 - roughness * 0.55, 0.2, 0.7)
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
