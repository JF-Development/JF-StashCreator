local function _dbg(prefix, ...)
    local parts = {}
    for i = 1, select('#', ...) do parts[#parts+1] = tostring(select(i, ...)) end
    print(prefix .. ' ' .. table.concat(parts, ' '))
end

function JF_Debug(...)
    if not Config or not Config.Debug then return end
    _dbg('[jf-stashcreator][DEBUG]', ...)
end
