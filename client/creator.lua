local function Notify(msg, ntype)
    ntype = ntype or 'info'
    if lib and lib.notify then
        lib.notify({ title = 'Stash Creator', description = msg, type = ntype })
    else
        TriggerEvent('chat:addMessage', { args = { 'StashCreator', msg } })
    end
end

RegisterCommand('stashadmin', function()
    TriggerServerEvent('jf-stashcreator:server:requestAdminMenu')
end)

RegisterCommand('createstash', function()
    OpenCreateMenu()
end)

function OpenCreateMenu()
    if not lib then
        Notify('ox_lib not loaded (lib is nil). Check fxmanifest + ensure order.', 'error')
        return
    end

    local input = lib.inputDialog('Create Stash (Details)', {
        { type = 'input', label = 'Stash ID (unique)', required = true },
        { type = 'input', label = 'Display Name', required = true },
        { type = 'number', label = 'Slots', default = 50 },
        { type = 'number', label = 'Weight (kg)', default = 100 },
        { type = 'input', label = 'Password (optional)', password = true },
        { type = 'input', label = 'Required Item (optional)' },
        { type = 'input', label = 'Job (optional)' },
        { type = 'input', label = 'Gang (optional)' },
        { type = 'input', label = 'Citizen ID (optional)' }
    })

    if not input then return end

    local data = {
        stash_id = input[1],
        label = input[2],
        slots = tonumber(input[3]) or 50,
        weight = tonumber(input[4]) or 100,
        password = input[5] or '',
        required_item = input[6] or '',
        job = input[7] or '',
        gang = input[8] or '',
        citizenid = input[9] or ''
    }

    -- Live placement preview + collision check + rotation
    JF_StartPlacement({
        title = 'Create stash: ' .. data.stash_id,
        initialHeading = GetEntityHeading(PlayerPedId()),
        onConfirm = function(coords, heading)
            data.coords = { x = coords.x, y = coords.y, z = coords.z }
            data.heading = heading
            TriggerServerEvent('jf-stashcreator:server:create', data)
        end
    })
end

RegisterNetEvent('jf-stashcreator:client:openAdminMenu', function(stashes)
    if not lib then return end

    local opts = {}
    for _, stash in pairs(stashes or {}) do
        opts[#opts+1] = {
            title = (stash.label or stash.stash_id) .. '  (' .. stash.stash_id .. ')',
            description = 'Edit / Delete / Move',
            onSelect = function()
                OpenEditMenu(stash)
            end
        }
    end

    lib.registerContext({
        id = 'jf_stash_admin',
        title = 'Stash Manager',
        options = opts
    })
    lib.showContext('jf_stash_admin')
end)

function OpenEditMenu(stash)
    if not lib then return end

    lib.registerContext({
        id = 'jf_stash_edit_' .. stash.stash_id,
        title = stash.label or stash.stash_id,
        options = {
            { title = 'Edit details', onSelect = function() EditStash(stash) end },
            { title = 'Move + rotate (live preview)', onSelect = function() MoveStash(stash) end },
            { title = 'Delete', onSelect = function()
                local ok = lib.alertDialog({
                    header = 'Delete stash?',
                    content = 'This cannot be undone.',
                    centered = true,
                    cancel = true
                })
                if ok == 'confirm' then
                    TriggerServerEvent('jf-stashcreator:server:delete', stash.stash_id)
                end
            end}
        }
    })

    lib.showContext('jf_stash_edit_' .. stash.stash_id)
end

function EditStash(stash)
    if not lib then return end

    local input = lib.inputDialog('Edit Stash (Details)', {
        { type = 'input', label = 'Display Name', default = stash.label or '' },
        { type = 'number', label = 'Slots', default = tonumber(stash.slots) or 50 },
        { type = 'number', label = 'Weight (kg)', default = tonumber(stash.weight) or 100 },
        { type = 'input', label = 'Password (optional)', password = true, default = stash.password or '' },
        { type = 'input', label = 'Required Item (optional)', default = stash.required_item or '' },
        { type = 'input', label = 'Job (optional)', default = stash.job or '' },
        { type = 'input', label = 'Gang (optional)', default = stash.gang or '' },
        { type = 'input', label = 'Citizen ID (optional)', default = stash.citizenid or '' },
    })
    if not input then return end

    TriggerServerEvent('jf-stashcreator:server:update', stash.stash_id, {
        label = input[1] or stash.label,
        slots = tonumber(input[2]) or stash.slots,
        weight = tonumber(input[3]) or stash.weight,
        password = input[4] or '',
        required_item = input[5] or '',
        job = input[6] or '',
        gang = input[7] or '',
        citizenid = input[8] or ''
    })
end

function MoveStash(stash)
    -- Use existing heading if present
    local initial = tonumber(stash.heading) or 0.0

    JF_StartPlacement({
        title = 'Move stash: ' .. stash.stash_id,
        initialHeading = initial,
        onConfirm = function(coords, heading)
            TriggerServerEvent('jf-stashcreator:server:move', stash.stash_id, {
                x = coords.x, y = coords.y, z = coords.z
            }, heading)
        end
    })
end

RegisterNetEvent('jf-stashcreator:client:notify', function(msg, ntype)
    Notify(msg, ntype)
end)

CreateThread(function()
    Wait(500) -- wait so F8 console is ready

    print([[
^5     _  _____       ____ _____ ____  ____  _     ____  ____  _____ ____ _____ ____  ____  
^5    / |/    /      / ___Y__ __Y  _ \/ ___\/ \ /|/   _\/  __\/  __//  _ Y__ __Y  _ \/  __\ 
^5    | ||  __\_____ |    \ / \ | / \||    \| |_|||  /  |  \/||  \  | / \| / \ | / \||  \/|
^5 /\_| || |   \____\___ | | | | |-||\___ || | |||  \__|    /|  /_ | |-|| | | | \_/||    /
^5 \____/\_/         \____/ \_/ \_/ \|\____/\_/ \|\____/\_/\_\\____\\_/ \| \_/ \____/\_/\_\
^7                 Client Side initialised
^7                    version 1.0.0
]])
end)
