# FileUtil.gd
# Utility class for handling file system operations
class_name FileUtil

## Scans a directory for files matching an extension and returns their full paths.
static func get_resource_paths(dir_path: String, extension: String = ".tres") -> Array[String]:
	var paths: Array[String] = []
	var dir = DirAccess.open(dir_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				if file_name.ends_with(extension):
					paths.append(dir_path.path_join(file_name))
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("FileUtil: Failed to open directory: " + dir_path)
		
	return paths
