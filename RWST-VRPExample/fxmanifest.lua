fx_version "cerulean"
game "gta5"

lua54 "yes"

server_only "yes"

dependency {
  "RWST",
  "vrp"
}

shared_scripts {
  "@vrp/lib/utils.lua"
}

server_scripts {
  "@RWST/lib/RWST.lua",
  "example.lua"
}
