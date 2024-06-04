-- Licensed under the GPL3 or later versions of the GPL license.
-- See the LICENSE file in the project root for more information.

local function table_dump(tbl, seen)
	if type(tbl) == "table" then
		seen = seen or {}

		if seen[tbl] then
			return "<circular reference>"
		end

		seen[tbl] = true

		local s = "{ "
		local first = true

		for k, v in pairs(tbl) do
			if not first then
				s = s .. ", "
			end
			first = false

			local key = k
			if type(k) ~= "number" then
				key = '"' .. k .. '"'
			end

			s = s .. key .. " = " .. table_dump(v, seen)
		end

		return s .. " }"
	else
		return tostring(tbl)
	end
end

local function table_copy(tbl, seen)
	if type(tbl) ~= "table" then
		return tbl
	end

	if seen and seen[tbl] then
		return seen[tbl]
	end

	local s = seen or {}
	local out = {}

	s[tbl] = out

	for k, v in pairs(tbl) do
		out[table_copy(k, s)] = table_copy(v, s)
	end

	return out
end

local a = { 1, { "a", "b" }, 2 }
a[2][3] = a
local a_copy = table_copy(a)
a_copy[2][1] = "X"

print("Original: " .. table_dump(a))
print("Copy:     " .. table_dump(a_copy))

-- Original: { 1 = 1, 2 = { 1 = a, 2 = b, 3 = <circular reference> }, 3 = 2 }
-- Copy:     { 1 = 1, 2 = { 1 = X, 2 = b, 3 = <circular reference> }, 3 = 2 }
