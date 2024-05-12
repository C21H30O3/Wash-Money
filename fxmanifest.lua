fx_version 'cerulean'
lua54 'yes'
game 'gta5'
author 'C21H30O3'
version '1.0'

shared_script {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}
server_scripts {
    'server.lua'
}
client_scripts {
    'config.lua'
}
dependencies {
    'es_extended',
}