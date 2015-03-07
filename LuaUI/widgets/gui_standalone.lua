function widget:GetInfo()
  return {
	name      = "Start Menu",
	desc      = "Landing page for spring",
	author    = "funk",
	date      = "Oct, 2014",
	license   = "GPL-v2",
	layer     = 1010,
	enabled   = true,
  handler   = true
  }
end

MENU_DIR = 'LuaUI/Widgets/Menu/'
Settings = {}
local function getVars()

  Settings['Water']                       = Spring.GetConfigInt('ReflectiveWater')
  Settings['ShadowMapSize']               = Spring.GetConfigInt('ShadowMapSize')
  Settings['Shadows']                     = Spring.GetConfigInt('Shadows')

  Settings['AdvMapShading']               = Spring.GetConfigInt('AdvMapShading', 1) == 1
  Settings['AdvModelShading']             = Spring.GetConfigInt('AdvModelShading', 1) == 1
  Settings['AllowDeferredMapRendering']   = Spring.GetConfigInt('AllowDeferredMapRendering', 1) == 1
  Settings['AllowDeferredModelRendering'] = Spring.GetConfigInt('AllowDeferredModelRendering', 1) == 1

  Settings['UnitIconDist']                = Spring.GetConfigInt('UnitIconDist', 280) -- number is used if no config is set
  Settings['UnitLodDist']                 = Spring.GetConfigInt('UnitLodDist', 280)
  Settings['MaxNanoParticles']            = Spring.GetConfigInt('MaxNanoParticles', 1000)
  Settings['MaxParticles']                = Spring.GetConfigInt('MaxParticles', 1000)
  Settings['MapBorder']                   = Spring.GetConfigInt('MapBorder') == 1 -- turn 0/1 to bool
  Settings['3DTrees']                     = Spring.GetConfigInt('3DTrees') == 1
  Settings['MapMarks']                    = Spring.GetConfigInt('MapMarks') == 1
  Settings['DynamicSky']                  = Spring.GetConfigInt('DynamicSky') == 1
  Settings['DynamicSun']                  = Spring.GetConfigInt('DynamicSun') == 1

	Chili       = WG.Chili
	Screen      = Chili.Screen0
	Checkbox    = Chili.Checkbox
	Control     = Chili.Control
	Colorbars   = Chili.Colorbars
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
  TextBox     = Chili.Textbox
	Panel       = Chili.Panel
  ComboBox    = function(obj)
  	local obj = obj
  	local options = obj.options or obj.labels

  	local comboBox = Chili.Control:New{
  		y       = obj.y,
  		width   = obj.width or '100%',
  		height  = 40,
  		x       = 0,
  		padding = {0,0,0,0}
  	}

  	local selected
  	for i = 1, #obj.labels do
  		if obj.labels[i] == Settings[obj.name] then selected = i end
  	end


  	local function applySetting(obj, listID)
  		local value   = obj.options[listID] or ''
  		local setting = obj.name or ''

      Spring.SendCommands(setting..' '..value)
  		Settings[setting] = obj.items[listID]
  		if tonumber(value) then
  			Spring.SetConfigInt(setting, value)
  		end
  	end

  	comboBox:AddChild(
  		Chili.Label:New{
  			x=0,
  			y=0,
        fontsize = 18,
  			caption=obj.title or obj.name,
  		})

  	comboBox:AddChild(
  		Chili.ComboBox:New{
  			name     = obj.name,
  			height   = 25,
  			x        = '10%',
  			width    = '80%',
  			y        = 15,
  			selected = selected,
  			options  = options,
  			items    = obj.labels,
  			OnSelect = {obj.OnSelect or applySetting},
  		})

  	return comboBox
  end

  CheckBox = function(obj)
  	local obj = obj

  	local toggle = function(self)
      Settings[self.name] = self.checked
  		Spring.SendCommands(self.name .. ' ' .. ( self.checked and 0 or 1 ) )
  	end

  	local checkBox = Chili.Checkbox:New{
  		name      = obj.name,
  		caption   = obj.title or obj.name,
  		checked   = Settings[obj.name] or false,
  		tooltip   = obj.tooltip or '',
  		y         = obj.y,
  		width     = obj.width or '80%',
  		height    = 20,
  		x         = '10%',
  		textalign = 'left',
  		boxalign  = 'right',
      fontsize  = 18,
  		OnChange  = {toggle}
  	}
  	return checkBox
  end

  Slider = function(obj)
  	local obj = obj

  	local trackbar = Chili.Control:New{
  		y       = obj.y or 0,
  		width   = obj.width or '100%',
  		height  = 40,
  		x       = 0,
  		padding = {0,0,0,0}
  	}


  	local function applySetting(obj, value)
  		Settings[obj.name] = value
  		Spring.SendCommands(obj.name..' '..value)
  	end

    trackbar:AddChild(Chili.Label:New{
      x        = 0,
      y        = 0,
      fontsize = 18,
      caption  = obj.title or obj.name,
    })

  	trackbar:AddChild(Chili.Trackbar:New{
      name     = obj.name,
      height   = 25,
      x        = '10%',
      width    = '80%',
      y        = 15,
      min      = obj.min or 0,
      max      = obj.max or 1000,
      step     = obj.step or 100,
      value    = Settings[obj.name] or 500,
      OnChange = {applySetting},
  	})

  	return trackbar
  end
  Stack = function(obj)
  	if obj.scroll then
      return ScrollPanel:New{
  			x        = obj.x or 0,
  			y        = obj.y or 0,
  			width    = obj.width or '50%',
  			bottom   = obj.bottom or 0,
  			children = {
  				StackPanel:New{
  					name        = obj.name or 'Stack',
  					x           = 0,
  					y           = 0,
  					width       = '100%',
  					resizeItems = false,
  					autosize    = true,
  					padding     = {0,0,0,0},
  					itemPadding = {0,0,0,0},
  					itemMargin  = {0,0,0,0},
  					children    = obj.children or {},
            verticalSmartScroll  = obj.smartScroll or true,
  					preserverChildrenOrder = true
  				}
  			}
  		}
  	else
      return StackPanel:New{
  			name        = obj.name or 'Stack',
  			x           = obj.x or 0,
  			y           = obj.y or 0,
  			width       = obj.width or '50%',
  			resizeItems = false,
  			autosize    = true,
  			padding     = {0,0,0,0},
  			itemPadding = {0,0,0,0},
  			itemMargin  = {0,0,0,0},
  			children    = obj.children or {},
  			preserverChildrenOrder = true
  		}
  	end
  end

	scrH = Screen.height
	scrW = Screen.width
