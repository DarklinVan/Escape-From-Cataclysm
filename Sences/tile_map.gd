extends Node

const NORMAL : TileSet = preload("res://Assets/TileSets/ChibiUltica/TileSet/normal.tres")

const t_list = [
	Vector2i(12,1),
	Vector2i(13,1),
	Vector2i(14,1),
	Vector2i(15,1),
	Vector2i(0,2),
	Vector2i(1,2),
	Vector2i(2,2),
	Vector2i(3,2),
	Vector2i(4,2),
	Vector2i(5,2),
	Vector2i(6,2),
	Vector2i(7,2),
	Vector2i(8,2),
	Vector2i(9,2),
	Vector2i(10,2),
	Vector2i(11,2),
]

func mapping_coor(chibi_id:int)->Vector2i:
	return Vector2i(-1,-1)

func _ready() -> void:
	var normal_mod := NORMAL.duplicate()
	var normal_source_0 = normal_mod.get_source(0) as TileSetAtlasSource
	for i in t_list:
		normal_source_0.create_tile(i)
		var td := normal_source_0.get_tile_data(i,0)
		td.terrain_set = 0
		td.terrain = 0
	save_tile_set(normal_mod)

func save_tile_set(mod_tileset:TileSet) -> void:
	ResourceSaver.save(mod_tileset, "res://Assets/TileSets/ChibiUltica/TileSet/normal_mod.tres")
	print("Saved")
