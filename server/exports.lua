
exports('OpenStash', function(src, stashId)
    if Config.Inventory.system == 'ox_inventory' and GetResourceState('ox_inventory') == 'started' then
        TriggerClientEvent('ox_inventory:openInventory', src, 'stash', stashId)

        return true
    end
    return false
end)

exports('CreateStash', function(data)
    if not data or not data.stash_id or not data.coords then return false end
    DB_SaveStash(data)
    if GetResourceState('ox_inventory') == 'started' then
        exports.ox_inventory:RegisterStash(
            data.stash_id,
            data.label or data.stash_id,
            tonumber(data.slots) or 50,
            (tonumber(data.weight) or 100) * 1000
        )
    end
    TriggerClientEvent('jf-stashcreator:client:refreshTargets', -1)
    return true
end)
