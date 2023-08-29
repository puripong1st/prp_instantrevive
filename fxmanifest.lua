fx_version 'adamant'

game 'gta5'

description 'prp_instantrevive'

version '1.3'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'Setting.lua',
	'SourceCode-Cooldown/server.lua',
	'SourceCode-Heal/server.lua',
	'SourceCode-Revive/server.lua'
}
client_scripts {
	'Setting.lua',
	'SourceCode-Cooldown/client.lua',
	'SourceCode-Heal/client.lua',
	'SourceCode-Revive/client.lua'
}
dependencies {
	'es_extended'
}

ui_page "Interface-Revive/index.html"

files {
	'Interface-Revive/index.html',
	'Interface-Revive/js/script.js',
	'Interface-Revive/css/style.css',
    'Interface-Revive/js/scripts.js',
    'Interface-Revive/js/materialiprp_instantrevive.min.js'
}