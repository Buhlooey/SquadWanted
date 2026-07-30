extends RichTextLabel

var sectionCompleteStrings: Array[String] = [
	"GOT 'EM!",
	"GOOD EYE!",
	"#SNIPED",
	"EZ"
]

func showSectionComplete() -> void:
	setText(sectionCompleteStrings.pick_random())
	show()

func setText(newText: String) -> void:
	text = str("[center]", newText)