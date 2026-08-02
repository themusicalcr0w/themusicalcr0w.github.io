# Portfolio excerpt from GeneratedDialogueService.gd, BodyMemory.gd,
# and ObservedBodySnapshot.gd. This shows the data flow across the system.

# GeneratedDialogueService.gd
func generate_for_intent(intent_id: String, overrides: Dictionary = {}) -> Dictionary:
	var opcode_command := _get_opcode_for_intent(intent_id, overrides)
	if opcode_command == "":
		opcode_command = GeneratedDialogueOpcodeData.build(GeneratedDialogueOpcodeData.OP_SMALL_TALK, {"intent": intent_id})
	var context := overrides.duplicate(true)
	context["intent_id"] = intent_id
	return generate_from_opcode(opcode_command, context)


func generate_from_opcode(opcode_command: String, overrides: Dictionary = {}) -> Dictionary:
	var parsed := GeneratedDialogueOpcodeData.parse(opcode_command)
	var opcode_key := str(parsed.get("opcode", "")).to_upper()
	var params := Dictionary(parsed.get("params", {}))
	var positional := Array(parsed.get("positional", []))
	var context := build_context(overrides, params, positional, opcode_key)
	var bank_id := _resolve_bank_id(opcode_key, params, context)
	var text := _render_phrase(_select_phrase(bank_id, context, params), context, params)
	var choices: Array[Dictionary] = _build_choices_for_opcode(opcode_key, params, context)
	var effects: Array[Dictionary] = _build_effects_for_opcode(opcode_key, params, context)
	return {
		"opcode": opcode_key,
		"bankId": bank_id,
		"text": text,
		"choices": choices,
		"effects": effects,
		"context": context,
		"params": params,
		"rawOpcode": str(parsed.get("raw", opcode_command))
	}

# BodyMemory.gd
func update_snapshot(
	body,
	actor = null,
	current_day: int = 0,
	location: String = "",
	known_name: String = "",
	relationship_summary: Dictionary = {},
	event_id: int = -1,
	visibility_context: Dictionary = {}
):
	if body == null or body.bodyId <= 0:
		return null
	var context := visibility_context.duplicate(true)
	if known_name.strip_edges() != "":
		context[ObservedBodySnapshotData.VISIBILITY_KNOWN_NAME] = known_name.strip_edges()
	var snapshot = get_snapshot(body.bodyId)
	if snapshot == null:
		snapshot = create_snapshot(body, current_day, location, known_name, context)
	else:
		snapshot.update_from_body(body, actor, current_day, location, context)
	if snapshot == null:
		return null
	var body_id := _sanitize_body_id(body.bodyId)
	if relationship_summary.is_empty():
		relationshipSummariesByBodyId.erase(body_id)
	else:
		relationshipSummariesByBodyId[body_id] = relationship_summary.duplicate(true)
	if event_id > 0:
		register_event_for_body(body_id, event_id)
	return snapshot

# ObservedBodySnapshot.gd
func _update_observed_dictionary(target: Dictionary, values: Dictionary, prefix: String, current_day: int, location: String) -> void:
	for key_variant in values.keys():
		var key := str(key_variant).strip_edges()
		if key == "":
			continue
		target[key] = values[key_variant]
		_record_feature("%s.%s" % [prefix, key], values[key_variant], current_day, location)


func _record_feature(feature_key: String, value, current_day: int, location: String) -> void:
	observedFeatures[feature_key] = value.duplicate(true) if value is Dictionary or value is Array else value
	featureObservedDays[feature_key] = maxi(current_day, 0)
	featureObservedLocations[feature_key] = location
	featureObservationCounts[feature_key] = int(featureObservationCounts.get(feature_key, 0)) + 1
