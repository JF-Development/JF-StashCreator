local Zones = {}

local function dbg(...)
    if Config and Config.Debug then
        local parts = {}
        for i = 1, select('#', ...) do parts[#parts+1] = tostring(select(i, ...)) end
        print('[jf-stashcreator][TARGET]', table.concat(parts, ' '))
    end
end

local function ClearTargets()
    if not Config.Target.enabled then return end
    dbg('Clearing targets. Count:', #Zones)

    if GetResourceState('ox_target') == 'started' then
        for _, zid in pairs(Zones) do
            pcall(function() exports.ox_target:removeZone(zid) end)
        end
    end

    if GetResourceState('qb-target') == 'started' then
        for _, zoneName in pairs(Zones) do
            pcall(function() exports['qb-target']:RemoveZone(zoneName) end)
        end
    end

    Zones = {}
end

local function AskPasswordIfNeeded(stash)
    if not Config.Password.enabled then return '' end
    if not stash.password or stash.password == '' then return '' end
    if not lib then return nil end

    local input = lib.inputDialog('Password Required', {
        { type = 'input', label = 'Enter password', password = true, required = true }
    })
    if not input then return nil end
    return input[1]
end

function AttemptOpenStash(stash)
    local entered = AskPasswordIfNeeded(stash)
    if entered == nil then
        if lib then lib.notify({ description = 'Cancelled', type = 'error' }) end
        return
    end
    TriggerServerEvent('jf-stashcreator:server:open', stash.stash_id, entered or '')
end

local function AddTargetForStash(stash)
    local coords = type(stash.coords) == 'string' and json.decode(stash.coords) or stash.coords
    if not coords then dbg('No coords for', stash.stash_id); return end

    local mode = (Config.Target and Config.Target.mode) or 'auto'
    local useOx = (mode == 'ox_target') or (mode == 'auto' and GetResourceState('ox_target') == 'started')
    local useQb = (mode == 'qb-target') or (mode == 'auto' and not useOx and GetResourceState('qb-target') == 'started')

    if useOx then
        local id = exports.ox_target:addSphereZone({
            coords = vec3(coords.x, coords.y, coords.z),
            radius = (Config.Target and Config.Target.radius) or 1.5,
            options = {{
                label = stash.label or stash.stash_id,
                icon = 'fa-solid fa-box',
                onSelect = function()
                    AttemptOpenStash(stash)
                end
            }}
        })
        Zones[#Zones+1] = id
        return
    end

    if useQb then
        local zoneName = 'jf_stash_' .. stash.stash_id
        exports['qb-target']:AddCircleZone(
            zoneName,
            vector3(coords.x, coords.y, coords.z),
            (Config.Target and Config.Target.radius) or 1.5,
            { name = zoneName, debugPoly = false },
            {
                options = {{
                    label = stash.label or stash.stash_id,
                    action = function()
                        AttemptOpenStash(stash)
                    end
                }},
                distance = (Config.Target and Config.Target.distance) or 2.0
            }
        )
        Zones[#Zones+1] = zoneName
        return
    end
end

local function LoadStashes()
    if not Config.Target.enabled then return end

    if lib and lib.callback and lib.callback.await then
        local stashes = lib.callback.await('jf-stashcreator:server:getStashes', false)
        ClearTargets()
        for _, stash in pairs(stashes or {}) do
            AddTargetForStash(stash)
        end
        return
    end

    TriggerServerEvent('jf-stashcreator:server:getStashes_fallback')
end

RegisterNetEvent('jf-stashcreator:client:stashes_fallback', function(stashes)
    ClearTargets()
    for _, stash in pairs(stashes or {}) do
        AddTargetForStash(stash)
    end
end)

RegisterNetEvent('jf-stashcreator:client:refreshTargets', function()
    LoadStashes()
end)

CreateThread(function()
    Wait(2000)
    LoadStashes()
end)
