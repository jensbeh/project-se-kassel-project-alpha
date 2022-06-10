extends Node


func post_import(scene):
	print(scene)
	var testObject = scene.find_node("test")
	for child in testObject.get_children():
		if "test_door" in child.name:
			var selected_door_sprite = child.get_meta("selected_door_sprite")
			print(selected_door_sprite)
			
			# possible slected doors = 1,2,3,4,6,7,8,9,11,12,13,14,16,17,18,19,24,29
			var frame = selected_door_sprite * 4 - 4
			
			var sprite = Sprite.new()
			sprite.name = "sprite"
			sprite.centered = false			
			sprite.texture = load("res://assets/tilesets/Village Animated Doors.png")
			sprite.hframes = 20
			sprite.vframes = 8
			sprite.frame = frame
			
			child.add_child(sprite)
			sprite.set_owner(scene)
			
			var animationPlayer = AnimationPlayer.new()
			animationPlayer.name = "animationPlayer"
			var path = sprite.name + ":frame"

			var openDoorAnimation = Animation.new()
			animationPlayer.add_animation( "openDoor", openDoorAnimation)
			openDoorAnimation.add_track(0)
			openDoorAnimation.length = 0.4
			openDoorAnimation.track_set_path(0, path)
			openDoorAnimation.track_insert_key(0, 0.0, frame)
			openDoorAnimation.track_insert_key(0, 0.1, frame + 1)
			openDoorAnimation.track_insert_key(0, 0.2, frame + 2)
			openDoorAnimation.track_insert_key(0, 0.3, frame + 3)
			openDoorAnimation.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
			openDoorAnimation.loop = 0

			var closeDoorAnimation = Animation.new()
			animationPlayer.add_animation( "closeDoor", closeDoorAnimation)
			closeDoorAnimation.add_track(0)
			closeDoorAnimation.length = 0.4
			closeDoorAnimation.track_set_path(0, path)
			closeDoorAnimation.track_insert_key(0, 0.0, frame + 3)
			closeDoorAnimation.track_insert_key(0, 0.1, frame + 2)
			closeDoorAnimation.track_insert_key(0, 0.2, frame + 1)
			closeDoorAnimation.track_insert_key(0, 0.3, frame + 0)
			closeDoorAnimation.value_track_set_update_mode(0, Animation.UPDATE_DISCRETE)
			closeDoorAnimation.loop = 0

			child.add_child(animationPlayer)
			animationPlayer.set_owner(scene)
			print("added AnimationPlayer")

	print("End")
	return scene
