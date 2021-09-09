static func getRandomInt(max_value):
	randomize()
	return randi() % max_value

static func randomBytes(n):
	var r = []
	for index in range(0, n):
		r.append(getRandomInt(256))
	return r

static func uuidbin():
	var b = randomBytes(16)
	
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return b

static func generate_uuid_v4():
	var b = uuidbin()
	
	var low = '%02x%02x%02x%02x' % [b[0], b[1], b[2], b[3]]
	var mid = '%02x%02x' % [b[4], b[5]]
	var hi = '%02x%02x' % [b[6], b[7]]
	var clock = '%02x%02x' % [b[8], b[9]]
	var node = '%02x%02x%02x%02x%02x%02x' % [b[10], b[11], b[12], b[13], b[14], b[15]]
	return '%s-%s-%s-%s-%s' % [low, mid, hi, clock, node]
	
	
# argument must be of type string!
static func is_uuid(test_string):
	# if length of string is 36 and contains exactly 4 dashes, it's a UUID
	return test_string.length() == 36 and test_string.count("-") == 4


# MIT License

# Copyright (c) 2018 Xavier Sellier

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
