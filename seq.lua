local seq = {}

local function callback_or_iterator(iter, state, f)
    if f then
        while true do
            local vals = {iter()}
            if vals[1] then
                f((table.unpack or unpack)(vals))
            else
                break
            end
        end
    else
        return iter, state
    end
end

-- any?
function seq.any(t, f)
    if f then
        for i = 1, #t do
            if f(t[i]) then
                return true
            end
        end
        return false
    else
        return t[1] ~= nil
    end
end

-- one?
function seq.one(t, f)
    if f then
        local seen = false
        for i = 1, #t do
            if f(t[i]) then
                if seen then
                    return false
                else
                    seen = true
                end
            end
        end
        return seen
    else
        return t[1] ~= nil and t[2] == nil
    end
end

-- push!
function seq.push(t, ...)
    local n = select('#', ...)
    for i = 1, n do
        t[#t+1] = select(i, ...)
    end
end

-- pop!
function seq.pop(t, n)
    if n == nil then
        return table.remove(t)
    else
        local result = {}
        for i = 1, math.min(n, #t) do
            result[n - i + 1] = table.remove(t)
        end
        return result
    end
end

-- contains
function seq.contains(t, v)
    for i = 1, #t do
        if t[i] == v then
            return true
        end
    end
    return false
end

-- assoc
function seq.assoc(t, elem, key)
    if key == nil then
        key = 1
    end
    for i = 1, #t do
        if elem == t[i][key] then
            return t[i]
        end
    end
end

-- rassoc
function seq.rassoc(t, elem)
    return seq.assoc(t, elem, 2)
end

-- seq? (expensive)

-- bsearch
-- returns i if found
-- returns nil, i if not found
function seq.bsearch_index(t, x)
    local low = 1
    local high = #t
    while low <= high do
        local mid = math.floor((high + low) / 2)
        if x == t[mid] then
            return mid
        elseif x < t[mid] then
            high = mid - 1
        else
            low = mid + 1
        end
    end
    return nil, low
end

-- clear
function seq.clear(t)
    for i = 1, #t do
        t[i] = nil
    end
end

-- concat
function seq.concat(t)
    local result = {}
    for i = 1, #t do
        for j = 1, #t[i] do
            result[#result+1] = t[i][j]
        end
    end
    return result
end

-- map
function seq.map(t, f)
    if type(t) == 'function' then
        t, f = f, t
    end
    local result = {}
    for i = 1, #t do
        result[i] = f(t[i])
    end
    return result
end

-- each
local function each_iter(s)
    local result = s.t[s.i]
    s.i = s.i + 1
    return result
end
function seq.each(t, f)
    callback_or_iterator(each_iter, {i = 1, t = t}, f)
end

-- each_index
local function each_index_iter(s)
    local result1, result2 = s.t[s.i], s.i
    s.i = s.i + 1
    return result1, result2
end
function seq.each_index(t, f)
    callback_or_iterator(each_index_iter, {i = 1, t = t}, f)
end

-- combination
-- repeated_combination
-- permutation
-- repeated_permutation

-- compact (expensive)
function seq.compact(t)
    local intermediate = {}
    for k, v in pairs(t) do
        if type(k) == 'number' and math.floor(k) == k then
            intermediate[#intermediate+1] = {k, v}
        end
    end
    seq.sort_by(intermediate, seq.first)
    return seq.map(intermediate, seq.last)
end

-- count/len/size
-- cycle
-- delete
-- delete_at
-- delete_if / reject
-- filter / select / find_all

-- is_empty
function seq.is_empty(t)
    return #t == 0
end

-- is_eql
function seq.is_eql(t1, t2)
    if #t1 ~= #t2 then
        return false
    end
    for i = 1, #t1 do
        if t1[i] ~= t2[i] then
            return false
        end
    end
    return true
end

-- drop (from front, immut)
-- drop_while
-- fill (check docs)
-- index / rindex
-- first
-- last


-- flatten
local function flatten_helper(t, result, depth)
    for i = 1, #t do
        if depth ~= 0 and type(t[i]) == "table" then
            flatten_helper(t, result, depth - 1)
        else
            result[#result+1] = t[i]
        end
    end
end
function seq.flatten(t, depth)
    depth = depth or -1
    local result = {}
    flatten_helper(t, result, depth)
    return result
end

-- inspect / tostring
-- intersect?
-- join
-- keep_if
-- max
-- min
-- minmax
-- product
-- shift / shift_while
-- unshift/prepend
-- reverse
-- reverse_each
-- reverse_each_index
-- rotate
-- sample / shuffle
-- slice
-- sort / sort_by
-- sum
-- take
-- take_while
-- transpose

-- union
-- intersection
-- difference

-- uniq
function seq.uniq(t)
    local result = {}
    local seen = {}
    for i = 1, #t do
        if not seen[t[i]] then
            seen[t[i]] = true
            result[#result+1] = t[i]
        end
    end
    return result
end

-- values_at
function seq.values_at(t, indices)
    local result = {}
    for i = 1, #indices do
        result[#result+1] = t[indices[i]]
    end
end

-- zip





return seq