end

local function showMenu(menu)
	MenuWindow:ClearChildren()
	MenuWindow:AddChild(menu)
end

local function initMain()
  initialized = true
  -- get rid of engine UI
  Spring.SendCommands("ResBar 0", "ToolTip 0","fps 0","console 0")
  gl.SlaveMiniMap(true)

  getVars()

  local width = scrW * 0.9
  local height = width / 2

	MenuWindow = Panel:New{
		parent = Screen,
		x      = (scrW - width)/2,
		y      = (scrH - height)/2,
		height = height,
		width  = width,
		children = {}
	}

	tabs = {
		PlaceHolder = Label:New{caption = 'Coming Soon..', y = 6, fontSize = 30,  x = '0%', width = '100%', align = 'center'},
    Skirmish    = VFS.Include(MENU_DIR .. 'Skirmish.lua'),
		Debug       = VFS.Include(MENU_DIR .. 'Debug.lua'),
    Options    = VFS.Include(MENU_DIR .. 'Options.lua'),
	}


	MenuTabs = TabBar:New{
		name   = 'Tabs',
		parent = Screen,
		x      = (scrW - width)/2 + 30,
		y      = (scrH - height)/2 - 30,
		width  = width,
		height = 30,
		itemMargin = {0,0,4,0},
		OnChange = {
			function(_, name)
				MenuWindow:ClearChildren()
				MenuWindow:AddChild(tabs[name] or tabs.PlaceHolder)
			end
		},
		children = {
			TabBarItem:New{ caption = 'Skirmish', width = 100, fontsize = 20},
			--TabBarItem:New{ caption = 'Missions', width = 100, fontsize = 20},
			--TabBarItem:New{ caption = 'Chickens', width = 100, fontsize = 20},
      TabBarItem:New{ caption = 'Options', width = 100, fontsize = 20},
      TabBarItem:New{ caption = 'Debug', width = 100, fontsize = 20},
		}
	}
  
  -- load from console buffer
  local buffer = Spring.GetConsoleBuffer(100)
  for i=1,#buffer do
    line = buffer[i]
    widget:AddConsoleLine(line.text,line.priority)
  end
end

function widget:GetConfigData()
	return Settings
end

function widget:SetConfigData(data)
	if (data and type(data) == 'table') then
		Settings = data
    initMain()
	end
end

function widget:GameSetup()
  return true, true
end

function widget:AddConsoleLine(text)
  if not tabs then return end
  local log = tabs.Debug:GetObjectByName('log')

  log:AddChild(Chili.TextBox:New{
    width       = '100%',
    text        = text,
    duplicates  = 0,
    align       = "left",
    valign      = "ascender",
    padding     = {0,0,0,0},
    duplicates  = 0,
    lineSpacing = 1,
    font        = {
      outline          = true,
      autoOutlineColor = true,
      outlineWidth     = 4,
      outlineWeight    = 1,
    },
  })
end

function ScriptTXT(script)
  local string = '[Game]\n{\n\n'

  -- First write Tables
  for key, value in pairs(script) do
    if type(value) == 'table' then
      string = string..'\t['..key..']\n\t{\n'
      for key, value in pairs(value) do
        string = string..'\t\t'..key..' = '..value..';\n'
      end
      string = string..'\t}\n\n'
    end
  end

  -- Then the rest (purely for aesthetics)
  for key, value in pairs(script) do
    if type(value) ~= 'table' then
      string = string..'\t'..key..' = '..value..';\n'
    end
  end
  string = string..'}'

  local txt = io.open('script.txt', 'w+')
  txt:write(string)
	txt:close()
  return string
end
