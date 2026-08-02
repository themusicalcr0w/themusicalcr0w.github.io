# Portfolio excerpt from SaveGameManager.gd
# Main-thread snapshot work is frame-budgeted; serialization and disk I/O continue
# on a background thread after a consistent point-in-time snapshot is captured.

const INCREMENTAL_SAVE_FRAME_BUDGET_USEC := 3500

func capture_character_before_save_mutation(character) -> void:
	if not _snapshot_save_active:
		return
	_snapshot_character(character)


func capture_body_before_save_mutation(body_id: int) -> void:
	if not _snapshot_save_active:
		return
	_snapshot_character(_find_snapshot_character_by_body_id(body_id))


func capture_location_before_save_mutation(location) -> void:
	if not _snapshot_save_active:
		return
	_snapshot_location(location)


func _start_incremental_save_snapshot(source_data: Dictionary, file_path: String, timestamp: int, profile_id: String) -> int:
	if _snapshot_save_active or _background_save_thread != null:
		return ERR_BUSY
	_clear_incremental_save_snapshot_state()
	_snapshot_save_active = true
	_snapshot_save_source_data = source_data.duplicate(false)
	_snapshot_save_payload_context = Dictionary(source_data.get("payload_context", {})).duplicate(false)
	_snapshot_save_character_refs = Array(_snapshot_save_payload_context.get("character_refs", [])).duplicate(false)
	_snapshot_save_location_refs = Array(_snapshot_save_payload_context.get("location_refs", [])).duplicate(false)
	_snapshot_save_file_path = file_path
	_snapshot_save_profile_id = profile_id
	_snapshot_save_timestamp = timestamp
	_capture_priority_snapshot_entries()
	set_process(true)
	return OK


func _process_incremental_save_snapshot() -> void:
	if not _snapshot_save_active:
		return
	var frame_started := Time.get_ticks_usec()
	while _snapshot_save_active:
		if _snapshot_save_character_index < _snapshot_save_character_refs.size():
			_snapshot_next_character()
		elif _snapshot_save_location_index < _snapshot_save_location_refs.size():
			_snapshot_next_location()
		else:
			_finish_incremental_save_snapshot()
			return
		if Time.get_ticks_usec() - frame_started >= INCREMENTAL_SAVE_FRAME_BUDGET_USEC:
			return

func _snapshot_character(character) -> void:
	if character == null:
		return
	var character_id := int(character.get("characterId"))
	if character_id <= 0 or _snapshot_save_character_ids.has(character_id):
		return
	var entry := MainGameSaveSerializerData.build_character_save_entry(character)
	if entry.is_empty():
		return
	_snapshot_save_character_ids[character_id] = true
	_snapshot_save_character_entries.append(entry)


func _snapshot_next_location() -> void:
	var location = _snapshot_save_location_refs[_snapshot_save_location_index]
	_snapshot_save_location_index += 1
	_snapshot_location(location)


func _snapshot_location(location) -> void:
	if location == null:
		return
	var location_id := int(location.get("locationId"))
	if location_id <= 0 or _snapshot_save_location_ids.has(location_id):
		return
	var entry := MainGameSaveSerializerData.build_location_save_entry(location)
	if entry.is_empty():
		return
	_snapshot_save_location_ids[location_id] = true
	_snapshot_save_location_entries.append(entry)

func _finish_incremental_save_snapshot() -> void:
	var payload := MainGameSaveSerializerData.build_main_game_payload_from_snapshot_context(
		_snapshot_save_payload_context,
		_snapshot_save_character_entries,
		_snapshot_save_location_entries
	)
	var source_data := {
		"scene_key": str(_snapshot_save_source_data.get("scene_key", "main_game")).strip_edges(),
		"scene_path": str(_snapshot_save_source_data.get("scene_path", DEFAULT_MAIN_GAME_SCENE)).strip_edges(),
		"preview": Dictionary(_snapshot_save_source_data.get("preview", {})).duplicate(true),
		"payload": payload
	}
	var file_path := _snapshot_save_file_path
	var timestamp := _snapshot_save_timestamp
	var profile_id := _snapshot_save_profile_id
	_clear_incremental_save_snapshot_state()
	var start_error := _start_background_save_write(source_data, file_path, timestamp, profile_id)
	if start_error != OK:
		_fail_background_save(file_path, "Background save could not be started.")


func _clear_incremental_save_snapshot_state() -> void:
	_snapshot_save_active = false
	_snapshot_save_source_data = {}
	_snapshot_save_payload_context = {}
	_snapshot_save_character_refs = []
	_snapshot_save_location_refs = []
	_snapshot_save_character_entries = []
	_snapshot_save_location_entries = []
	_snapshot_save_character_ids = {}
	_snapshot_save_location_ids = {}
	_snapshot_save_character_index = 0
	_snapshot_save_location_index = 0
	_snapshot_save_file_path = ""
	_snapshot_save_profile_id = ""
	_snapshot_save_timestamp = 0


func _start_background_save_write(source_data: Dictionary, file_path: String, timestamp: int, profile_id: String) -> int:
	if _background_save_thread != null:
		if _background_save_thread.is_alive():
			return ERR_BUSY
		_background_save_thread.wait_to_finish()
		_background_save_thread = null
	_background_save_profile_id = profile_id
	_background_save_file_path = file_path
	_background_save_thread = Thread.new()
	var start_error := _background_save_thread.start(Callable(self, "_background_save_write_thread").bind(source_data, file_path, timestamp))
	if start_error != OK:
		_background_save_thread = null
		_background_save_profile_id = ""
		_background_save_file_path = ""
		return start_error
	set_process(true)
	return OK


func _background_save_write_thread(source_data: Dictionary, file_path: String, timestamp: int) -> Dictionary:
	var save_data := _build_save_file_data_for_background_source(source_data, timestamp)
	if save_data.is_empty():
		return _build_save_failure("Background save snapshot was not ready.")
	return _write_save_data_to_disk(save_data, file_path)
