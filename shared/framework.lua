Framework = Framework or { name = 'standalone', object = nil }

CreateThread(function()
    if GetResourceState('qb-core') == 'started' then
        Framework.name = 'qb'
        Framework.object = exports['qb-core']:GetCoreObject()
    elseif GetResourceState('es_extended') == 'started' then
        Framework.name = 'esx'
        Framework.object = exports['es_extended']:getSharedObject()
    else
        Framework.name = 'standalone'
        Framework.object = nil
    end

    print(('[jf-stashcreator] Framework: %s'):format(Framework.name))
end)

function IsAdmin(src)
    if Framework.name == 'qb' and Framework.object then
        return Framework.object.Functions.HasPermission(src, Config.Admin.qb_permission)
    elseif Framework.name == 'esx' and Framework.object then
        local xPlayer = Framework.object.GetPlayerFromId(src)
        if not xPlayer then return false end
        return (xPlayer.getGroup and xPlayer.getGroup() == Config.Admin.esx_group) or false
    end
    return false
end

function GetCitizenId(src)
    if Framework.name == 'qb' and Framework.object then
        local p = Framework.object.Functions.GetPlayer(src)
        return p and p.PlayerData and p.PlayerData.citizenid or nil
    elseif Framework.name == 'esx' and Framework.object then
        local x = Framework.object.GetPlayerFromId(src)
        return x and (x.identifier or (x.getIdentifier and x.getIdentifier())) or nil
    end
    return nil
end

function GetPlayerJob(src)
    if Framework.name == 'qb' and Framework.object then
        local p = Framework.object.Functions.GetPlayer(src)
        return p and p.PlayerData and p.PlayerData.job and p.PlayerData.job.name or nil
    elseif Framework.name == 'esx' and Framework.object then
        local x = Framework.object.GetPlayerFromId(src)
        return x and x.job and x.job.name or nil
    end
    return nil
end

function GetPlayerGang(src)
    if Framework.name == 'qb' and Framework.object then
        local p = Framework.object.Functions.GetPlayer(src)
        return p and p.PlayerData and p.PlayerData.gang and p.PlayerData.gang.name or nil
    end
    return nil
end

function HasItem(src, itemName)
    if not itemName or itemName == '' then return true end
    if Framework.name == 'qb' and Framework.object then
        local p = Framework.object.Functions.GetPlayer(src)
        if not p then return false end
        return p.Functions.GetItemByName(itemName) ~= nil
    end
    -- ESX/standalone item checks not included in this build
    return true
end
