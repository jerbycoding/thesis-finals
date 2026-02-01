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
				if file_name.ends_with(extension):
					paths.append(full_path)
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
			if not matches_class and res.get_script():
				if res.get_script().get_global_name() == expected_class:
					matches_class = true
			
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
