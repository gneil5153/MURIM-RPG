extends StaticBody3D

var health := 100.0
var reset_time := 0.0
var flash_time := 0.0
var hits := 0
var label: Label3D
var mesh: MeshInstance3D

func _ready() -> void:
    add_to_group("damageable")
    mesh = MeshInstance3D.new()
    var shape := CapsuleMesh.new()
    shape.radius = 0.45
    shape.height = 1.8
    mesh.mesh = shape
    mesh.position.y = 0.9
    var material := StandardMaterial3D.new()
    material.albedo_color = Color(0.65, 0.3, 0.15)
    mesh.material_override = material
    add_child(mesh)
    var collision := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.45
    capsule.height = 1.8
    collision.shape = capsule
    collision.position.y = 0.9
    add_child(collision)
    label = Label3D.new()
    label.position.y = 2.4
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    label.font_size = 42
    add_child(label)
    update_label()

func update_label() -> void:
    label.text = "ENTRENAMIENTO\n%d / 100" % int(health) if health > 0.0 else "DERROTADO"

func take_damage(amount: float) -> void:
    if health <= 0.0:
        return
    hits += 1
    health = maxf(0.0, health - amount)
    flash_time = 0.16
    mesh.scale = Vector3(1.15, 0.85, 1.15)
    if health <= 0.0:
        reset_time = 2.0
    update_label()

func _process(delta: float) -> void:
    flash_time = maxf(0.0, flash_time - delta)
    mesh.material_override.albedo_color = Color(1.0, 0.85, 0.25) if flash_time > 0.0 else Color(0.65, 0.3, 0.15)
    mesh.scale = mesh.scale.lerp(Vector3.ONE, minf(1.0, delta * 12.0))
    if reset_time > 0.0:
        reset_time = maxf(0.0, reset_time - delta)
        if reset_time == 0.0:
            health = 100.0
            update_label()
