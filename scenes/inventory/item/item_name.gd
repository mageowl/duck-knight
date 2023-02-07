class_name ItemName

const NAMES : Array[String] = [
	"vandolf",
	"alaesya",
	"grud",
	"smak",
	"evan",
	"moldyvort",
	"harry",
	"monsterkiller",
	"draan",
	"quarion",
	"biscut",
	"air monk",
	"deathslayer",
	"satin",
	"kat",
	"arphodite",
	"zues",
	"hermes",
	"hades",
	"posidon",
	"percy",
	"nobody",
	"ignus",
	"mageman"
]

const TITLES : Array[String] = [
	"the epic",
	"of neverwinter",
	"the great",
	"the worldshaper",
	"the cat",
	"the dog",
	"the black",
	"the white",
	"the gray",
	"duckeater",
	"the duck knight",
	"the knight",
	"the wise",
	"the very wise",
	"the extra wise",
	"the strong",
	"the magical",
	"of power",
	"of speed",
	"of magic",
	"of kingdom 38"
]

var segments : Array[NameSegment] = []

func _init(type: ItemType, item_trait: ItemTrait, string: String = ""):
	if string != "":
		segments.push_back(NameSegment.of(string))
		return
	
	if randf() > 0.8:
		segments.push_back(NameSegment.new(NAMES))
		
		if randf() > 0.6 * 0.8: # its already greater than 8, so check more
			segments.push_back(NameSegment.new(TITLES))
		
		segments.push_back(NameSegment.of("'s"))
	
	randomize()
	var post_ajective = randf() > 0.5
	
	if not post_ajective: segments.push_back(NameSegment.new(item_trait.adjectives))
	segments.push_back(NameSegment.new(type.names))
	if post_ajective: segments.push_back(NameSegment.new(item_trait.post_adjectives))

func as_string() -> String:
	if segments.size() > 1:
		var string = ""
		for segment in segments:
			string += segment.string
		
		return string.trim_prefix(" ")
	elif segments.size() == 1: return segments[0].string
	else: return ""

class NameSegment:
	var string := ""
	var type := Type.EMPTY
	
	enum Type {
		EMPTY,
		STRING,
		ARRAY
	}
	
	static func empty():
		return NameSegment.new([], Type.EMPTY)
	
	static func of(str: String):
		return NameSegment.new([str], Type.STRING)
	
	func _init(array: Array, segment_type := Type.ARRAY):
		randomize()
		
		type = segment_type
		if  type == Type.STRING: string = array[0]
		elif type == Type.ARRAY: string = " " + array.pick_random()
		elif type == Type.EMPTY: string = ""
		else: string = "..."
