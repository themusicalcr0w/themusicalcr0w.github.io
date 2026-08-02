# Portfolio excerpt from PopulateWorld.gd and ResidenceAllocator.gd
# Unrelated implementation details omitted. This file is not intended to compile alone.

# PopulateWorld.gd
func populate_world(
	p_world_map,
	p_character_manager: CharacterManager,
	p_player_profile: Dictionary = {},
	p_player_character: Character = null
) -> Dictionary:
	world_map = p_world_map
	character_manager = p_character_manager
	player_profile = p_player_profile.duplicate(true)
	player_character = p_player_character

	_build_helpers()
	residence_allocator.prepare_residences()
	# DEBUG: Console logging to diagnose generation stalls before the UI finishes rendering.
	_debug_log(
		"Prepared residences: family_homes=%d apartments=%d" % [
			residence_allocator.get_available_family_building_count(),
			residence_allocator.apartment_buildings.size()
		]
	)

	if player_character != null:
		create_player_family(player_character, player_profile)
		_debug_log(
			"Player family generated: total_characters=%d remaining_family_homes=%d" % [
				character_manager.get_character_count(),
				residence_allocator.get_available_family_building_count()
			]
		)

	var family_iteration: int = 0
	while residence_allocator.has_available_family_buildings():
		var available_homes_before: int = residence_allocator.get_available_family_building_count()
		var created_households: Array = create_family()
		var available_homes_after: int = residence_allocator.get_available_family_building_count()
		family_iteration += 1
		if family_iteration == 1 or family_iteration % 25 == 0 or available_homes_after == 0:
			_debug_log(
				"Family iteration %d: households=%d homes_before=%d homes_after=%d total_characters=%d" % [
					family_iteration,
					created_households.size(),
					available_homes_before,
					available_homes_after,
					character_manager.get_character_count()
				]
			)
		if created_households.is_empty() or available_homes_after >= available_homes_before:
			_debug_log(
				"Family generation stalled: households=%d homes_before=%d homes_after=%d total_characters=%d" % [
					created_households.size(),
					available_homes_before,
					available_homes_after,
					character_manager.get_character_count()
				]
			)
			break

	_debug_log("Preparing apartment layouts for %d apartment buildings" % residence_allocator.apartment_buildings.size())
	residence_allocator.populate_single_apartments()

# ResidenceAllocator.gd
func _relocate_eligible_adult_children(household: Dictionary) -> Dictionary:
	var final_household: Dictionary = household.duplicate(true)
	if not bool(final_household.get("allowAdultChildMoveOut", true)):
		return final_household

	var members: Array = final_household.get("members", []).duplicate()
	var children: Array = final_household.get("children", []).duplicate()
	var moved_children: Array = []

	for child in children:
		if child == null or child.body == null:
			continue
		if child.age <= 18:
			continue
		debug_eligible_adult_children += 1
		if randf() > ADULT_CHILD_MOVE_OUT_CHANCE:
			debug_adult_children_skipped_by_chance += 1
			continue
		if not _assign_existing_character_to_apartment(child):
			debug_adult_children_failed_apartment_assignment += 1
			continue
		moved_children.append(child)

	for moved_child in moved_children:
		members.erase(moved_child)
		children.erase(moved_child)

	final_household["members"] = members
	final_household["children"] = children
	return final_household

func _assign_existing_character_to_apartment(character: Character) -> bool:
	if character == null or character.body == null:
		return false
	var apartment: Building = _find_apartment_with_capacity()
	if apartment == null:
		return false

	room_layout_builder.ensure_apartment_common_rooms(apartment, apartment.residentBodyIds.size() + 1)
	apartment.add_resident_body(character.body.bodyId)
	apartment.add_occupant_body(character.body.bodyId)
	var bedroom: Room = room_layout_builder.create_apartment_bedroom(apartment, character.body.bodyId, character.nameFirst)
	if bedroom == null:
		apartment.remove_resident_body(character.body.bodyId)
		apartment.remove_occupant_body(character.body.bodyId)
		return false
	# DEBUG: Track move-outs reaching each apartment building for the in-game summary.
	debug_adult_children_moved_to_apartments += 1
	apartment.set_metadata_value(
		"debug_moved_out_adult_children",
		int(apartment.get_metadata_value("debug_moved_out_adult_children", 0)) + 1
	)
	return true

func _find_apartment_with_capacity() -> Building:
	var best_building: Building = null
	var lowest_resident_count: int = 999999
	for building in apartment_buildings:
		if building == null:
			continue
		var max_residents: int = building.maxResidents if building.maxResidents > 0 else 0
		if max_residents <= 0:
			continue
		var resident_count: int = building.residentBodyIds.size()
		if resident_count >= max_residents:
			continue
		if resident_count < lowest_resident_count:
			lowest_resident_count = resident_count
			best_building = building
	return best_building
