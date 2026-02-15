extends GdUnitTestSuite

func test_monitor_structure():
	var monitor = load("res://scenes/3d/props/graybox/Prop_Monitor.tscn").instantiate()
	var viewport = monitor.get_node_or_null("SubViewport")
	var desktop = monitor.get_node_or_null("SubViewport/AmbientDesktop")
	
	assert_that(viewport).is_not_null()
	assert_that(desktop).is_not_null()
	
	monitor.free()
