# tests/unit/DialogueManagerTest.gd
extends "res://addons/gdUnit4/src/GdUnitTestSuite.gd"

# This test suite is for the DialogueManager autoload singleton.

func test_singleton_is_initialized_correctly():
	# The DialogueManager is an autoload, so it should exist and be configured.
	assert_object(DialogueManager).is_not_null()
	
	# The dialogue_box_instance should be created and added to the root tree in _ready()
	assert_object(DialogueManager.dialogue_box_instance).is_not_null()
	assert_bool(DialogueManager.dialogue_box_instance.is_inside_tree()).is_true()
	assert_object(DialogueManager.dialogue_box_instance.get_parent()).is_same(get_tree().root)

# More complex tests would require mocking NPCs and scenes to test the full
# start_dialogue and _close_dialogue_session logic. For this initial setup,
# we are just verifying that the singleton initializes its components as expected.
