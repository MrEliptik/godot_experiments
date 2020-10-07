var min_x : float
var min_y : float
var max_x : float
var max_y : float

func blob(x, y):
	min_x = x
	min_y = y
	max_x = x
	max_y = y
	
func rect():
	return Rect2(min_x, min_y, max_x-min_x, max_y-min_y)
	
func center():
	return Vector2(rect().position.x + (rect().size.x/2), rect().position.y + (rect().size.y/2))
	
func add(x, y):
	min_x = min(min_x, x)
	min_y = min(min_y, y)
	max_x = max(min_x, x)
	max_y = max(min_y, y)
	
func is_near(x, y):
	var cx = (min_x+max_x) / 2
	var cy = (min_y+max_y) / 2
	
	var d = Vector2(cx, cy).distance_to(Vector2(x, y))
	if d < 25: return true
	else: return false
