-- (c) Copyright 2016, Sean Connelly (@voidqk), http:--syntheti.cc
-- MIT License
-- Project Home: https:--github.com/voidqk/polybooljs
-- Converted to Lua by EgoMoose

--
-- provides the raw computation functions that takes epsilon into account
--
-- zero is defined to be between (-epsilon, epsilon) exclusive
--
local EPSILON = 0.000001
local NEG_EPSILON = -EPSILON

local function point_above_or_on_line(point: vector, left: vector, right: vector): number
	local left_x, left_y = left.x, left.y

	return if (right.x - left_x) * (point.y - left_y) - (right.y - left_y) * (point.x - left_x)
			>= NEG_EPSILON
		then 1
		else -1
end

local function point_between(point: vector, left: vector, right: vector)
	-- p must be collinear with left->right
	-- returns false if p == left, p == right, or left == right
	local d_py_ly = point.y - left.y
	local d_rx_lx = right.x - left.x
	local d_px_lx = point.x - left.x
	local d_ry_ly = right.y - left.y

	local dot = d_px_lx * d_rx_lx + d_py_ly * d_ry_ly
	local sqlen = d_rx_lx * d_rx_lx + d_ry_ly * d_ry_ly
	-- if `dot` is 0, then `p` == `left` or `left` == `right` (reject)
	-- if `dot` is less than 0, then `p` is to the left of `left` (reject)
	-- if dot < EPSILON then
	-- return false
	-- end

	-- if `dot` > `sqlen`, then `p` is to the right of `right` (reject)
	-- therefore, if `dot - sqlen` is greater than 0, then `p` is to the right of `right` (reject)
	-- if dot - sqlen > -EPSILON then
	-- return false
	-- end

	return not ((dot < EPSILON) or (dot - sqlen > NEG_EPSILON))

	-- return true
end

local function points_same(p1: vector, p2: vector): boolean
	return vector.magnitude(p1 - p2) < EPSILON
end

local function points_compare(point1: vector, point2: vector): number
	if vector.magnitude(point1 - point2) <= EPSILON then
		return 0
	end

	if math.abs(point1.x - point2.x) < EPSILON then
		return if point1.y < point2.y then -1 else 1
	end

	return if point1.x < point2.x then -1 else 1
end

local function points_collinear(pt1: vector, pt2: vector, pt3: vector)
	-- does pt1->pt2->pt3 make a straight line?
	-- essentially this is just checking to see if the slope(pt1->pt2) === slope(pt2->pt3)
	-- if slopes are equal, then they must be collinear, because they share pt2
	return math.abs((pt1.x - pt2.x) * (pt2.y - pt3.y) - (pt2.x - pt3.x) * (pt1.y - pt2.y))
		< EPSILON
end

local function lines_intersect(
	a0: vector,
	a1: vector,
	b0: vector,
	b1: vector
): { point: vector, along_a: number, along_b: number } | false
	-- returns false if the lines are coincident (e.g., parallel or on top of each other)
	--
	-- returns an object if the lines intersect:
	--   {
	--     pt: [x, y],    where the intersection point is at
	--     alongA: where intersection point is along A,
	--     alongB: where intersection point is along B
	--   }
	--
	--  alongA and alongB will each be one of: -2, -1, 0, 1, 2
	--
	--  with the following meaning:
	--
	--    -2   intersection point is before segment's first point
	--    -1   intersection point is directly on segment's first point
	--     0   intersection point is between segment's first and second points (exclusive)
	--     1   intersection point is directly on segment's second point
	--     2   intersection point is after segment's second point
	local adx = a1.x - a0.x
	local ady = a1.y - a0.y
	local bdx = b1.x - b0.x
	local bdy = b1.y - b0.y

	local axb = adx * bdy - ady * bdx
	if math.abs(axb) < EPSILON then
		return false
	end

	local dx = a0.x - b0.x
	local dy = a0.y - b0.y

	local a = (bdx * dy - bdy * dx) / axb
	local b = (adx * dy - ady * dx) / axb

	local ret = {
		along_a = 0,
		along_b = 0,
		point = vector.create(a0.x + a * adx, a0.y + a * ady),
	}

	-- categorize where intersection point is along A and B
	if a <= -EPSILON then
		ret.along_a = -2
	elseif a < EPSILON then
		ret.along_a = -1
	elseif a - 1 <= -EPSILON then
		ret.along_a = 0
	elseif a - 1 < EPSILON then
		ret.along_a = 1
	else
		ret.along_a = 2
	end

	if b <= NEG_EPSILON then
		ret.along_b = -2
	elseif b < EPSILON then
		ret.along_b = -1
	elseif b - 1 <= NEG_EPSILON then
		ret.along_b = 0
	elseif b - 1 < EPSILON then
		ret.along_b = 1
	else
		ret.along_b = 2
	end

	return ret
end

return {
	value = EPSILON,

	lines_intersect = lines_intersect,
	points_collinear = points_collinear,
	point_above_or_on_line = point_above_or_on_line,
	points_same = points_same,
	point_between = point_between,

	points_compare = points_compare,
}
