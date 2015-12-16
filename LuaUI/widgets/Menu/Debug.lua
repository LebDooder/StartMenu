local Debug = Control:New{
	name = "Debug",
	panelRight = true,
	x = 0, y = 0, right = 0, bottom = 0,
}

----------------------------
-- Widgets
----------------------------

local wFilterString = ""
local widgetList = {}

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
		if string.lower(name or ''):find(wFilterString)
		or string.lower(wData.desc or ''):find(wFilterString)
		or string.lower(wData.author or ''):find(wFilterString) then
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
	local stack = Debug:GetObjectByName('widgetList')
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
			stack:AddChild(Label:New{caption = cat.label,x='0%',fontsize=18})
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
				stack:AddChild(Checkbox:New{
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
-- Rebuilds widget list with new filter
local function addFilter()
	local editbox = Debug:GetObjectByName('widgetFilter')
	wFilterString = editbox.text or ""
	makeWidgetList()
	editbox:SetText('')
end

Debug:AddChild(EditBox:New{
  name        = 'widgetFilter',
  x           = 0,
  y           = 0,
  width       = '30%',
  text        = ' Enter filter -> Hit Return,  or -->',
  OnMouseDown = {function(obj) obj.text = '' end}
})

Debug:AddChild(Button:New{
  right     = '63%',
  y         = 0,
  height    = 20,
  width     = '7%',
  caption   = 'Search',
  OnMouseUp = {addFilter}
})

Debug:AddChild(Stack{
  name   = 'widgetList',
  width  = '35%',
  y      = 25,
  scroll = true
})

Debug:AddChild(Stack{
  name   = 'log',
  x      = '40%',
  width  = '60%',
  scroll = true
})

makeWidgetList()

return Debug
