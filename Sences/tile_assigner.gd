extends Node
class_name TilesetHelper

const TILE_NORMAL = preload("res://Assets/TileSets/ChibiUltica/tile_normal.json")
const NORMAL = preload("res://Assets/TileSets/ChibiUltica/normal.png")
@onready var normal_config = TILE_NORMAL.data
@onready var base_layer: TileMapLayer = $BaseLayer

## 从给定的图片序号映射到Atlas坐标
static func map_tileindex_to_coor(range_:Vector2i,index: int) -> Vector2i:
	# 6208, 12863
	if index < range_.x or index > range_.y:
		return Vector2i(-1,-1)
	var x:int = (index-range_.x) % 16
	var y:int = (index-range_.x) / 16
	return Vector2i(x,y)

## 创建空白图片
static func creat_new_img(img_size:Vector2i,format:Image.Format=Image.FORMAT_RGBA8)->Image:
	return Image.create_empty(img_size.x,img_size.y,false,format)

## 向下拓展新行
static func extend_new_row(img:Image,tile_size:Vector2i)->Image:
	var img_size : Vector2i = img.get_size()
	var new_img_size : Vector2i = Vector2i(img_size.x,img_size.y+tile_size.y)
	var temp_img : Image = creat_new_img(new_img_size,img.get_format())
	temp_img.blit_rect(img,Rect2i(Vector2i(0,0),img_size),Vector2i(0,0))
	return temp_img

## 向右拓展新列
static func extend_new_column(img:Image,tile_size:Vector2i)->Image:
	var img_size : Vector2i = img.get_size()
	var new_img_size : Vector2i = Vector2i(img_size.x+tile_size.x,img_size.y)
	var temp_img : Image = creat_new_img(new_img_size,img.get_format())
	temp_img.blit_rect(img,Rect2i(Vector2i(0,0),img_size),Vector2i(0,0))
	return temp_img

## 用于从大图集中获取特定区域
# 从AtlasTexture中获取指定区域的AtlasTexture
static func get_atlas_from_atlastexture(at:AtlasTexture,coor:Vector2i,tilesize:Vector2i)->AtlasTexture:
	# 计算指定区域的矩形
	var region = Rect2i(Vector2i(coor.x*tilesize.x,coor.y*tilesize.y),tilesize)
	# 设置AtlasTexture的区域为计算出的矩形
	at.region = region
	# 返回修改后的AtlasTexture
	return at
# 安全复制图像区域
static func _copy_image_region(
	target: Image,
	source: Image,
	position: Vector2i
) -> void:
	# 获取源图像的矩形区域
	var source_rect := Rect2i(Vector2i.ZERO, source.get_size())
	# 计算有效复制区域的大小
	var effective_size := Vector2i(
		min(source.get_width(), target.get_width() - position.x),
		min(source.get_height(), target.get_height() - position.y)
	)
	
	# 如果有效复制区域大小小于等于0，则警告并返回
	if effective_size.x <= 0 or effective_size.y <= 0:
		push_warning("复制区域超出目标图像范围")
		return
		
	# 将源图像的指定区域复制到目标图像的指定位置
	target.blit_rect(
		source,
		Rect2i(Vector2i.ZERO, effective_size),
		position
	)

# 合并多个AtlasTexture到一个图像中
static func merge_atlas_textures(
	datas: Array, 
	tile_size: Vector2i = Vector2i(32, 32),
	output_path: String = "res://merged_atlas.png"
) -> bool:
	
	# 初始化图集大小和最终图像
	var atlas_size := Vector2i(0, 0)
	var final_img : Image
	var current_index := 0
	
	# 遍历数据数组
	for data in datas:
		# 检查数据格式是否正确
		if not data.has("atlas") or not data["atlas"] is Array:
			push_warning("无效数据格式，缺少atlas数组")
			continue
			
		# 遍历atlas数组
		for atlas in data["atlas"]:
			atlas = atlas as AtlasTexture
			# 跳过非AtlasTexture对象
			if not atlas:
				push_warning("跳过非AtlasTexture对象")
				continue
				
			# 获取AtlasTexture的图像
			var atlas_img :Image= atlas.get_image()
			# 跳过空图像
			if atlas_img.is_empty():
				push_warning("跳过空图像")
				continue
				
			# 初始化第一张图像
			if not final_img:
				final_img = creat_new_img(tile_size)
				atlas_size = Vector2i(1, 1)
				_copy_image_region(final_img, atlas_img, Vector2i.ZERO)
				continue
				
			# 计算新图块位置并扩展画布
			current_index += 1
			var grid_pos := map_tileindex_to_coor(Vector2i(1,10000),current_index)
			
			# 如果超出当前画布宽度，扩展一列
			if grid_pos.x >= atlas_size.x:
				final_img = extend_new_column(final_img, tile_size)
				atlas_size.x += 1
				
			# 如果超出当前画布高度，扩展一行
			if grid_pos.y >= atlas_size.y:
				final_img = extend_new_row(final_img, tile_size)
				atlas_size.y += 1
				
			# 计算实际绘制位置
			var draw_pos := Vector2i(
				grid_pos.x * tile_size.x,
				grid_pos.y * tile_size.y
			)
			_copy_image_region(final_img, atlas_img, draw_pos)
	
	# 保存结果
	if final_img:
		final_img.save_png(output_path)
		return true
	else:
		push_error("未生成有效图像")
		return false

static func get_sigle_atlas():
	pass

