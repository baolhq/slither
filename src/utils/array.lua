local array = {}

function array.slice(list, first, last, step)
    local res = {}

    for i = first, last or #list, step or 1 do
        res[#res + 1] = list[i]
    end

    return res
end

function array.contains(list, pos)
    for _, v in ipairs(list) do
        if v == pos then
            return true
        end
    end
    return false
end

return array
