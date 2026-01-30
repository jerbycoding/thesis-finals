# App_Handbook.gd
extends Control

@onready var reader: RichTextLabel = %Reader
@onready var title_label: Label = %TitleLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer

var docs: Dictionary = {} # page_id -> HandbookPage
const HANDBOOK_DIR = "res://resources/handbook/"

func _ready():
	_discover_pages()
	_build_full_document()

func _discover_pages():
	print("📘 Handbook: Discovering pages in %s..." % HANDBOOK_DIR)
	docs.clear()
	
	var loaded_pages = FileUtil.load_and_validate_resources(HANDBOOK_DIR, "HandbookPage")
	# Order them logically
	var preferred_order = ["procedures", "terminal", "network", "siem", "email", "incidents"]
	
	for key in preferred_order:
		for res in loaded_pages:
			if res.page_id == key:
				docs[res.page_id] = res
				
	# Add any outliers
	for res in loaded_pages:
		if not docs.has(res.page_id):
			docs[res.page_id] = res

func _build_full_document():
	var full_text = ""
	var separator = "\n\n[center][color=#cccccc]__________________________________________________[/color][/center]\n\n"
	
	for page_id in docs:
		var page = docs[page_id]
		full_text += "[b][font_size=24]" + page.title.to_upper() + "[/font_size][/b]\n"
		full_text += "[color=#666666][i]Document ID: REF-" + page_id.to_upper() + "-v4.4[/i][/color]\n\n"
		full_text += page.content
		full_text += separator
		
	reader.text = full_text
	print("📘 Handbook: Integrated %d pages into full document." % docs.size())
