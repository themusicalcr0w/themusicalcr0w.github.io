# Selected function from BattleRules.gd

func command(owner: int, action: Dictionary) -> String:
	if winner != -2: return "The battle has ended."
	if owner < 0 or owner > 1: return "Invalid player."
	var kind := str(action.get("type", ""))
	if not choices.is_empty() and kind != "choice": return "Resolve the pending card choice first."
	var error := "Unknown command."
	match kind:
		"choice": error = _choice(owner,int(action.get("index",-1)))
		"set_gate": error = _set_gate(owner, int(action.get("hand", -1)), int(action.get("slot", -1)))
		"throw": error = _throw(owner, int(action.get("bakugan", -1)), int(action.get("slot", -1)))
		"ability": error = _ability(owner, action)
		"change_attribute": error = _change_attribute(owner, action)
		"pass": error = _pass(owner)
		"concede":
			winner = 1 - owner
			phase = "ended"
			_emit("ended", "%s conceded." % players[owner].name, {"winner": winner})
			error = ""
	if error == "":
		commands.append({"owner": owner, "action": action.duplicate(true)})
		_check_victory()
	return error
