--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
  return {
    name      = "LibLobby API",
    desc      = "LibLobby GUI Framework",
    author    = "gajop",
    date      = "WIP",
    license   = "GPLv2",
    version   = "0.2",
    layer     = 1000,
    enabled   = true,  --  loaded by default?
    handler   = true,
    api       = true,
    hidden    = true,
  }
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- LibLobby's location

LIB_LOBBY_DIRNAME = "LuaUI/widgets/Lobby/"

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:Initialize()
  LCS = loadstring(VFS.LoadFile("LuaUI/widgets/LCS/LCS.lua"))
  LCS = LCS()

  VFS.Include(LIB_LOBBY_DIRNAME .. "observable.lua", nil, VFS.RAW_FIRST)
  Interface = VFS.Include(LIB_LOBBY_DIRNAME .. "interface.lua", nil, VFS.RAW_FIRST)
  Wrapper = VFS.Include(LIB_LOBBY_DIRNAME .. "wrapper.lua", nil, VFS.RAW_FIRST)

  lobby = Wrapper()


  --// Export Widget Globals
  WG.LibLobby = {}
  WG.LibLobby = {
      lobby = lobby, -- instance (singleton)
      Listener = Listener
  }

end

function widget:Shutdown()
  WG.LibLobby = nil
end

function widget:Update()
  xpcall(
    function()
      WG.LibLobby.lobby:Update()
    end, 
    function(err)
      Spring.Echo(debug.traceback())
    end
  )
end
