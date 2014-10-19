-- WIP
-- Look at the globalize function for an explanation on the 'API' to add options to menu from other widgets
--  as of writing this it is around line 700

-- TODO add popup window/API
-- TODO Handle spring settings better in general
-- TODO possibly seperate engine options and handling to seperate widget
--   same with widget/interface tab
function widget:GetInfo()
	return {
		name    = 'Main Menu',
		desc    = 'The main menu; for information, settings, widgets, etc',
		author  = 'Funkencool',
		date    = '2013',
		license = 'GNU GPL v2',
		layer   = 1001,
		handler = true,
		enabled = true
	}
end


local spSendCommands = Spring.SendCommands
local spgetFPS       = Spring.GetFPS
local spGetTimer     = Spring.GetTimer

local Chili, mainMenu, menuTabs, menuBtn
local Settings = {}
local DefaultSettings = {}

local white = '\255\255\255\255'

Settings['searchWidgetDesc'] = true
Settings['searchWidgetAuth'] = true
Settings['searchWidgetName'] = true
Settings['widget']           = {}
Settings['UIwidget']         = {}
Settings['Skin']             = 'Squared'
Settings['Cursor']           = 'Default'
Settings['CursorName']       = 'ba'

------------------------------------
local wFilterString = ""
local widgetList = {}
local tabs = {}
local credits = ''
local changelog = ''
local NewbieInfo = ''
local HotkeyInfo = ''
local amNewbie = false

local wCategories = {
	['unit']      = {label = 'Units',       list = {}, pos = 1,},
	['cmd']       = {label = 'Commands',    list = {}, pos = 2,},
	['gui']       = {label = 'GUI',         list = {}, pos = 3,},
	['snd']       = {label = 'Sound',       list = {}, pos = 4,},
	['camera']    = {label = 'Camera',      list = {}, pos = 5,},
	['map']       = {label = 'Map',         list = {}, pos = 6,},
	['bgu']       = {label = 'BAR GUI',     list = {}, pos = 7,},
	['gfx']       = {label = 'GFX',         list = {}, pos = 8,},
	['dbg']       = {label = 'Debugging',   list = {}, pos = 9,},
	['api']       = {label = 'API \255\255\200\200(Here be dragons!)',         list = {}, pos = 10,},
	['test']      = {label = 'Test Widgets',list = {}, pos = 11,},
	['ungrouped'] = {label = 'Ungrouped',   list = {}, pos = 12,},
}
----------------------------
--
local function setCursor(cursorSet)
	local cursorNames = {
		'cursornormal','cursorareaattack','cursorattack','cursorattack',
		'cursorbuildbad','cursorbuildgood','cursorcapture','cursorcentroid',
		'cursorwait','cursortime','cursorwait','cursorunload','cursorwait',
		'cursordwatch','cursorwait','cursordgun','cursorattack','cursorfight',
		'cursorattack','cursorgather','cursorwait','cursordefend','cursorpickup',
		'cursorrepair','cursorrevive','cursorrepair','cursorrestore','cursorrepair',
		'cursormove','cursorpatrol','cursorreclamate','cursorselfd','cursornumber',
        'cursorsettarget',
	}

	for i=1, #cursorNames do
		local topLeft = (cursorNames[i] == 'cursornormal' and cursorSet ~= 'k_haos_girl')
		Spring.ReplaceMouseCursor(cursorNames[i], cursorSet..'/'..cursorNames[i], topLeft)
	end
end

----------------------------
-- Toggles widgets, enabled/disabled when clicked
--  does not account for failed initialization of widgets yet
local function toggleWidget(self)
	widgetHandler:ToggleWidget(self.name)
	if self.checked then
		self.font.color        = {1,0,0,1}
		self.font.outlineColor = {1,0,0,0.2}
	else
		self.font.color        = {0.5,1,0,1}
		self.font.outlineColor = {0.5,1,0,0.2}
	end
	self:Invalidate()
end

