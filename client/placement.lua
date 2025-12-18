
local isPlacing = false
local placingHeading = 0.0
local placingZOffset = 0.0
local placingPayload = nil


local function notify(msg, ntype)
    ntype = ntype or 'info'
    if lib and lib.notify then
        lib.notify({
            title = 'Stash Creator',
            description = msg,
            type = ntype
        })
    else
        TriggerEvent('chat:addMessage', { args = { 'StashCreator', msg } })
    end
end

local function dbg(...)
    if Config and Config.Debug then
        local t = {}
        for i = 1, select('#', ...) do
            t[#t+1] = tostring(select(i, ...))
        end
        print('[jf-stashcreator][PLACEMENT]', table.concat(t, ' '))
    end
end


local function RaycastFromCamera(distance)
    local camCoords = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(2)

    local rx = math.rad(camRot.x)
    local rz = math.rad(camRot.z)

    local dir = vector3(
        -math.sin(rz) * math.cos(rx),
        math.cos(rz) * math.cos(rx),
        math.sin(rx)
    )

    local dest = camCoords + (dir * distance)

    local ray = StartShapeTestRay(
        camCoords.x, camCoords.y, camCoords.z,
        dest.x, dest.y, dest.z,
        -1,
        PlayerPedId(),
        0
    )

    local _, hit, coords = GetShapeTestResult(ray)
    if hit == 1 then
        return coords
    end

    return nil
end


local function HasCollision(coords)
    local radius = Config.Placement.radius or 0.6

    local handle = StartShapeTestCapsule(
        coords.x, coords.y, coords.z + 0.1,
        coords.x, coords.y, coords.z - 0.1,
        radius,
        -1,
        PlayerPedId(),
        7
    )

    local _, hit, _, _, entityHit = GetShapeTestResult(handle)

    if entityHit == PlayerPedId() then
        return false
    end

    return hit == 1
end


function JF_StartPlacement(payload)
    if isPlacing then
        notify('Already in placement mode.', 'error')
        return
    end

    if not lib then
        notify('ox_lib not loaded (lib is nil)', 'error')
        return
    end

    placingPayload = payload or {}
    placingHeading = placingPayload.initialHeading or GetEntityHeading(PlayerPedId())
    placingZOffset = 0.0
    isPlacing = true

    notify(
        'Placement mode:\n' ..
        '[E] Confirm\n' ..
        '[Q] Rotate Left\n' ..
        '[SHIFT+E] Rotate Right\n' ..
        '[Mouse Wheel] Height\n' ..
        '[BACKSPACE] Cancel',
        'info'
    )

    dbg('Placement started:', placingPayload.title or 'unknown')

    CreateThread(function()
        while isPlacing do
            Wait(0)

            local coords = RaycastFromCamera(Config.Placement.distance)
            if coords then

                coords = vector3(coords.x, coords.y, coords.z + placingZOffset)

                local blocked = HasCollision(coords)

                -- Marker colour
                local r, g, b = 0, 200, 255
                if blocked then r, g, b = 255, 0, 0 end

                DrawMarker(
                    2,
                    coords.x, coords.y, coords.z + 0.05,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, placingHeading,
                    Config.Placement.markerSize,
                    Config.Placement.markerSize,
                    Config.Placement.markerSize,
                    r, g, b, Config.Placement.markerAlpha,
                    false, true, 2, false
                )


                if IsControlPressed(0, 44) then -- Q
                    placingHeading = placingHeading - 1.0
                end

                if IsControlPressed(0, 21) and IsControlPressed(0, 38) then -- SHIFT + E
                    placingHeading = placingHeading + 1.0
                end


                if IsControlJustPressed(0, 15) then -- MWHEEL UP
                    placingZOffset = placingZOffset + 0.05
                end

                if IsControlJustPressed(0, 14) then -- MWHEEL DOWN
                    placingZOffset = placingZOffset - 0.05
                end

                if IsControlPressed(0, 10) then -- PAGE UP
                    placingZOffset = placingZOffset + 0.02
                end

                if IsControlPressed(0, 11) then -- PAGE DOWN
                    placingZOffset = placingZOffset - 0.02
                end

                placingZOffset = math.max(-1.0, math.min(2.5, placingZOffset))


                if IsControlJustPressed(0, 38) and not IsControlPressed(0, 21) then
                    if blocked then
                        notify('Placement blocked (collision detected).', 'error')
                    else
                        isPlacing = false
                        local cb = placingPayload.onConfirm
                        placingPayload = nil
                        dbg('Confirmed at', coords.x, coords.y, coords.z, 'heading', placingHeading)
                        if cb then
                            cb(coords, placingHeading)
                        end
                    end
                end
            end


            if IsControlJustPressed(0, 177) then -- BACKSPACE
                isPlacing = false
                placingPayload = nil
                dbg('Placement cancelled')
                notify('Placement cancelled.', 'error')
            end
        end
    end)
end
