extends Node
class_name TilesetParser
const NORMAL : TileSet = preload("res://Assets/TileSets/ChibiUltica/TileSet/normal.tres")
@onready var normal_mod := NORMAL.duplicate()
@onready var normal_source = normal_mod.get_source(0) as TileSetAtlasSource

const DEFAULT_TILE_SIZE := Vector2i(32, 32)

func parse_tileset(json_path: String, output_path: String) -> void:
	var tileset := TileSet.new()
	var json_data := load_json(json_path)
	
	# 解析 tiles-new 部分
	if "tiles-new" in json_data:
		for tilesheet in json_data["tiles-new"]:
			_process_tilesheet(tilesheet, tileset)
	
	# 保存生成的 TileSet
	ResourceSaver.save(tileset, output_path)

func _process_tilesheet(tilesheet: Dictionary, tileset: TileSet) -> void:
	if tilesheet["file"] != "normal.png":
		return
	var tilesheet_path :String= "res://Assets/TileSets/ChibiUltica/"+tilesheet["file"]
	print("Processing: "+tilesheet_path)
	var texture := load(tilesheet_path) as Texture2D
	if not texture:
		printerr("Failed to load texture: ", tilesheet["file"])
		return
	
	# 创建 Atlas 源
	var source := TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = DEFAULT_TILE_SIZE
	
	var source_id := tileset.add_source(source)
	var tile_index := 0
	
	# 处理每个 tile 定义
	for tile_def in tilesheet.get("tiles", []):
		_process_tile_definition(tile_def, source, tile_index)
		tile_index += 1

func _process_tile_definition(tile_def: Dictionary, source: TileSetAtlasSource, index: int) -> void:
	# 计算图块在图集中的位置
	var atlas_coords := Vector2i(
		index % (source.texture.get_width() / source.texture_region_size.x),
		index / (source.texture.get_width() / source.texture_region_size.x)
	)
	
	# 创建基础 tile
	print("Creating tile at:("+str(atlas_coords.x)+","+str(atlas_coords.y)+")")
	source.create_tile(atlas_coords)
	
	# 处理 ID 映射
	var ids: Array = tile_def["id"] if tile_def["id"] is Array else [tile_def["id"]]
	for entity_id in ids:
		# 这里可以添加 ID 到图块的映射逻辑
		pass
	
	# 处理前景/背景
	var tile_data: TileData = source.get_tile_data(atlas_coords, 0)
	_process_sprite(tile_def.get("fg"), tile_data, "fg")
	_process_sprite(tile_def.get("bg"), tile_data, "bg")
	
	# 处理旋转
	#if tile_def.get("rotates", false):
		#tile_data.transform = TileSet.TileTransform.TRANSPOSE
	
	# 处理多层 (示例)
	if "multitile" in tile_def and tile_def["multitile"]:
		_process_multitile(tile_def, source, atlas_coords)

func _process_sprite(sprite_def, tile_data: TileData, layer_type: String) -> void:
	if not sprite_def:
		return
	
	# 简单字符串类型
	if typeof(sprite_def) == TYPE_STRING:
		# 这里可以添加精灵查找逻辑
		tile_data.set_texture_offset(Vector2(0, 0), 0)
	
	## 数组类型（旋转/变体）
	#elif sprite_def is Array:
		## 处理旋转变体
		#if layer_type == "fg":
			#for i in sprite_def.size():
				#if i >= 4: break
				#var rot := i % 4
				## 这里需要处理不同旋转方向的精灵位置
				## 示例：为每个方向创建不同 tile

func _process_multitile(tile_def: Dictionary, source: TileSetAtlasSource, base_coords: Vector2i) -> void:
	# 处理附加图块
	for additional_tile in tile_def.get("additional_tiles", []):
		var tile_id : String= additional_tile["id"]
		var new_coords := base_coords + Vector2i(1, 0) # 示例偏移
		
		# 创建附加 tile
		source.create_tile(new_coords)
		var tile_data : TileData = source.get_tile_data(new_coords, 0)
		
		# 配置地形连接
		#if tile_id in ["edge", "corner"]:
			#tile_data.terrain_set = 0
			#tile_data.terrain = 0
			#tile_data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE,-1)
			#tile_data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,-1)
			#tile_data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE,-1)
			#tile_data.set_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE,-1)

func load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		printerr("Failed to open JSON file: ", path)
		return {}
	
	var json := JSON.new()
	json.parse(file.get_as_text())
	return json.get_data()
# 在主场景中调用
func _ready():
	var parser = TilesetParser.new()
	parser.parse_tileset("res://Assets/TileSets/ChibiUltica/tile_config.json", "res://tileset.res")
