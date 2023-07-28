extends LineEdit

func _ready():
	text = str(CacheManager.bytes_to_mb(CacheManager.cache_size_limit))

func _on_text_changed(new_text):
	var txt : String = new_text as String
	
	if txt.length() >= 6:
		txt = txt.substr(0, 6)
	
	for character in txt:
		if not str_to_var(character) is int:
			var i = txt.find(character)
			if i == txt.length() - 1:
				txt = txt.substr(0, txt.length() - 1)
			else:
				txt = txt.substr(0, i) + txt.substr(i + 1)
	
	text = ""
	insert_text_at_caret(txt)
	
	if not txt.is_empty():
		Preferences.write_pref("cache size", str_to_var(txt))
		CacheManager.cache_size_limit = CacheManager.mb_to_bytes(str_to_var(txt))