func _ready() -> void:
	var normal_tilesheet = normal_config["tiles-new"][0] # 从normal_config字典中获取"tiles-new"列表的第一个元素，赋值给normal_tilesheet变量
	var tile_entry_range = normal_tilesheet["//"].split(" ") # 获取normal_tilesheet字典中键为"//"的值，并使用空格分割成字符串数组
	tile_entry_range = Vector2i(int(tile_entry_range[1]),int(tile_entry_range[3])) # 将分割后的字符串数组中的第二个和第四个元素转换为整数，并创建一个Vector2i对象
	var tileAtlasSource := TileSetAtlasSource.new() # 创建一个TileSetAtlasSource对象
	tileAtlasSource.texture = NORMAL # 将NORMAL赋值给tileAtlasSource对象的texture属性
	tileAtlasSource.texture_region_size = Vector2(32,32)
	var tileset := TileSet.new() # 创建一个TileSet对象
	tileset.tile_size = Vector2(32,32)
	tileset.add_source(tileAtlasSource) # 将tileAtlasSource对象添加到tileset对象的sources属性中
	ResourceSaver.save(tileset,"res://tileset.tres") # 将tileset对象保存为"res://tileset.tres"文件
	#test_atlas()
	# 单个图块， 动画图块， 多个图块
	var tilecount = [0,0,0]
	var tiles :Array= normal_tilesheet["tiles"]
	var datas = []
	
	for tile in tiles:
		tile = tile as Dictionary 
		var fg = tile.get("fg")
		var bg = tile.get("bg")
		var id = tile.get("id")
		var multitile = tile.get("multitile",false)
		var animated = tile.get("animated",false)
		var atlas = []
		
		if animated:
			tilecount[1] = tilecount[1]+1
			continue
		elif  multitile:
			tilecount[2] = tilecount[2]+1
			continue
		else :
			tilecount[0] = tilecount[0]+1
		if fg:
			var sprites = Sprites.new(fg)
			atlas = sprites.get_atlas(NORMAL,tile_entry_range,Vector2i(32,32))
		var data = {
			"atlas": atlas
		}
		datas.append(data)
	#merge_atlas_textures(datas,Vector2i(32,32),"res://normal_sigle.png")

func test_atlas() -> void:
	var atlas_temp := AtlasTexture.new()
	atlas_temp.atlas = NORMAL
	atlas_temp = get_atlas_from_atlastexture(atlas_temp,Vector2i(0,0),Vector2i(32,32))
	var atlas_img := ImageTexture.create_from_image(atlas_temp.get_image()).get_image()
	atlas_temp = get_atlas_from_atlastexture(atlas_temp,Vector2i(3,0),Vector2i(32,32))
	var atlas_img2 := ImageTexture.create_from_image(atlas_temp.get_image()).get_image()
	atlas_img2.blend_rect(atlas_img,Rect2i(0,0,32,32),Vector2i(0,0))
	atlas_img2 = extend_new_column(atlas_img2,Vector2i(32,32))
	atlas_img2.save_png("res://atlas_img2.png")
	#ResourceSaver.save(atlas_img,"res://new_atlas_texture.tres")
	
class Sprites extends TilesetHelper:
	# 定义一个数组，用于存储精灵树
	var sprite_tree:Array[Sprites] = []
	# 定义权重，默认为1
	var weight = 1
	# 定义当前精灵的索引，默认为-1
	var _sprite = -1
	# 构造函数，初始化精灵树
	func _init(sprites) -> void:
		# 如果输入是数组，调用_is_array函数处理
		if sprites is Array:
			_is_array(sprites)
		# 如果输入是字典，调用_is_dict函数处理
		elif sprites is Dictionary:
			_is_dict(sprites)
		# 如果输入是浮点数，将其转换为整数并赋值给_sprite
		elif sprites is float:
			_sprite = int(sprites)
	# 处理数组类型的输入，构建精灵树
	func _is_array(sprites:Array):
		for sprite in sprites:
			# 递归创建Sprites对象并添加到sprite_tree中
			sprite_tree.append(Sprites.new(sprite))
	# 处理字典类型的输入，设置权重并构建精灵树
	func _is_dict(sprites:Dictionary):
		# 设置权重
		weight = int(sprites["weight"])
		# 创建Sprites对象并添加到sprite_tree中
		sprite_tree.append(Sprites.new(sprites["sprite"]))
	# 判断当前节点是否为叶子节点
	func _is_leaf()->bool:
		return sprite_tree.is_empty()
	# 将当前节点转换为字符串
	func _to_string() -> String:
		if _is_leaf():
			# 如果是叶子节点，返回当前精灵的索引
			return str(_sprite)
		# 如果不是叶子节点，返回子节点的字符串表示，以逗号分隔
		return ",".join(sprite_tree)
	# 获取图集中的纹理
	func get_atlas(atlas:Texture2D,atlas_range:Vector2i,tile_size:Vector2i) -> Array[AtlasTexture]:
		if _is_leaf():
			# 如果是叶子节点，计算纹理坐标并创建AtlasTexture对象
			var coor = map_tileindex_to_coor(atlas_range,_sprite)
			var temp = AtlasTexture.new()
			temp.atlas = atlas
			return [get_atlas_from_atlastexture(temp,coor,tile_size)]
		else:
			# 如果不是叶子节点，遍历子节点并获取其图集中的纹理
			var atlases: Array[AtlasTexture]= []
			for c in sprite_tree: # 遍历sprite_tree中的每个子节点
				var a :Array[AtlasTexture] = c.get_atlas(atlas,atlas_range,tile_size)
				atlases.append_array(a)
			return atlases
				
