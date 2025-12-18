
local function dbg(...)
    if Config and Config.Debug then
        local t = {}
        for i = 1, select('#', ...) do
            t[#t+1] = tostring(select(i, ...))
        end
        print('[jf-stashcreator][SERVER]', table.concat(t, ' '))
    end
end

local function RegisterStash(stash)
    if Config.Inventory.system ~= 'ox_inventory' then return end
    if GetResourceState('ox_inventory') ~= 'started' then return end

    exports.ox_inventory:RegisterStash(
        stash.stash_id,
        stash.label or stash.stash_id,
        tonumber(stash.slots) or 50,
        (tonumber(stash.weight) or 100) * 1000
    )

    dbg('Registered stash:', stash.stash_id)
end


local function HasAccess(src, stash)
    if stash.job and stash.job ~= '' then
        if GetPlayerJob(src) ~= stash.job then
            return false, 'Wrong job'
        end
    end

    if stash.gang and stash.gang ~= '' then
        if GetPlayerGang(src) ~= stash.gang then
            return false, 'Wrong gang'
        end
    end

    if stash.citizenid and stash.citizenid ~= '' then
        if GetCitizenId(src) ~= stash.citizenid then
            return false, 'Wrong citizen ID'
        end
    end

    if Config.RequiredItem.enabled and stash.required_item and stash.required_item ~= '' then
        if not HasItem(src, stash.required_item) then
            return false, 'Missing required item'
        end
    end

    return true
end


lib.callback.register('jf-stashcreator:server:getStashes', function(_)
    dbg('Callback getStashes')
    return DB_GetAllStashes()
end)


RegisterNetEvent('jf-stashcreator:server:requestAdminMenu', function()
    local src = source
    if not IsAdmin(src) then return end

    TriggerClientEvent(
        'jf-stashcreator:client:openAdminMenu',
        src,
        DB_GetAllStashes()
    )
end)


RegisterNetEvent('jf-stashcreator:server:create', function(data)
    local src = source
    if not IsAdmin(src) then return end
    if not data or not data.stash_id or not data.coords then return end

    dbg('Creating stash', data.stash_id, 'by', src)

    local ok, err = pcall(function()
        DB_SaveStash(data)
        RegisterStash(data)
    end)

    if not ok then
        dbg('Create stash failed:', err)
        TriggerClientEvent(
            'jf-stashcreator:client:notify',
            src,
            'Failed to create stash (check server console)',
            'error'
        )
        return
    end

    TriggerClientEvent('jf-stashcreator:client:notify', src, 'Stash created', 'success')
    TriggerClientEvent('jf-stashcreator:client:refreshTargets', -1)
end)


RegisterNetEvent('jf-stashcreator:server:update', function(stashId, data)
    local src = source
    if not IsAdmin(src) then return end
    if not stashId or not data then return end

    dbg('Updating stash', stashId)

    DB_UpdateStash(stashId, data)
    TriggerClientEvent('jf-stashcreator:client:notify', src, 'Stash updated', 'success')
    TriggerClientEvent('jf-stashcreator:client:refreshTargets', -1)
end)


RegisterNetEvent('jf-stashcreator:server:move', function(stashId, coords, heading)
    local src = source
    if not IsAdmin(src) then return end
    if not stashId or not coords then return end

    dbg('Moving stash', stashId)

    DB_MoveStash(stashId, coords, heading)
    TriggerClientEvent('jf-stashcreator:client:notify', src, 'Stash moved', 'success')
    TriggerClientEvent('jf-stashcreator:client:refreshTargets', -1)
end)


RegisterNetEvent('jf-stashcreator:server:delete', function(stashId)
    local src = source
    if not IsAdmin(src) then return end
    if not stashId then return end

    dbg('Deleting stash', stashId)

    DB_DeleteStash(stashId)
    TriggerClientEvent('jf-stashcreator:client:notify', src, 'Stash deleted', 'success')
    TriggerClientEvent('jf-stashcreator:client:refreshTargets', -1)
end)


RegisterNetEvent('jf-stashcreator:server:open', function(stashId, enteredPassword)
    local src = source
    if not stashId then return end

    local stash = DB_GetStashById(stashId)
    if not stash then
        dbg('Stash not found:', stashId)
        return
    end

    local allowed, reason = HasAccess(src, stash)
    if not allowed then
        TriggerClientEvent(
            'jf-stashcreator:client:notify',
            src,
            'Access denied: ' .. (reason or ''),
            'error'
        )
        return
    end

    if Config.Password.enabled and stash.password and stash.password ~= '' then
        if tostring(enteredPassword or '') ~= tostring(stash.password) then
            TriggerClientEvent(
                'jf-stashcreator:client:notify',
                src,
                'Wrong password',
                'error'
            )
            return
        end
    end

   
    TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stashId)
    dbg('Opened stash', stashId, 'for', src)
end)


CreateThread(function()
    Wait(2000)
    local stashes = DB_GetAllStashes()
    dbg('Startup registering stashes:', stashes and #stashes or 0)

    for _, stash in pairs(stashes or {}) do
        RegisterStash(stash)
    end
end)

CreateThread(function()
    print([[
^5     _  _____       ____ _____ ____  ____  _     ____  ____  _____ ____ _____ ____  ____  
^5    / |/    /      / ___Y__ __Y  _ \/ ___\/ \ /|/   _\/  __\/  __//  _ Y__ __Y  _ \/  __\ 
^5    | ||  __\_____ |    \ / \ | / \||    \| |_|||  /  |  \/||  \  | / \| / \ | / \||  \/|
^5 /\_| || |   \____\___ | | | | |-||\___ || | |||  \__|    /|  /_ | |-|| | | | \_/||    /
^5 \____/\_/         \____/ \_/ \_/ \|\____/\_/ \|\____/\_/\_\\____\\_/ \| \_/ \____/\_/\_\
^7					Server Side initialised
^7						version 1.0.0
]])
end)
