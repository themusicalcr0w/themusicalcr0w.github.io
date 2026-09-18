# Source: Scripts/World/Suburban/SuburbanStaticBatcher.gd
# Selected source; requires the surrounding project.

func _register_residency() -> void:
	# Only immutable render batches are evicted. Authored bodies, colliders,
	# occluders, seats, doors and NPC nodes remain present and keep their state.
	if cache_source_used.is_empty() or not get_parent().has_node("CityDistrict"): return
	for visual: MeshInstance3D in find_children("StaticBatch_*", "MeshInstance3D", true, false):
		if visual.mesh == null: continue
		_resident_batches.append({"visual":visual,"bounds":visual.global_transform*visual.get_aabb(),"missing":false})

func _update_residency() -> void:
	if _resident_batches.is_empty() or _restore_failed or OS.get_environment("CITY_SUBURB_RESIDENCY") == "0": return
	var camera := get_viewport().get_camera_3d()
	if camera == null: return
	# The margin includes shadows and fast vehicles; long connector-road batches
	# use their nearest bound, so they stay present when any part is nearby.
	var keep := maxf(camera.far,500.0)+150.0
	var restore := keep-50.0
	var missing_nearby := false
	for record in _resident_batches:
		var bounds: AABB = record.bounds
		var distance := camera.global_position.distance_to(camera.global_position.clamp(bounds.position,bounds.end))
		if not _force_resident and distance > keep and not record.missing:
			record.visual.mesh = null
			record.missing = true
		elif record.missing and (_force_resident or distance < restore): missing_nearby = true
	if missing_nearby and not _restore_pending:
		if ResourceLoader.load_threaded_request(cache_source_used,"PackedScene",false,ResourceLoader.CACHE_MODE_IGNORE) != OK:
			_restore_failed = true; push_error("Cannot restore suburban geometry: "+cache_source_used); return
		_restore_pending = true
	if not _restore_pending: return
	var status := ResourceLoader.load_threaded_get_status(cache_source_used)
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS: return
	var packed := ResourceLoader.load_threaded_get(cache_source_used) as PackedScene
	_restore_pending = false
	if packed == null:
		_restore_failed = true; push_error("Cannot load suburban geometry: "+cache_source_used); return
	# Read mesh references from scene state instead of instantiating a second
	# suburb. Restore only the batches inside the current viewing margin.
	var meshes := {}
	var state := packed.get_state()
	for index in state.get_node_count():
		if not str(state.get_node_name(index)).begins_with("StaticBatch_"): continue
		for property in state.get_node_property_count(index):
			if state.get_node_property_name(index,property) == &"mesh":
				meshes[state.get_node_name(index)] = state.get_node_property_value(index,property)
	for record in _resident_batches:
		if not record.missing: continue
		var bounds: AABB = record.bounds
		if not _force_resident and camera.global_position.distance_to(camera.global_position.clamp(bounds.position,bounds.end)) >= keep: continue
		var mesh := meshes.get(record.visual.name) as Mesh
		if mesh == null:
			_restore_failed = true; push_error("Suburban cache lost batch "+str(record.visual.name)); continue
		record.visual.mesh = mesh; record.missing = false
