
local Match = Control:New{
	x = 0, y = 0, right = 0, bottom = 0,
	name = 'Match',
	padding = {0,0,0,0},
	bots = {},
	botNames = {'Fred','Fred Jr.','Steve','John','Greg'},
	Script = {
		player0  =  {
			isfromdemo = 0,
			name = 'Local',
			rank = 0,
			spectator = 0,
			team = 0,
		},

		team0  =  {
			allyteam = 0,
			rgbcolor = '0.99609375 0.546875 0',
			side = 'CORE',
			teamleader = 0,
		},

		allyteam0  =  {
			numallies = 0,
		},

		gametype = 'Balanced Annihilation Reloaded $VERSION',
		hostip = '127.0.0.1',
		hostport = 8452,
		ishost = 1,
		mapname = 'Icy_Shell_v01',
		myplayername = 'Local',
		nohelperais = 0,
		numplayers = 1,
		numusers = 2,
		startpostype = 2,
	}
}

-- Adds bots to script table, then starts the game with a generated script
local function StartScript()

	-- it's easier to store and modify objects than table
	--  so I wait until the end to put bots in the Script (no more changing)
	for team = 1, #Match.bots do
		local bot = Match.bots[team]
		Match.Script['ai' .. team - 1] = {
			host = 0,
			isfromdemo = 0,
			name = bot.name or 'AI',
			shortname = 'KAIK',
			spectator = 0,
			team = team,
		}

		Match.Script['team'.. team]  =  {
			allyteam = bot.allyTeam,
			rgbcolor = ''..bot.color[1]..' '..bot.color[2]..' '..bot.color[3],
			side = bot.side,
			teamleader = 0,
		}

		if not Match.Script['allyteam' .. bot.allyTeam] then
			Match.Script['allyteam' .. bot.allyTeam]  =  {
				numallies = 0,
			}
		end
	end

	WriteScript(Match.Script)
	Spring.Reload(ScriptTXT(Match.Script))
end

local sideImage = function(side, color)
	local image = Image:New{
		x = 0, y = 0, right = 0, bottom = 0,
		file = 'LuaUI/Images/'..side..'.dds',
		children = {
			Image:New{
				color = color,
				x = 0, y = 0, right = 0, bottom = 0,
				file = 'LuaUI/Images/'..side..'_Overlay.dds',
			}
		}
	}
	return image
end

local getLayout = function(AI)
	local layout = Control:New{
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		padding = {0,0,0,0},
		children = {
			Label:New{
				caption = 'Name',
				fontsize = 20,
				x = 5,
				y = 10,
				width = '100%',
			},
			EditBox:New{
				x = 20,
				right = 20,
				y = 30,
				height = 30,
				text = AI.name,
				OnFocusUpdate = {
					function(self)
						AI.name = self.text
					end
				}
			},
			Label:New{
				y = 64,
				x = 5,
				width = '100%',
				caption = 'Side',
				fontsize = 20,
			},
			Button:New{
				y = 90,
				x = 5,
				width = 65,
				height = 65,
				caption = '',
				padding = {0,0,0,0},
				children = {sideImage('ARM', AI.color)},
				OnClick = {
					function()
						AI.side = 'ARM'
						AI:ClearChildren()
						AI:AddChild(sideImage('ARM', AI.color))
					end
				}
			},
			Button:New{
				y = 90,
				x = 75,
				width = 65,
				height = 65,
				caption = '',
				padding = {0,0,0,0},
				children = {sideImage('CORE', AI.color)},
				OnClick = {
					function()
						AI.side = 'CORE'
						AI:ClearChildren()
						AI:AddChild(sideImage('CORE', AI.color))
					end
				}
			},
			Colorbars:New{
				x = 5,
				right = 5,
				bottom = 10,
				height = 50,
				color = AI.color,
			},
		}
	}
	return layout
end

