# FileUtil.gd
# Utility class for handling file system operations
class_name FileUtil

## Scans a directory (and all sub-directories) for files matching an extension and returns their full paths.
static func get_resource_paths(dir_path: String, extension: String = ".tres") -> Array[String]:
	var paths: Array[String] = []
	var dir = DirAccess.open(dir_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var full_path = dir_path.path_join(file_name)
			if dir.current_is_dir():
				# RECURSIVE CALL: Drill down into sub-folders
				if file_name != "." and file_name != "..":
					paths.append_array(get_resource_paths(full_path, extension))
			else:
				# In exported builds, .tres files become .tres.remap.
				# We check the "clean" name but append the original path for Godot's loader.
				var clean_name = file_name.replace(".remap", "").replace(".import", "")
				if clean_name.ends_with(extension):
					paths.append(dir_path.path_join(clean_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("FileUtil: Failed to open directory: " + dir_path)
		
	return paths

## Scans a directory, loads all `.tres` resources, and validates them against an expected class name.
static func load_and_validate_resources(dir_path: String, expected_class: String) -> Array[Resource]:
	var resources: Array[Resource] = []
	var paths = get_resource_paths(dir_path)
	
	for path in paths:
		var res = load(path)
		if res:
			# Check if it's a built-in class or a custom class_name
			var matches_class = res.is_class(expected_class)
			
			if not matches_class:
				# Godot 4 custom class_name lookup
				for cls_data in ProjectSettings.get_global_class_list():
					if cls_data.class == expected_class:
						var cls_script = load(cls_data.path)
						if res.get_script() == cls_script:
							matches_class = true
							break
			
			if matches_class:
				if res.has_method("validate") and not res.validate():
					push_warning("FileUtil: Skipping malformed resource '%s' in %s" % [path.get_file(), dir_path])
					continue
				resources.append(res)
			else:
				push_warning("FileUtil: Skipping resource '%s' with incorrect type in %s. Expected '%s', got '%s'." % [path.get_file(), dir_path, expected_class, res.get_class()])
		else:
			push_warning("FileUtil: Failed to load resource at path %s" % path)
			
	return resources
