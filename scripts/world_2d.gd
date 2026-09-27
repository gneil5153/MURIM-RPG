extends Node2D

func _ready() -> void:
    y_sort_enabled = false
    var ground := Sprite2D.new()
    ground.name = "Pixel dojo ground"
    ground.texture = load("res://assets/pixel/dojo_ground.png")
    ground.position = Vector2(-1024, -1024)
    ground.centered = false
    ground.scale = Vector2(2.0, 2.0)
    ground.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    ground.z_index = -5
    add_child(ground)
    var atlas: Texture2D = load("res://assets/pixel/tree_atlas.png")
    var trees := [
        Vector2(-465,-430),Vector2(-390,-465),Vector2(-306,-443),Vector2(-220,-462),Vector2(-130,-468),Vector2(-34,-468),Vector2(90,-466),Vector2(180,-455),Vector2(270,-470),Vector2(365,-449),Vector2(455,-420),
        Vector2(-470,-325),Vector2(-410,-250),Vector2(-455,-130),Vector2(-472,15),Vector2(-446,130),Vector2(-470,260),Vector2(-412,385),Vector2(-335,455),Vector2(-245,464),Vector2(-145,456),Vector2(-45,466),Vector2(65,456),Vector2(165,466),Vector2(270,451),Vector2(380,464),Vector2(455,380),Vector2(465,276),Vector2(442,150),Vector2(466,40),Vector2(454,-80),Vector2(466,-210),Vector2(414,-330),
        Vector2(-350,-360),Vector2(350,-360),Vector2(-360,355),Vector2(360,354),Vector2(-450,-370),Vector2(445,340)
    ]
    for index in range(trees.size()):
        var tree := Node2D.new()
        tree.position = trees[index] * 2.0
        var art := Sprite2D.new()
        art.texture = atlas
        art.region_enabled = true
        art.region_rect = Rect2((index % 4) * 64, 0, 64, 96)
        art.centered = false
        art.position = Vector2(-64, -184)
        art.scale = Vector2(2.0, 2.0)
        art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
        tree.add_child(art)
        get_parent().call_deferred("add_child", tree)
