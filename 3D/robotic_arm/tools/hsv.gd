class HSV:
	var h: float
	var s: float
	var v: float
	
	func distance_to(hsv_color: HSV):
		return Vector3(h, s, v).distance_to(Vector3(hsv_color.h, hsv_color.s, hsv_color.v))
		
	func from_RGB(color_rgb: Color):
		var _min
		var _max
		var _delta
		
		_min = color_rgb.r if color_rgb.r < color_rgb.g else color_rgb.g 
		_min = _min if _min < color_rgb.b else color_rgb.b
		
		_max = color_rgb.r if color_rgb.r > color_rgb.g else color_rgb.g 
		_max = _max if _max > color_rgb.b else color_rgb.b
		
		self.v = _max
		_delta = _max - _min
		if (_delta < 0.00001):
			self.s = 0
			self.h = 0
			return
		if _max > 0.0:
			self.s = _delta / _max
		else:
			self.s = 0.0
			self.h = NAN
			return
		if color_rgb.r >= _max:
			self.h = (color_rgb.g - color_rgb.b) / _delta
		elif color_rgb.g >= _max:
			self.h = 2.0 + (color_rgb.b - color_rgb.r) / _delta
		else:
			self.h = 4.0 + (color_rgb.r - color_rgb.g) / _delta
			
		self.h *= 60.0
		
		if self.h < 0.0:
			self.h += 360.0


static func RGB_to_HSV(color_rgb: Color) -> HSV:
	var hsv = HSV.new()
	var _min
	var _max
	var _delta

	_min = color_rgb.r if color_rgb.r < color_rgb.g else color_rgb.g 
	_min = _min if _min < color_rgb.b else color_rgb.b

	_max = color_rgb.r if color_rgb.r > color_rgb.g else color_rgb.g 
	_max = _max if _max > color_rgb.b else color_rgb.b

	hsv.v = _max
	_delta = _max - _min
	if (_delta < 0.00001):
		hsv.s = 0
		hsv.h = 0
		return hsv
	if _max > 0.0:
		hsv.s = _delta / _max
	else:
		hsv.s = 0.0
		hsv.h = NAN
		return hsv
	if color_rgb.r >= _max:
		hsv.h = (color_rgb.g - color_rgb.b) / _delta
	elif color_rgb.g >= _max:
		hsv.h = 2.0 + (color_rgb.b - color_rgb.r) / _delta
	else:
		hsv.h = 4.0 + (color_rgb.r - color_rgb.g) / _delta

	hsv.h *= 60.0

	if hsv.h < 0.0:
		hsv.h += 360.0

	return hsv
