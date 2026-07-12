extends RefCounted

var failures: Array[String] = []


func expect_true(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)


func expect_equal(actual, expected, message: String) -> void:
	if actual != expected:
		failures.append("%s (expected=%s, actual=%s)" % [message, str(expected), str(actual)])


func finish(tree: SceneTree, test_name: String) -> void:
	if failures.is_empty():
		print("PASS %s" % test_name)
		tree.quit(0)
		return
	for failure in failures:
		push_error("%s: %s" % [test_name, failure])
	tree.quit(1)
