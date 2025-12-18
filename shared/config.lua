Config = {}

-- Global debug prints
Config.Debug = false

-- Admin checks
Config.Admin = {
    qb_permission = 'admin',
    esx_group = 'admin',
}

-- Inventory integration (v1 supports ox_inventory)
Config.Inventory = {
    system = 'ox_inventory',
}

-- Target / Third-eye integration
Config.Target = {
    enabled = true,
    mode = 'auto', -- auto | ox_target | qb-target
    radius = 1.5,
    distance = 2.0,
}

-- Placement preview settings
Config.Placement = {
    distance = 10.0,     -- raycast distance
    radius = 0.6,        -- collision sphere radius
    markerSize = 0.45,
    markerAlpha = 160,

}

-- Password behaviour
Config.Password = {
    enabled = true,
    server_side_check = true,
}

-- Required item behaviour
Config.RequiredItem = {
    enabled = true,
    enforce = true,
}

-- Discord webhook audit logs
Config.Webhook = {
    enabled = true,
    url = 'PUT_YOUR_DISCORD_WEBHOOK_HERE',
    name = 'Stash Creator Logs',
    avatar = 'https://i.imgur.com/8Km9tLL.png'
}
