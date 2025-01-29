fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

author 'marcuzz' 
description 'Inventory item for RSG cash and bloodmoney'
version '1.0.0'

shared_scripts {
    'config.lua',
}

server_scripts {
    'money.lua'
}

dependencies {
    'rsg-core',
}

lua54 'yes'
