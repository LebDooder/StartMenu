function widget:GetInfo()
  return {
	name      = "Start Menu",
	desc      = "Landing page for spring",
	author    = "funk",
	date      = "Oct, 2014",
	license   = "GPL-v2",
	layer     = 1010,
	enabled   = true,
  }
end

local MENU_DIR = 'LuaUI/Widgets/Menu/'

local Chili, Screen
local MenuWindow, MenuButtons, scrH, scrW

local function getVars()
	Chili       = WG.Chili
	Screen      = Chili.Screen0
	Checkbox    = Chili.Checkbox
	Control     = Chili.Control
	Colorbars   = Chili.Colorbars
	ComboBox    = Chili.ComboBox
	Button      = Chili.Button
	Label       = Chili.Label
	Line        = Chili.Line
	EditBox     = Chili.EditBox
	Window      = Chili.Window
	ScrollPanel = Chili.ScrollPanel
	LayoutPanel = Chili.LayoutPanel
	StackPanel  = Chili.StackPanel
	Grid        = Chili.Grid
	TextBox     = Chili.TextBox
	Image       = Chili.Image
	TreeView    = Chili.TreeView
	Trackbar    = Chili.Trackbar
	TabPanel    = Chili.TabPanel
	TabBar      = Chili.TabBar
	TabBarItem  = Chili.TabBarItem
	Panel       = Chili.Panel

	scrH = Screen.height
	scrW = Screen.width
end

local function showMenu(menu)
	MenuWindow:ClearChildren()
	MenuWindow:AddChild(menu)
end

local function initBG()
	local width = scrW * 0.8
	
	Background = Control:New{
		x       = 0,
		y       = 0,
		right   = 0,
		bottom  = 0,
		padding = {0,0,0,0},
		margin  = {0,0,0,0},
		parent  = Screen
	}
	
	Background:AddChild(Image:New{
		y      = 0,
		x      = 0,
		width  = '100%',
		height = 300,
		file   = 'LuaUI/images/BARlogo.png',
	})

	Background:AddChild(Image:New{
		y          = 0,
		x          = 0,
		right      = 0,
		bottom     = 0,
		keepAspect = false,
		file       = 'LuaUI/images/gradient.png',
	})

	-- Background:AddChild(Image:New{
		-- y      = 0,
		-- x      = 0,
		-- width  = 2560, -- image res
		-- height = 1440, -- image res
		-- file   = 'Bitmaps/LoadPictures/loadscreen.png',
	-- })
end

local function initMain()
	
	MenuWindow = Panel:New{
		parent = Screen,
		x      = scrW/2 - 400,
		y      = 300,
		height = 400,
		width  = 800,
		children = {}
	}

	local tabs = {
		PlaceHolder = Label:New{caption = 'Coming Soon..', y = 6, fontSize = 30,  x = '0%', width = '100%', align = 'center'},
		Online      = VFS.Include(MENU_DIR .. 'Online.lua'),
		Skirmish    = VFS.Include(MENU_DIR .. 'Skirmish.lua'),
	}

	
	MenuTabs = TabBar:New{
		name   = 'Tabs',
		parent = Screen,
		x      = scrW/2 - 400,
		y      = 270,
		width  = 800,
		height = 30,
		itemMargin = {0,0,4,0},
		OnChange = {
			function(_, name)
				MenuWindow:ClearChildren()
				MenuWindow:AddChild(tabs[name] or tabs.PlaceHolder)
			end
		},
		children = {
			TabBarItem:New{ caption = 'Online', width = 100, fontsize = 20},
			TabBarItem:New{ caption = 'Skirmish', width = 100, fontsize = 20},
			TabBarItem:New{ caption = 'Missions', width = 100, fontsize = 20},
			TabBarItem:New{ caption = 'Chickens', width = 100, fontsize = 20},
			TabBarItem:New{ caption = 'Options', width = 100, fontsize = 20},
			-- TabBarItem:New{ caption = 'Quit',
				-- width = '100%', fontsize = 20,
				-- OnClick = {function() Spring.SendCommands{'quit'} end}
			-- },
		}
	}
	
	TestTab = TabBarItem:New{
		caption = 'Test',
		parent = MenuTabs,
		width = 100,
		fontsize = 20,
		OnClick = {function() MenuTabs:Remove('Test') end}
	}
end

function widget:Initialize()
	-- WG.GetMapInfo('Ravaged_2')
	Spring.SendCommands("ResBar 0", "ToolTip 0","fps 0")
	getVars()
	initMain()
	initBG()
end

function widget:ShutDown()
	MenuWindow:Dispose()
	--MenuButtons:Dispose()
end

function widget:DrawScreen()
	-- Black Background
	--  TODO fix, only needed for brief moment before chili inits
	-- local vsx, vsy = gl.GetViewSizes()
	-- gl.Color(0,0,0,1)
	-- gl.Rect(0,0,vsx,vsy)
end


function WriteScript(script)
	local txt = io.open('script.txt', 'w+')
	txt:write('[Game]\n{\n\n')
	
	-- First write Tables
	for key, value in pairs(script) do
		if type(value) == 'table' then
			txt:write('\t['..key..']\n\t{\n')
			for key, value in pairs(value) do
				txt:write('\t\t'..key..' = '..value..';\n')
			end
			txt:write('\t}\n\n')
		end
	end
	
	-- Then the rest (purely for aesthetics)
	for key, value in pairs(script) do
		if type(value) ~= 'table' then
			txt:write('\t'..key..' = '..value..';\n')
		end
	end
	txt:write('}')
	txt:close()
end