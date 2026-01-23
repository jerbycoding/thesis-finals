# App_Handbook.gd
extends Control

@onready var reader: RichTextLabel = %Reader
@onready var title_label: Label = %TitleLabel
@onready var nav_buttons: VBoxContainer = %NavButtons

var docs: Dictionary = {} # page_id -> HandbookPage
const HANDBOOK_DIR = "res://resources/handbook/"

func _ready():
	_discover_pages()
	_generate_nav_buttons()
	
	# Show default doc
	if docs.has("terminal"):
		_show_doc("terminal")
	elif not docs.is_empty():
		_show_doc(docs.keys()[0])

func _discover_pages():
	print("📘 Handbook: Discovering pages in %s..." % HANDBOOK_DIR)
	docs.clear()
	
	var loaded_pages = FileUtil.load_and_validate_resources(HANDBOOK_DIR, "HandbookPage")
	for res in loaded_pages:
		docs[res.page_id] = res
		print("  - Discovered Page: %s" % res.page_id)
			
	print("📘 Handbook: Library ready: %d pages" % docs.size())

func _generate_nav_buttons():
	# Clear existing hardcoded buttons
	for child in nav_buttons.get_children():
		child.queue_free()
	
	# Create a button for each page
	for page_id in docs:
		var page = docs[page_id]
		var btn = Button.new()
		
		# Try to add an icon based on ID
		var icon = "  📄 "
		match page_id:
			"terminal": icon = "  🐚 "
			"network": icon = "  🕸️ "
			"siem": icon = "  📊 "
			"email": icon = "  ✉ "
			"procedures": icon = "  📜 "
			"incidents": icon = "  🎫 "
			
		btn.text = icon + page.title.capitalize()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		btn.pressed.connect(_show_doc.bind(page_id))
		btn.mouse_entered.connect(func(): if AudioManager: AudioManager.play_ui_hover())
		
		nav_buttons.add_child(btn)

func _show_doc(id: String):
	if not docs.has(id): return
	
	if AudioManager: AudioManager.play_ui_click()
	
	var page = docs[id]
	title_label.text = ":: " + page.title.to_upper() + " ::"
	reader.text = page.content
	
	# Highlight active button
	for child in nav_buttons.get_children():
		if child is Button:
			var is_active = child.text.to_lower().contains(page.title.to_lower())
			if is_active:
				child.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.INFO_BLUE)
			else:
				child.add_theme_color_override("font_color", GlobalConstants.UI_COLORS.TEXT_PRIMARY)