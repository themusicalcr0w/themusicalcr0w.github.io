# Representative excerpt from Scripts/PokePet.gd
# Runtime slicing of a 4x4 sprite sheet into independent per-pet animations.

func _update_sprite_texture() -> void:
	if not animated_sprite:
		return

	
	
	
	var filename := "%s.png" % emote.pokemon
	var path := "%s%s" % [emote.MON_DIR, filename]


	if not ResourceLoader.exists(path):
		push_warning("Missing sprite sheet: %s" % path)
		return

	var tex: Texture2D = load(path)
	if not tex:
		return


	# Duplicate SpriteFrames so each pet has instance
	var frames: SpriteFrames = animated_sprite.sprite_frames.duplicate(true)
	animated_sprite.sprite_frames = frames


	# spritesheet is 4x4 (16 frames)
	var frame_size = Vector2i(
		int(float(tex.get_width()) / 4.0),
		int(float(tex.get_height()) / 4.0)
	)


	var anim_map = {
		"idle_forward": 0, # top row
		"idle_left": 1,    # 2nd row
		"idle_right": 2,   # 3rd row
		"idle_rear": 3     # bottom row
	}



	
	for anim_name in anim_map.keys():
		var row = anim_map[anim_name]
		if not frames.has_animation(anim_name):
			frames.add_animation(anim_name)



		frames.clear(anim_name)
		for col in range(4):
			var region = Rect2(col * frame_size.x, row * frame_size.y, frame_size.x, frame_size.y)
			var atlas_tex = AtlasTexture.new()
			atlas_tex.atlas = tex
			atlas_tex.region = region
			frames.add_frame(anim_name, atlas_tex)








