# Representative excerpt from Scripts/PokeEmote.gd
# Per-pet ConfigFile sections, inherited layout, and slot compaction.

static func pet_section(index: int) -> String:
	return PET_SECTION_PREFIX + str(max(1, index))




func _section() -> String:
	return pet_section(pet_index)




func _get_pet_value(cfg: ConfigFile, key: String, default_value: Variant) -> Variant:
	var fallback: Variant = default_value
	if pet_index == 1:
		fallback = cfg.get_value(LEGACY_SECTION, key, default_value)

	return cfg.get_value(_section(), key, fallback)




static func load_number_of_pokemon() -> int:
static func ensure_pet_slot(index: int, inherit_layout_from: int = 1, force_layout_inherit: bool = false) -> void:
	if index <= 1:
		return

	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		cfg = ConfigFile.new()

	var section := pet_section(index)
	if cfg.has_section(section):
		var layout_initialized := bool(cfg.get_value(section, KEY_LAYOUT_INITIALIZED, false))
		if force_layout_inherit or not layout_initialized:
			_copy_layout_settings(cfg, pet_section(inherit_layout_from), section)
			cfg.set_value(section, KEY_TEXT_GREY, 0.0)
			cfg.set_value(section, KEY_LAYOUT_INITIALIZED, true)
			cfg.save(SAVE_PATH)
		return

	var inherit_section := pet_section(inherit_layout_from)
	var inherited_bg := str(cfg.get_value(inherit_section, KEY_BG_COLOR, cfg.get_value(LEGACY_SECTION, KEY_BG_COLOR, Color(0.155, 0.155, 0.155).to_html())))
	var inherited_opacity := float(cfg.get_value(inherit_section, KEY_BG_OPACITY, cfg.get_value(LEGACY_SECTION, KEY_BG_OPACITY, 0.4)))
	var inherited_scale := float(cfg.get_value(inherit_section, KEY_WINDOW_SCALE, cfg.get_value(LEGACY_SECTION, KEY_WINDOW_SCALE, 1.0)))
	var inherited_height := float(cfg.get_value(inherit_section, KEY_HEIGHT_OFFSET, cfg.get_value(LEGACY_SECTION, KEY_HEIGHT_OFFSET, 0.0)))
	var inherited_monitor := int(cfg.get_value(inherit_section, KEY_MONITOR_INDEX, cfg.get_value(LEGACY_SECTION, KEY_MONITOR_INDEX, DEFAULT_MONITOR_INDEX)))

	cfg.set_value(section, KEY_FRIENDSHIP, 300)
	cfg.set_value(section, KEY_SHINY, false)
	cfg.set_value(section, KEY_FEMALE, false)
	cfg.set_value(section, KEY_POKEDEX, 137)
	cfg.set_value(section, KEY_POKEMON, "137")
	cfg.set_value(section, KEY_ALT_INDEX, 0)
	cfg.set_value(section, KEY_BG_COLOR, inherited_bg)
	cfg.set_value(section, KEY_BG_OPACITY, inherited_opacity)
	cfg.set_value(section, KEY_TEXT_GREY, 0.0)
	cfg.set_value(section, KEY_WINDOW_SCALE, clampf(float(inherited_scale), 0.5, 4.0))
	cfg.set_value(section, KEY_HEIGHT_OFFSET, clampf(float(inherited_height), -300.0, 300.0))
	cfg.set_value(section, KEY_MONITOR_INDEX, normalize_monitor_index(inherited_monitor))
	cfg.set_value(section, KEY_LAYOUT_INITIALIZED, true)
	cfg.save(SAVE_PATH)




static func _copy_layout_settings(cfg: ConfigFile, from_section: String, to_section: String) -> void:
	var inherited_scale := float(cfg.get_value(from_section, KEY_WINDOW_SCALE, cfg.get_value(LEGACY_SECTION, KEY_WINDOW_SCALE, 1.0)))
	var inherited_height := float(cfg.get_value(from_section, KEY_HEIGHT_OFFSET, cfg.get_value(LEGACY_SECTION, KEY_HEIGHT_OFFSET, 0.0)))
	var inherited_monitor := int(cfg.get_value(from_section, KEY_MONITOR_INDEX, cfg.get_value(LEGACY_SECTION, KEY_MONITOR_INDEX, DEFAULT_MONITOR_INDEX)))

	cfg.set_value(to_section, KEY_WINDOW_SCALE, clampf(inherited_scale, 0.5, 4.0))
	cfg.set_value(to_section, KEY_HEIGHT_OFFSET, clampf(inherited_height, -300.0, 300.0))
	cfg.set_value(to_section, KEY_MONITOR_INDEX, normalize_monitor_index(inherited_monitor))



static func despawn_pet(index: int) -> int:
	if index <= 1:
		return load_number_of_pokemon()

	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		save_number_of_pokemon(1)
		return 1

	var count := load_number_of_pokemon()
	if index > count:
		return count

	for move_index in range(index, count):
		_copy_pet_section(cfg, pet_section(move_index + 1), pet_section(move_index))

	var last_section := pet_section(count)
	if cfg.has_section(last_section):
		cfg.erase_section(last_section)

	var new_count := clampi(count - 1, 1, MAX_POKEMON)
	cfg.set_value(GLOBAL_SECTION, KEY_NUMBER_OF_POKEMON, new_count)
	cfg.save(SAVE_PATH)
	return new_count




static func _copy_pet_section(cfg: ConfigFile, from_section: String, to_section: String) -> void:
	if cfg.has_section(to_section):
		cfg.erase_section(to_section)

	if not cfg.has_section(from_section):
		return

	for key in cfg.get_section_keys(from_section):
		cfg.set_value(to_section, key, cfg.get_value(from_section, key))



