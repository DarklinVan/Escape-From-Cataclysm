extends Node

const NORMAL : TileSet = preload("res://Assets/TileSets/ChibiUltica/TileSet/normal.tres")


func _ready() -> void:
	var normal_mod := NORMAL.duplicate()
	var normal_source_0 = normal_mod.get_source(0) as TileSetAtlasSource
	normal_source_0.create_tile(Vector2i(0,0))
	#var td := normal_source_0.get_tile_data(Vector2i(0,0),0)
	
	save_tile_set(normal_mod)

func save_tile_set(mod_tileset:TileSet) -> void:
	ResourceSaver.save(mod_tileset, "res://Assets/TileSets/ChibiUltica/TileSet/normal_mod.tres")
	print("Saved")
