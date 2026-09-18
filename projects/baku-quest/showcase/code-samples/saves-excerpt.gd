# Selected function from BakuSaveStore.gd

func write_document(candidate: Dictionary) -> bool:
	if not _writable:
		return false
	var directory := ProjectSettings.globalize_path(save_path.get_base_dir())
	var error := DirAccess.make_dir_recursive_absolute(directory)
	if error != OK:
		last_error = "Cannot create save folder: " + error_string(error)
		return false
	candidate = candidate.duplicate(true)
	candidate["saved_at_utc"] = Time.get_datetime_string_from_system(true)
	var temporary := save_path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "Cannot write save: " + error_string(FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(candidate, "\t"))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK or _read_document(temporary).is_empty():
		last_error = "Save verification failed; previous save preserved."
		return false
	# Keep the last valid generation, including after recovery from a bad primary.
	if not _read_document(save_path).is_empty():
		error = DirAccess.copy_absolute(ProjectSettings.globalize_path(save_path), ProjectSettings.globalize_path(save_path + ".bak"))
		if error != OK:
			last_error = "Cannot back up save: " + error_string(error)
			return false
	error = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(save_path))
	if error != OK:
		last_error = "Cannot replace save: " + error_string(error)
		return false
	data = candidate.duplicate(true)
	last_error = ""
	return true
