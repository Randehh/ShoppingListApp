-----------------------------------------------------------------------------------------
--
-- Useful methods
--
-----------------------------------------------------------------------------------------

function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function tablelength(T) --Count the table length
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function copy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else
        copy = orig
    end
    return copy
end

function setContains(set, key)
    return set[key] ~= nil
end

function getIndexFromList(list, object)
    for i=0,#list do
        if list[i] == object then
            return i
        end
    end
    return -1
end