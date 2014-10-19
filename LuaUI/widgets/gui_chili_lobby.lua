-------------------------
include("keysym.h.lua")

function widget:GetInfo()
  return {
    name      = "Chili lobby",
    desc      = "Chili example lobby",
    author    = "gajop",
    date      = "in the future",
    license   = "GPL-v2",
    layer     = 1001,
    enabled   = true,
  }
end

LIBS_DIR = "LuaUI/widgets/"
LCS = loadstring(VFS.LoadFile(LIBS_DIR .. "LCS/LCS.lua"))
LCS = LCS()

CHILILOBBY_DIR = LIBS_DIR .. "LobbyUI/"

user = {name = '', pass = '', remember = false, auto = false}

function Init()
    VFS.Include(CHILILOBBY_DIR .. "exports.lua")
    VFS.Include(CHILILOBBY_DIR .. "console.lua")
    VFS.Include(CHILILOBBY_DIR .. "login_window.lua")
    VFS.Include(CHILILOBBY_DIR .. "chat_windows.lua")
    VFS.Include(CHILILOBBY_DIR .. "battle_list_window.lua")
	VFS.Include(CHILILOBBY_DIR .. "battle_room_window.lua")
    VFS.Include(CHILILOBBY_DIR .. "user_list_panel.lua")
	WG.BattleList = BattleListWindow
	LoginWindow()
end

function widget:SetConfigData(data)
	if data and type(data) == 'table' then
		for key, value in pairs(data) do 
			user[key] = value
			Spring.Echo(key..' = '..tostring(value))
		end
	end
	Init()
end

function widget:GetConfigData()
	return user
end


