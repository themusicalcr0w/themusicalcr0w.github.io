# Representative excerpt from Scripts/MainNode.gd
# Monitor-aware sizing, positioning, DPI scaling, and edge response.

	
	
	
	
func _ready() -> void:
	var pet := _get_pet_node()
	if pet and pet.is_primary_pet:
		set_process(false)
		return

	set_process(true)
	cam.make_current()
	cam.position = Vector2.ZERO
	cam.offset   = Vector2.ZERO
	call_deferred("apply_pet_window_settings", true)




func apply_pet_window_settings(reset_position: bool = false) -> void:
	var id := get_window().get_window_id()
	if id == DisplayServer.INVALID_WINDOW_ID:
		call_deferred("apply_pet_window_settings", reset_position)
		return

	var current_screen_id := DisplayServer.window_get_current_screen(id)
	if current_screen_id < 0 or current_screen_id >= DisplayServer.get_screen_count():
		current_screen_id = _get_screen_for_position(win.position)

	var screen_id := _get_monitor_index()
	var current_screen_rect := DisplayServer.screen_get_usable_rect(current_screen_id)
	var screen_rect := DisplayServer.screen_get_usable_rect(screen_id)
	var dpi_scale := DisplayServer.screen_get_scale(screen_id)
	var window_scale := _get_window_scale()
	var px := Vector2i((BASE_WINDOW_SIZE * dpi_scale * window_scale).round())
	var old_center: Vector2 = Vector2(win.position) + Vector2(win.size) * 0.5
	win.current_screen = screen_id

	win.min_size = px
	win.size = px

	var window_pos: Vector2i
	if reset_position:
		var pet := _get_pet_node()
		if pet and pet.has_initial_window_position and screen_rect.has_point(pet.initial_window_position):
			window_pos = pet.initial_window_position
		else:
			var pet_index := _get_pet_index()
			var spacing := win.size.x + 24
			var right_margin := 100 + ((pet_index - 1) * spacing)
			window_pos = screen_rect.position
			window_pos.x += screen_rect.size.x - win.size.x - right_margin
	else:
		window_pos = Vector2i((old_center - Vector2(win.size) * 0.5).round())
		if current_screen_id != screen_id:
			var relative_x := clampf((old_center.x - current_screen_rect.position.x) / max(1.0, float(current_screen_rect.size.x)), 0.0, 1.0)
			window_pos.x = screen_rect.position.x + int(round(relative_x * float(screen_rect.size.x) - float(win.size.x) * 0.5))

	window_pos.x = clampi(window_pos.x, screen_rect.position.x, screen_rect.position.x + max(0, screen_rect.size.x - win.size.x))
	window_pos.y = screen_rect.position.y + screen_rect.size.y - win.size.y - int(round(_get_height_offset()))
	win.position = window_pos

	var win_center: Vector2 = Vector2(win.position) + Vector2(win.size) * 0.5
	window_delta = win_center - cam.global_position





func check_monitor_edges():
	var screen_id := DisplayServer.window_get_current_screen(win.get_window_id())
	var window_left = win.position.x
	
	if window_left <= screen_rect.position.x:
		send_window_bump("right") #hitting the left edge
	elif window_right >= screen_rect.position.x + screen_rect.size.x:
		send_window_bump("left") #hitting the right edge
		
		
		
		
		
func get_more_space_side(global_x: float) -> String:
	var screen_id := DisplayServer.window_get_current_screen(win.get_window_id())
	var screen_rect := DisplayServer.screen_get_usable_rect(screen_id)

	var dist_left := global_x - screen_rect.position.x
	var dist_right := (screen_rect.position.x + screen_rect.size.x) - global_x

