extends Node3D

# Drives the skinned Quaternius Monk instead of building a body from primitives.
@onready var rig: Node3D = $Rig
var skeleton: Skeleton3D
var animation_player: AnimationPlayer
var current_motion := ""
var attack_hold := 0.0
var dodge_hold := 0.0
var previous_attack := 0.0
var previous_dodge := 0.0

func _ready() -> void:
    rig.scale = Vector3.ONE * 0.78
    var skeletons := rig.find_children("*", "Skeleton3D", true, false)
    var players := rig.find_children("*", "AnimationPlayer", true, false)
    skeleton = skeletons[0] as Skeleton3D if not skeletons.is_empty() else null
    animation_player = players[0] as AnimationPlayer if not players.is_empty() else null
    if skeleton == null or animation_player == null:
        push_error("The imported humanoid rig is missing its skeleton or animations")
        return
    _add_hair()
    _play_motion("Idle")

func _process(delta: float) -> void:
    var actor := get_parent() as CharacterBody3D
    if actor == null or animation_player == null:
        return
    var speed := Vector2(actor.velocity.x, actor.velocity.z).length()
    var attack: float = actor.get("attack_anim")
    var dodge: float = actor.get("dodge_time")
    if attack > previous_attack + 0.3:
        attack_hold = 0.68
    if dodge > previous_dodge + 0.05:
        dodge_hold = 0.34
    previous_attack = attack
    previous_dodge = dodge
    attack_hold = maxf(0.0, attack_hold - delta)
    dodge_hold = maxf(0.0, dodge_hold - delta)

    var motion := "Idle"
    if dodge_hold > 0.0:
        motion = "Roll"
    elif attack_hold > 0.0:
        motion = "Attack"
    elif speed > 8.0:
        motion = "Run"
    elif speed > 0.2:
        motion = "Walk"
    _play_motion(motion)
    if motion == "Run":
        animation_player.speed_scale = clampf(speed / 10.0, 0.8, 1.3)
    elif motion == "Walk":
        animation_player.speed_scale = clampf(speed / 5.8, 0.55, 1.4)
    elif motion == "Roll":
        animation_player.speed_scale = 2.7
    else:
        animation_player.speed_scale = 1.0

    var landing: float = actor.get("landing_impact")
    var dodge_lean: Vector3 = actor.get("dodge_lean")
    var turn_lean: float = actor.get("turn_lean")
    rotation.x = lerpf(rotation.x, dodge_lean.x - landing * 0.07, minf(delta * 12.0, 1.0))
    rotation.z = lerpf(rotation.z, dodge_lean.z + turn_lean, minf(delta * 12.0, 1.0))

func _play_motion(name: String) -> void:
    if current_motion == name or animation_player == null:
        return
    var animation_name := _find_animation(name)
    if animation_name == "":
        push_warning("Missing character animation: " + name)
        return
    current_motion = name
    animation_player.play(animation_name, 0.12)

func _find_animation(name: String) -> String:
    for animation_name in animation_player.get_animation_list():
        if animation_name == name or animation_name.ends_with("/" + name):
            return animation_name
    return ""

func _add_hair() -> void:
    var head_index := skeleton.find_bone("Head")
    if head_index < 0:
        return
    var attachment := BoneAttachment3D.new()
    attachment.name = "Long murim hair"
    skeleton.add_child(attachment)
    attachment.bone_idx = head_index
    var hair_material := StandardMaterial3D.new()
    hair_material.albedo_color = Color("#111822")
    hair_material.roughness = 0.84
    hair_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    var crown := SphereMesh.new()
    crown.radius = 0.26
    crown.height = 0.26
    crown.radial_segments = 16
    var top := MeshInstance3D.new()
    top.name = "Hair crown"
    top.mesh = crown
    top.material_override = hair_material
    top.position = Vector3(0, 0.22, 0.0)
    attachment.add_child(top)
    for side in [-1.0, -0.45, 0.2, 0.8]:
        var strand := MeshInstance3D.new()
        strand.name = "Flowing hair"
        strand.mesh = _hair_sheet(side)
        strand.material_override = hair_material
        attachment.add_child(strand)

func _hair_sheet(side: float) -> ArrayMesh:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for step in range(10):
        var t0 := float(step) / 10.0
        var t1 := float(step + 1) / 10.0
        var p0 := _hair_point(side, t0, -1.0)
        var p1 := _hair_point(side, t0, 1.0)
        var p2 := _hair_point(side, t1, -1.0)
        var p3 := _hair_point(side, t1, 1.0)
        for vertex in [p0, p2, p1, p1, p2, p3]:
            surface.add_vertex(vertex)
    surface.generate_normals()
    return surface.commit()

func _hair_point(side: float, t: float, edge: float) -> Vector3:
    var width := 0.09 * (1.0 - t * 0.75)
    return Vector3(side * 0.17 + edge * width + sin(t * 4.0 + side) * 0.025 * t,
        0.20 - t * 0.95, 0.20 + t * 0.12 + sin(t * PI) * 0.07)
