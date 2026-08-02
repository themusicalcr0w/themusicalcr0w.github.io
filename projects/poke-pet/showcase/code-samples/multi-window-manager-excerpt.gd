# Representative excerpt from Scripts/PokePet.gd
# Window synchronization and per-pet native window creation.

func _sync_pet_windows(target_count: int = -1) -> void:
	if not is_primary_pet:
		return

	if target_count < 0:
		target_count = PokeEmote.load_number_of_pokemon()
	target_count = clampi(target_count, 1, PokeEmote.MAX_POKEMON)
	emote.number_of_pokemon = target_count

	for index in range(1, target_count + 1):
		if not spawned_pet_windows.has(index) or not is_instance_valid(spawned_pet_windows[index]):
			_spawn_pet_window(index)

	for key in spawned_pet_windows.keys():
		var index := int(key)
		if index > target_count:
			var window := spawned_pet_windows[index] as Window
			if is_instance_valid(window):
				_close_spawned_pet_window(window)
			spawned_pet_windows.erase(index)




func _spawn_pet_window(index: int) -> void:
	PokeEmote.ensure_pet_slot(index, 1)

	var packed_scene := _get_pet_window_scene()
	if not packed_scene:
		push_warning("Unable to load pet window scene: %s" % PET_WINDOW_SCENE_PATH)
		return

	var window := packed_scene.instantiate() as Window
	if not window:
		push_warning("Pet window scene root must be a Window: %s" % PET_WINDOW_SCENE_PATH)
		return

	window.visible = false
	var screen_id := PokeEmote.load_pet_monitor_index(index)
	var spawn_position := _get_pet_window_spawn_position(index, screen_id)

	window.title = APP_NAME + " " + str(index)
	window.current_screen = screen_id
	window.position = spawn_position
	_configure_window_for_desktop_pet(window, false)
	window.close_requested.connect(Callable(window, "queue_free"))

	var scene_root := window.get_node_or_null("SceneRoot")
	if not scene_root:
		push_warning("Pet window scene is missing SceneRoot.")
		window.queue_free()
		return

	var pet := scene_root.get_node_or_null("Pet") as PokePet
	if pet:
		pet.pet_index = index
		pet.is_primary_pet = false
		pet.has_initial_window_position = true
		pet.initial_window_position = spawn_position
		var emote_node := pet.get_node_or_null("Emotions2")
		if emote_node is PokeEmote:
			emote_node.pet_index = index

	get_tree().root.add_child(window)
	spawned_pet_windows[index] = window
	window.show()
	_apply_background_window_hint_for_window(window)





# Despawn path keeps runtime windows and saved slot order consistent.
func _despawn_pet_window(index: int) -> void:
	if not is_primary_pet or index <= 1:
		return

	var new_count := PokeEmote.despawn_pet(index)
	emote.number_of_pokemon = new_count
	_close_popup()

	for key in spawned_pet_windows.keys():
		var window := spawned_pet_windows[key] as Window
		if is_instance_valid(window):
			_close_spawned_pet_window(window)
	spawned_pet_windows.clear()
	get_tree().call_group("poke_pet_instances", "_on_number_of_pokemon_changed", new_count)
	call_deferred("_sync_pet_windows", new_count)



