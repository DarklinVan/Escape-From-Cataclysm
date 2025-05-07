extends Node

func _ready() -> void:
	var reg :Array[String]= [".png$"]
	var reg2 :Array[String]= [".json$","normal"]
	var pngs = dir_contents("res://Assets/TileSets/Raw",reg)
	var jsons = dir_contents("res://Assets/TileSets/Raw",reg2)
	for j in jsons:
		var file_path = j["path"]
		# 示例：读取 JSON 文件内容
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			var json_data = JSON.parse_string(content)
			if json_data:
				print("成功解析 JSON: ", file_path)
			else:
				printerr("JSON 解析失败: ", file_path)

func dir_contents(path: String, reg: Array[String] = []) -> Array:
	var dir = DirAccess.open(path)
	var list = []
	
	# 预编译正则表达式（空数组时自动包含所有文件）
	var regex_list = _compile_regex_array(reg)
	
	if dir:
		dir.list_dir_begin()  # 跳过隐藏文件和导航目录（. / ..）
		var file_name = dir.get_next()
		
		while file_name != "":
			var full_path = path.path_join(file_name)
			var is_dir = dir.current_is_dir()
			
			# 目录：直接递归遍历
			if is_dir:
				list.append_array(dir_contents(full_path, reg))
			# 文件：根据正则规则过滤
			else:
				var match_rule = regex_list.is_empty() || _match_any_regex(file_name, regex_list)
				if match_rule:
					list.append({"name": file_name, "path": full_path})
			
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		printerr("路径访问失败: ", path)
	return list

# 辅助函数：编译正则表达式数组
func _compile_regex_array(patterns: Array) -> Array[RegEx]:
	var regex_array :Array[RegEx]= []
	for pattern in patterns:
		var regex = RegEx.new()
		if regex.compile(pattern) == OK:
			regex_array.append(regex)
	return regex_array

# 辅助函数：检查是否匹配任意正则
func _match_any_regex(text: String, regex_list: Array[RegEx]) -> bool:
	for regex in regex_list:
		if regex.search(text):
			return true
	return false