----------------------------
-- Adds widget to the appropriate groups list of widgets
local function groupWidget(name,wData)

	local _, _, category = string.find(wData.basename, '([^_]*)')
	if (not category) or (not wCategories[category]) then category = 'ungrouped' end

	for cat_name,cat in pairs(wCategories) do
		if category == cat_name then
			cat.list[#cat.list+1] = {name = name, wData = wData}
		end
	end

end

----------------------------
-- Decides which group each widget goes into
local function sortWidgetList()
	local wFilterString = string.lower(wFilterString or '')
	for name,wData in pairs(widgetHandler.knownWidgets) do

		-- Only adds widget to group if it matches an enabled filter
		if (Settings.searchWidgetName and string.lower(name or ''):find(wFilterString))
		or (Settings.searchWidgetDesc and string.lower(wData.desc or ''):find(wFilterString))
		or (Settings.searchWidgetAuth and string.lower(wData.author or ''):find(wFilterString)) then
			groupWidget(name,wData)
		end

		-- Alphabetizes widgets by name in ascending order
		for _,cat in pairs(wCategories) do
			local ascendingName = function(a,b) return a.name<b.name end
			table.sort(cat.list,ascendingName)
		end

	end
end

----------------------------
-- Creates widget list for interface tab
--  TODO create cache of chili objects on initialize
--    (doesn't need to recreate everything unless /luaui reload is called)
--  TODO detect widget failure, set color accordingly
local function makeWidgetList()
	sortWidgetList()
	local stack = tabs['Interface']:GetObjectByName('widgetList')
	stack:ClearChildren()

	-- Get order of categories
	local inv_pos = {}
	local num_cats = 0
	for cat_name,cat in pairs(wCategories) do
		if cat.pos then
			inv_pos[cat.pos] = cat_name
			num_cats = num_cats + 1
		end
	end

	-- First loop adds group label
	for i=1, num_cats do
		-- Get group of pos i
		local cat = wCategories[inv_pos[i]]
		local list = cat.list
		if #list>0 then
			stack:AddChild(Chili.Label:New{caption  = cat.label,x='0%',fontsize=18})
			-- Second loop adds each widget
			for b=1,#list do
				local green  = {color = {0.5,1,0,1}, outlineColor = {0.5,1,0,0.2}}
				local orange = {color = {1,0.5,0,1}, outlineColor = {1,0.5,0,0.2}}
				local red    = {color = {1,0,0,1}, outlineColor = {1,0,0,0.2}}

				local enabled = (widgetHandler.orderList[list[b].name] or 0)>0
				local active  = list[b].wData.active
				local author = list[b].wData.author or "Unkown"
				local desc = list[b].wData.desc or "No Description"
				local fromZip = list[b].wData.fromZip and "" or "*"
				stack:AddChild(Chili.Checkbox:New{
					name      = list[b].name,
					caption   = list[b].name .. fromZip,
					tooltip   = 'Author: '..author.. '\n'.. desc,
					width     = '80%',
					x         = '10%',
					font      = (active and green) or (enabled and orange) or red,
					checked   = enabled,
					OnChange  = {toggleWidget},

				})
			end
		end
		cat.list = {}
	end
end

----------------------------

-- Toggles the menu visibility
--  also handles tab selection (e.g. f11 was pressed and menu opens to 'Interface')
local function showHide(tab)
	local oTab = Settings.tabSelected


	if tab then
		menuTabs:Select(tab)
	else
		mainMenu:ToggleVisibility()
		return
	end

	if mainMenu.visible and oTab == tab then
		mainMenu:Hide()
	elseif mainMenu.hidden then
		mainMenu:Show()
	end
end

----------------------------
-- Handles the selection of the tabs
local function sTab(_,tabName)
	if not tabs[tabName] then return end
	if Settings.tabSelected then mainMenu:RemoveChild(tabs[Settings.tabSelected]) end
	mainMenu:AddChild(tabs[tabName])
	Settings.tabSelected = tabName
end

----------------------------
-- Rebuilds widget list with new filter
local function addFilter()
	local editbox = tabs['Interface']:GetObjectByName('widgetFilter')
	wFilterString = editbox.text or ""
	makeWidgetList()
	editbox:SetText('')
end

----------------------------
-- Saves a variable in the settings array
local function Save(index, data)

	-- New behavior, Save{ key = value, key2 = value2 }
	if type(index)=='table' then
		for key, value in pairs(index) do
			Settings[key] = value
		end

	-- Old behavior, Save('key', value)
	else
		local old = Settings[index]
		Settings[index] = data
		return old
	end
end

----------------------------
-- Loads a variable from the settings array
local function Load(index)
	if Settings[index] ~= nil then
		return Settings[index]
	else
		Spring.Echo('[Main Menu]Could not find '..index)
        return nil
	end
end

----------------------------
--
local function addOption(obj)
	local stack = tabs[obj.tab]:GetObjectByName(obj.stack or 'Stack')

	if obj.title then
		-- Stays if widget fails, needs to be created in widget to work
		stack:AddChild(Chili.Label:New{caption=obj.title,x='0%',fontsize=18})
	end

	for i = 1, #obj.children do
		stack:AddChild(obj.children[i])
	end

	if obj.bLine then
		-- Stays if widget fails, needs to be created in widget to work
		stack:AddChild(Chili.Line:New{width='100%'})
	end

end

----------------------------
--
local function addToStack()
	Spring.Echo('AddToStack() is depreciated, instead use AddOption{}')
end

----------------------------
-- Creates a stack panel which can then be used as a parent to options
local function addStack(obj)
	local stack
	if obj.scroll then
		stack = Chili.ScrollPanel:New{
			x        = obj.x or 0,
			y        = obj.y or 0,
			width    = obj.width or '50%',
			bottom   = obj.bottom or 0,
			children = {
				Chili.StackPanel:New{
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
					preserverChildrenOrder = true
				}
			}
		}
	else
		stack = Chili.StackPanel:New{
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
	return stack
end


----------------------------
-- Creates the original window in which all else is contained
local function loadMainMenu()
	local sizeData = Load('mainMenuSize') or {x=400,y=200,width=585,height=400}

	-- Detects and fixes menu being off-screen
	local vsx,vsy = Spring.GetViewGeometry()
	if vsx < sizeData.x+sizeData.width-100 or sizeData.x < 100 then sizeData.x = 400 end
	if vsy < sizeData.y+sizeData.height-100 or sizeData.y < 100 then sizeData.height = 500 end

	mainMenu = Chili.Window:New{
		parent    = Chili.Screen0,
		x         = sizeData.x,
		y         = sizeData.y,
		width     = sizeData.width,
		height    = sizeData.height,
		padding   = {5,8,5,5},
		draggable = true,
		resizable = true,
		OnResize  = {
			function(self)
				Save{mainMenuSize = {x=self.x,y=self.y,width=self.width,height=self.height}}
			end
		},
		children  = {
			Chili.Line:New{parent = mainMenu,y = 15,width = '100%'},
			Chili.Line:New{parent = mainMenu,bottom = 15,width = '100%'},
		}
	}

	menuTabs = Chili.TabBar:New{
		parent       = mainMenu,
		x            = 0,
		y            = 0,
		width        = '100%',
		height       = 20,
		minItemWidth = 70,
		selected     = Settings.tabSelected or 'Info',
		tabs         = {'Interface'},
		itemPadding  = {1,0,1,0},
		OnChange     = {sTab}
	}
    
    mainMenu:Hide()

end

-----------------------------
-- Creates a tab, mostly as an auxillary function for addControl()
local function createTab(tab)
	tabs[tab.name] = Chili.Control:New{x = 0, y = 20, bottom = 20, width = '100%', children = tab.children or {} }
	menuTabs:AddChild(Chili.TabBarItem:New{caption = tab.name})
end

-----OPTIONS-----------------
-----------------------------


----------------------------
-- Creates a combobox style control
local comboBox = function(obj)
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

		if setting == 'Skin' then
			Chili.theme.skin.general.skinName = value
			Spring.Echo('To see skin changes; \'/luaui reload\'')
		elseif setting == 'Cursor' then
			setCursor(value)
			Settings['CursorName'] = value
        else 
            spSendCommands(setting..' '..value)
		end

		-- Spring.Echo(setting.." set to "..value) --TODO: this is misleading
		Settings[setting] =  obj.items[obj.selected]
	end

	comboBox:AddChild(
		Chili.Label:New{
			x=0,
			y=0,
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
			text     = label,
			options  = options,
			items    = obj.labels,
			OnSelect = {applySetting},
		})

	return comboBox
end

local function createInterfaceTab()
	-- Interface --
	tabs.Interface = Chili.Control:New{x = 0, y = 20, bottom = 20, width = '100%', --Control attached to tab
		children = {
			addStack{name='widgetList',x='50%',scroll=true},
			Chili.EditBox:New{name='widgetFilter',x=0,y=0,width = '35%',text=' Enter filter -> Hit Return,  or -->',OnMouseDown = {function(obj) obj.text = '' end}},
			Chili.Button:New{right='50%',y=0,height=20,width='15%',caption='Search',OnMouseUp={addFilter}},
			Chili.Checkbox:New{caption='Search Widget Name',x=0,y=40,width='35%',textalign='left',boxalign='right',checked=Settings.searchWidgetName,
				OnChange = {function() Settings.searchWidgetName = not Settings.searchWidgetName end}},
			Chili.Checkbox:New{caption='Search Description',x=0,y=20,width='35%',textalign='left',boxalign='right',checked=Settings.searchWidgetDesc,
				OnChange = {function() Settings.searchWidgetDesc = not Settings.searchWidgetDesc end}},
			Chili.Checkbox:New{caption='Search Author',x=0,y=60,width='35%',textalign='left',boxalign='right',checked=Settings.searchWidgetAuth,
				OnChange = {function() Settings.searchWidgetAuth = not Settings.searchWidgetAuth end}},

			Chili.Line:New{width='50%',y=80},

			comboBox{name='Skin',y=90, width='45%',
				labels=Chili.SkinHandler.GetAvailableSkins()},
			comboBox{name='Cursor',y=125, width='45%',
				labels={'Chili Default','Chili Static','Spring Default','CA Classic','CA Static','Erom','Masse','K_haos_girl'},
				options={'zk','zk_static','ba','ca','ca_static','erom','masse','k_haos_girl'}},

			Chili.Label:New{caption='-- Widget Settings --',x='2%',width='46%',align = 'center',y=175},
			addStack{y=190,x='2%',width='46%',scroll=true},
		}
	}
	sTab(_,'Interface')
end

-----------------------------
--
local function AddChildren(control, children)
	for i=1, #children do control:AddChild(children[i]) end
end


-----------------------------
-- Adds a chili control to a tab
--  usage is Menu.AddControl('nameOfTab', controlToBeAdded)
--  if tab doesn't exist, one is created
--  this is useful if you want a widget to get it's own tab (endgraph is a good example)
--  this function probably won't change
local function addControl(tab,control)
	if not tabs[tab] then createTab{name = tab} end
	tabs[tab]:AddChild(control)
	tabs[tab]:Invalidate()
end


-----------------------------
-- Makes certain functions global, extending their usage to other widgets
--  most manipulate and/or create chili objects in some way to extend options
--  look at relevant functions above for more info
local function globalize()
	local Menu = {}

	Menu.UpdateList = makeWidgetList
	Menu.Save       = Save
	Menu.Load       = Load
	Menu.AddControl = addControl
	Menu.ShowHide   = showHide

	-- This will be primary function for adding options to the menu
	--  the name may change but the general usage should stay the same
	Menu.AddOption  = addOption
	-- Example Usage
	-- Menu.AddOption{
	--   tab      = 'Interface',
	--   children = {
	--     Chili.Label:New{caption='Example',x='0%',fontsize=18},
	--     Chili.ComboBox:New{
	--        x        = '10%',
	--        width    = '80%',
	--        items    = {"Option 1", "Option 2", "Option 3"},
	--        selected = 1,
	--        OnSelect = {
	--          function(_,sel)
	--            Spring.Echo("Option "..sel.." Selected")
	--          end
	-- 			  }
	-- 		},
	-- 		Chili.Line:New{width='100%'},
	-- 	}
	-- }



	-- This will likely be replaced ( but will remain for now as is)
	Menu.AddToStack = addToStack

	-- These will more than likely be removed
	Menu.AddChoice  = addChoice
	Menu.Checkbox   = checkbox
	Menu.Slider     = slider
	------------------------

	WG.MainMenu = Menu
end
-----------------------------

function widget:GetConfigData()
	return Settings
end

function widget:SetConfigData(data)
	if (data and type(data) == 'table') then
		Settings = data
	end
end

function widget:KeyPress(key,mod)
	local editbox = tabs['Interface']:GetObjectByName('widgetFilter')
	if key==13 and editbox.state.focused then
		addFilter()
		return true
	end
end

--------------------------
-- Initial function called by widget handler
function widget:Initialize()
	Chili = WG.Chili
	Chili.theme.skin.general.skinName = Settings['Skin'] or 'Squared'
	setCursor(Settings['CursorName'] or 'zk')

	loadMainMenu()

	createInterfaceTab()
	
	globalize()
	
	makeWidgetList()

	-----------------------
	---     Hotkeys     ---
	local openMenu    = function() showHide() end
	local openWidgets = function() showHide('Interface') end

	spSendCommands('unbindkeyset f11')
	spSendCommands('unbindkeyset Any+i gameinfo')
	spSendCommands('unbind esc quitmessage')
	widgetHandler.actionHandler:AddAction(widget,'openMenu', openMenu, nil, 't')
	widgetHandler.actionHandler:AddAction(widget,'openWidgets', openWidgets, nil, 't')
	spSendCommands('bind f11 openWidgets')
	spSendCommands('bind esc openMenu')
end


function widget:Shutdown()
	spSendCommands('unbind S+esc openMenu')
	spSendCommands('unbind f11 openWidgets')
	spSendCommands('unbind esc hideMenu')
	spSendCommands('bind f11 luaui selector') -- if the default one is removed or crashes, then have the backup one take over.
	spSendCommands('bind Any+i gameinfo')
end

