local function SafeWebhook()
    return Config and Config.Webhook and Config.Webhook.enabled and Config.Webhook.url and Config.Webhook.url ~= ''
end

function SendLog(title, description, color)
    if not SafeWebhook() then return end

    local payload = {
        username = Config.Webhook.name or 'Stash Logs',
        avatar_url = Config.Webhook.avatar,
        embeds = {{
            title = title,
            description = description,
            color = color or 16777215,
            footer = { text = os.date('%d/%m/%Y %H:%M:%S') }
        }}
    }

    PerformHttpRequest(Config.Webhook.url, function(err, text)
        if Config.Debug then
            print(('[jf-stashcreator][WEBHOOK] err=%s resp=%s'):format(tostring(err), tostring(text)))
        end
    end, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end

function PlayerInfo(src)
    return {
        name = GetPlayerName(src) or ('src:' .. tostring(src)),
        citizenid = GetCitizenId(src) or 'N/A',
        job = GetPlayerJob(src) or 'N/A',
        gang = GetPlayerGang(src) or 'N/A'
    }
end
