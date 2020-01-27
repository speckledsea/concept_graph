tool
extends GraphNode

class_name ConceptNode


signal delete_node
signal node_changed

var _cache := {}
var _resize_timer := Timer.new()


func _ready() -> void:
	if not has_custom_gui():
		title = get_node_name()
		resizable = true
		show_close = true

	_resize_timer.one_shot = true
	_resize_timer.autostart = false
	add_child(_resize_timer)

	_connect_signals()


func has_custom_gui() -> bool:
	return false


func get_node_name() -> String:
	return "ConceptNode"


func get_category() -> String:
	return "No category"


func get_description() -> String:
	return "A brief description of the node functionality"


func get_output(idx: int):
	"""
	Returns what the node generates for a give slot
	This method ensure the output is not calculated more than one time per run. It's useful if the
	output node is connected to more than one node. It ensure the results are the same and save
	some performance
	"""
	if _cache.has(idx):
		return _cache[idx]
	_cache[idx] = _generate_output(idx)
	return _cache[idx]


func reset() -> void:
	"""
	Invalidate the cache to force the node to recalculate its output. This method is called
	when something changed earlier in the graph.
	"""
	_cache = {}
	# TODO : for each node connected on the right -> reset


func export_editor_data() -> Dictionary:
	var data = {}
	data["offset_x"] = offset.x
	data["offset_y"] = offset.y

	if resizable:
		data["rect_x"] = rect_size.x
		data["rect_y"] = rect_size.y

	return data


func restore_editor_data(data: Dictionary) -> void:
	offset.x = data["offset_x"]
	offset.y = data["offset_y"]

	if data.has("rect_x"):
		rect_size.x = data["rect_x"]
	if data.has("rect_y"):
		rect_size.x = data["rect_y"]


func export_custom_data() -> Dictionary:
	"""
	Because we're saving the tree to a json file, we need each node to explicitely specify the data
	to save. It's also the node responsability to restore it when we load the file. Most nodes
	won't need this but it could be useful for nodes that allows the user to type in raw values
	directly if nothing is connected to a slot.
	"""
	return {}


func restore_custom_data(data: Dictionary) -> void:
	"""
	This method get exactly what it exported from the export_custom_data method. Use it to manually
	restore the previous node state.
	"""
	pass


func get_node_connected_to_left(idx: int) -> ConceptNode:
	return null


func _generate_output(idx: int):
	"""
	Overide this function in the derived classes to return something usable
	"""
	return null


func _connect_signals() -> void:
	self.connect("close_request", self, "_on_close_request")
	self.connect("resize_request", self, "_on_resize_request")
	_resize_timer.connect("timeout", self, "_on_resize_timeout")


func _on_resize_request(new_size) -> void:
	rect_size = new_size
	_resize_timer.start(2.0)


func _on_resize_timeout() -> void:
	emit_signal("node_changed")


func _on_close_request() -> void:
	emit_signal("delete_node", self)