-- Attaches random profile and config layout to Button obj
-- Essentially turns Button obj into AI obj
local generatePersona = function(self)

	self.name = Match.botNames[math.random(5)]
	self.team = #Match.bots + 1
	self.color = {math.random(),math.random(),math.random(),1}
	self.side = math.random(10) > 5 and 'CORE' or 'ARM'

	self.caption = ''
	self:AddChild(sideImage(self.side, self.color))

	self.layout = getLayout(self)

	-- create a replacement add AI button
	Match:AddChild(Button:New{
		x = self.x + 55,
		y = 60,
		height = 50,
		width = 50,
		padding = {0,0,0,0},
		allyTeam = 1,
		caption = 'Add AI',
		OnClick = self.OnClick,
	})

	self.OnClick = {
		function(self)
			Match:GetChildByName('AI Config'):ClearChildren()
			Match:GetChildByName('AI Config'):AddChild(self.layout)
		end
	}

	Match.bots[self.team] = self
end

Match:AddChild(Label:New{
	caption  = 'Skirmish',
	x        = 2,
	y        = 4,
	fontSize = 50,
})

Match:AddChild(Button:New{
	caption  = 'Start',
	y        = 10,
	right    = 20,
	height   = 50,
	width    = 65,
	padding  = {0,0,0,0},
	allyTeam = 1,
	OnClick  = {StartScript},
})

---------------------------
-- Teams and Bot UI
-- TODO add allyTeams:
--  YOU vs (bot)(add AI) vs (add AI)

Match:AddChild(Label:New{
	caption  = 'YOU vs',
	fontSize = 24,
	x        = 20,
	y        = 70,
})

Match:AddChild(Button:New{
	caption  = 'Add AI',
	x        = 120,
	y        = 60,
	height   = 50,
	width    = 50,
	padding  = {0,0,0,0},
	allyTeam = 1,
	OnClick  = {generatePersona},
})

Match:AddChild(Panel:New{
	name     = 'AI Config',
	right    = 0,
	y        = 150,
	bottom   = 6,
	width    = '25%',
	padding  = {0,0,0,0},
	children = {
		Label:New{caption = 'Add AI', y = 6, fontSize = 18,  x = '0%', width = '100%', align = 'center'},
		Label:New{caption = 'and/or', y = 26, fontSize = 18, x = '0%', width = '100%', align = 'center'},
		Label:New{caption = 'Select AI', y = 46, fontSize = 18, x = '0%', width = '100%', align = 'center'},
		Label:New{caption = 'To edit', y = 66, fontSize = 18, x = '0%', width = '100%', align = 'center'},
	}
})


---------------------------
-- Map Selection UI

Match:AddChild(Label:New{
	caption  = 'On',
	fontSize = 20,
	x        = 36,
	y        = 120,
})

Match:AddChild(Label:New{
	name    = 'MapName',
	caption = VFS.GetMaps()[1] or '',
	fontSize = 20,
	x        = 70,
	y        = 120,
})

-- TODO get minimaps somehow
-- TODO add small translucent info overlay over minimap (wind, size, teams, etc..)
-- TODO get and show team start boxes, or at least start positions
-- TODO add tabpanel to include: Minimap, Metalmap, infomap
local MiniMap = Button:New{
	name    = 'Minimap',
	caption = 'MiniMap for ' .. string.sub(VFS.GetMaps()[1], 1, 10) .. '..',
	x       = 0,
	width   = 250,
	y       = 0,
	bottom  = 0,
	focusColor = {0,0,0,0.5},
	borderColor = {0,0,0,0},
	backgroundColor = {0,0,0,0.5},
}

local MapList = ScrollPanel:New{
	name   = 'Map Selection',
	right  = 0,
	width  = 185,
	y      = 0,
	bottom = 0,
	children = {Label:New{caption = '-- Select Map --', y = 6, fontSize = 18,  x = '0%', width = '100%', align = 'center'}}

}

for _, map in pairs(VFS.GetMaps()) do
	MapList:AddChild(Button:New{
		caption  = map,
		x        = 0,
		y        = #MapList.children * 30,
		width    = '100%',
		height   = 26,
		OnClick = {
			function(self)
				Match.Script.mapname = self.caption
				Match:GetChildByName('MapName'):SetCaption(self.caption)
				MiniMap:SetCaption('MiniMap for ' .. string.sub(self.caption, 1, 10) .. '..')
			end
		}
	})
end


Match:AddChild(Panel:New{
	name    = 'Map Config',
	x       = 0,
	y       = 150,
	bottom  = 6,
	width   = '74%',
	padding = {0,0,0,0},
	children = {MiniMap, MapList}
})
-- End

-- Control will essentially attached to a Menu button
return Match
