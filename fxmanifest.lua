

fx_version 'cerulean'
game 'gta5'
version '1.0.0'
lua54 'yes'
description "Advanced Jail using OX LIB"

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"server/*.lua"
}

client_scripts {
	"client/*.lua",
}

shared_scripts {
	'@ox_lib/init.lua',
	'configs/*.lua',
	'locale/locale.lua'
}