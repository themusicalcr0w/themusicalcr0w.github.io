# Portfolio excerpt from JournalPageCurlRenderer.gd
# Generates the deforming 2D page mesh used during page turns.

func set_turn_progress(value: float) -> void:
	if not _active:
		return
	_progress = clampf(value, 0.0, 1.0)
	var should_use_back := _progress >= 0.5
	if should_use_back != _using_back_face:
		_using_back_face = should_use_back
		var page_texture := _back_texture if _using_back_face and _back_texture != null else _front_texture
		_sheet_mesh.texture = page_texture
		_set_page_shader_texture(page_texture)
	_set_shader_progress(_progress)
	_rebuild_mesh()
	_update_cast_shadow()

func _rebuild_mesh() -> void:
	if _page_size.x <= 1.0 or _page_size.y <= 1.0:
		return
	var mesh := ArrayMesh.new()
	var vertices := PackedVector2Array()
	var uvs := PackedVector2Array()
	var colors := PackedColorArray()
	var indices := PackedInt32Array()
	var fold_amount := sin(_progress * PI)
	var width_factor := maxf(MIN_VISIBLE_WIDTH / maxf(_page_size.x, 1.0), absf(1.0 - (_progress * 2.0)))
	var visible_width := _page_size.x * width_factor
	var side_sign := _get_visible_side_sign()
	var hinge_x := _get_hinge_x()
	var curve_sign := _get_curve_sign()
	var horizontal_bow := 16.0 * fold_amount * curve_sign
	var vertical_bow := 7.0 * fold_amount * curve_sign
	var y_base := _get_visible_y()

	for row in range(ROW_COUNT + 1):
		var y_fraction := float(row) / float(ROW_COUNT)
		for column in range(COLUMN_COUNT + 1):
			var t := float(column) / float(COLUMN_COUNT)
			var curl_curve := sin(t * PI)
			var x := hinge_x + side_sign * visible_width * t
			x += side_sign * horizontal_bow * curl_curve * width_factor
			var y := y_base + y_fraction * _page_size.y
			y += (y_fraction - 0.5) * vertical_bow * curl_curve
			vertices.append(Vector2(x, y))
			uvs.append(Vector2(t if side_sign > 0.0 else 1.0 - t, y_fraction))
			colors.append(Color.WHITE)

	for row in range(ROW_COUNT):
		for column in range(COLUMN_COUNT):
			var current := row * (COLUMN_COUNT + 1) + column
			var next_row := current + COLUMN_COUNT + 1
			indices.append(current)
			indices.append(next_row)
			indices.append(current + 1)
			indices.append(current + 1)
			indices.append(next_row)
			indices.append(next_row + 1)

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	_sheet_mesh.mesh = mesh
