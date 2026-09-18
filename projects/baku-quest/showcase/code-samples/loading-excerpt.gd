# Source: Scripts/World/Suburban/SuburbanStaticBatcher.gd
# Selected source; requires the surrounding project.

func _yield_budget() -> void:
	if _cooperative and Time.get_ticks_usec()-_slice_started>6000:
		await get_tree().process_frame
		_slice_started=Time.get_ticks_usec()

func _collect_budgeted(root_node:Node)->void:
	var pending:Array[Node]=[root_node]
	while not pending.is_empty():
		var node:Node=pending.pop_back()
		if _collect_one(node):
			var children:=node.get_children()
			children.reverse()
			pending.append_array(children)
		await _yield_budget()

# Excerpt from _ready(): dispatch the prepared geometry job.
		var result:Array=[]
		var build:=func():result.append(preload("res://Scripts/World/Suburban/StaticGeometryMerge.gd").build(records,material,flags))
		if _cooperative:
			var task:=WorkerThreadPool.add_task(build)
			while not WorkerThreadPool.is_task_completed(task):await get_tree().process_frame
			WorkerThreadPool.wait_for_task_completion(task)
		else:build.call()
		var importer:ImporterMesh=result[0]
