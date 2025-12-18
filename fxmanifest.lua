fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'JacobF'
description 'jf-stashcreator - Full: DB stashes + admin manager + target + placement preview'
version '1.2.0'

dependency 'ox_lib'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/framework.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/debug.lua',
    'client/placement.lua',
    'client/creator.lua',
    'client/target.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/debug.lua',
    'server/database.lua',
    'server/logs.lua',
    'server/main.lua',
    'server/exports.lua'
}
