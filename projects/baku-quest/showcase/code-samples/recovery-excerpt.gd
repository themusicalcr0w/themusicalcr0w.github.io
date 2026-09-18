# Selected function from BakuSaveStore.gd

func load_save() -> bool:
	data = fresh_document()
	last_error = ""
	recovered_backup = false
	_writable = true
	if not FileAccess.file_exists(save_path):
		if not FileAccess.file_exists(save_path + ".bak"):
			return true
	if FileAccess.file_exists(save_path):
		var header = _decode(FileAccess.get_file_as_string(save_path))
		if header is Dictionary and header.get("schema") != SCHEMA:
			_writable = false
			last_error = "This save uses an unsupported version. Existing files were preserved."
			return false
	var loaded := _read_document(save_path)
	if loaded.is_empty():
		loaded = _read_document(save_path + ".bak")
		recovered_backup = not loaded.is_empty()
	if loaded.is_empty():
		_writable = false
		last_error = "The save could not be loaded. Existing files were preserved."
		return false
	data = loaded
	return true
