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

# 从chibi的json配置中映射index到图中的实际坐标
func mapping_coor(chibi_id:int)->Vector2i:
	# range 6128 to 12783
	if chibi_id > 12783 or chibi_id < 6128:
		return Vector2i(-1,-1)
	var index = chibi_id - 6128
	var x_index :int= index % 16 
	var y_index :int= index / 16.0
	return Vector2i(x_index,y_index)

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
