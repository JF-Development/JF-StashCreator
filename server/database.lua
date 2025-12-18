function DB_SaveStash(data)
    return MySQL.insert.await(
        'INSERT INTO stash_creator (stash_id, label, slots, weight, password, required_item, job, gang, citizenid, coords, heading) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
        {
            data.stash_id,
            data.label,
            data.slots,
            data.weight,
            data.password,
            data.required_item,
            data.job,
            data.gang,
            data.citizenid,
            json.encode(data.coords),
            tonumber(data.heading) or 0
        }
    )
end

function DB_UpdateStash(stashId, data)
    return MySQL.update.await(
        'UPDATE stash_creator SET label = ?, slots = ?, weight = ?, password = ?, required_item = ?, job = ?, gang = ?, citizenid = ? WHERE stash_id = ?',
        { data.label, data.slots, data.weight, data.password, data.required_item, data.job, data.gang, data.citizenid, stashId }
    )
end

function DB_MoveStash(stashId, coords, heading)
    return MySQL.update.await(
        'UPDATE stash_creator SET coords = ?, heading = ? WHERE stash_id = ?',
        { json.encode(coords), tonumber(heading) or 0, stashId }
    )
end

function DB_DeleteStash(stashId)
    return MySQL.update.await('DELETE FROM stash_creator WHERE stash_id = ?', { stashId })
end

function DB_GetAllStashes()
    return MySQL.query.await('SELECT * FROM stash_creator')
end

function DB_GetStashById(stashId)
    return MySQL.single.await('SELECT * FROM stash_creator WHERE stash_id = ?', { stashId })
end
