
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

		gametype = 'Pick A Game',
		hostip = '127.0.0.1',
		hostport = 8452,
		ishost = 1,
		mapname = 'Pick A Map',
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


-- Attaches random profile and config layout to Button obj
-- Essentially turns Button obj into AI obj
local generatePersona = function(self)

	self.name = Match.botNames[math.random(5)]
	self.team = #Match.bots + 1
	self.color = {math.random(),math.random(),math.random(),1}
	self.side = math.random(10) > 5 and 'CORE' or 'ARM'

	self.caption = self.name
	self:AddChild(sideImage(self.side, self.color))

	-- create a replacement 'add AI' button
	Match:AddChild(Button:New{
		x = self.x + 55,
		y = 60,
		height = 50,
		width = 50,
		padding = {0,0,0,0},
		allyTeam = 1,
		caption = 'Add\n AI',
		OnClick = self.OnClick,
	})
	self.OnClick = {}
	Match.bots[self.team] = self
end

Match:AddChild(Label:New{
	name     = 'Game Name',
	caption  = Match.Script.gametype,
	x        = 2,
	y        = 4,
	fontSize = 50,
})

Match:AddChild(Button:New{
	caption  = 'Start',
	bottom   = 10,
	right    = 210,
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

-- Match:AddChild(Panel:New{
-- 	name     = 'AI Config',
-- 	right    = 0,
-- 	y        = 150,
-- 	bottom   = 6,
-- 	width    = '25%',
-- 	padding  = {0,0,0,0},
-- 	children = {
-- 		Label:New{caption = 'Add AI', y = 6, fontSize = 18,  x = '0%', width = '100%', align = 'center'},
-- 		Label:New{caption = 'and/or', y = 26, fontSize = 18, x = '0%', width = '100%', align = 'center'},
-- 		Label:New{caption = 'Select AI', y = 46, fontSize = 18, x = '0%', width = '100%', align = 'center'},
-- 		Label:New{caption = 'To edit', y = 66, fontSize = 18, x = '0%', width = '100%', align = 'center'},
-- 	}
-- })


---------------------------
-- Map Selection UI

Match:AddChild(Label:New{
	caption  = 'On',
	fontSize = 20,
	x        = 36,
	y        = 120,
})

Match:AddChild(Label:New{
	name     = 'MapName',
	caption  = Match.Script.mapname,
	fontSize = 20,
	x        = 70,
	y        = 120,
})

-- TODO get minimaps somehow
--  small translucent info overlay over minimap (wind, size, teams, etc..)
--  get and show team start boxes, or at least start positions
--  add tabpanel to include: Minimap, Metalmap, infomap

local MapList = ScrollPanel:New{
	parent = match,
	name   = 'Map Selection',
	right  = 0,
	width  = 200,
	height = '50%',
	y      = 0,
	children = {Label:New{caption = '-- Select Map --', y = 6, fontSize = 18,  x = '0%', width = '100%', align = 'center'}}
}

local GameList = ScrollPanel:New{
	name   = 'Game Selection',
	parent = match,
	right  = 0,
	width  = 200,
	height = '49%',
	bottom = 0,
	children = {Label:New{caption = '-- Select Game --', y = 6, fontSize = 18,  x = '0%', width = '100%', align = 'center'}}
}

-- fill list of maps
for _, name in pairs(VFS.GetMaps()) do
	local info = VFS.GetArchiveInfo(name)
	MapList:AddChild(Button:New{
		caption  = info.name,
		x        = 0,
		y        = #MapList.children * 30,
		width    = '100%',
		height   = 26,
		OnClick = {
			function(self)
				Match.Script.mapname = info.name
				Match:GetChildByName('MapName'):SetCaption(info.name)
			end
		}
	})
end

-- fill list of games
for _, name in pairs(VFS.GetGames()) do
	local info = VFS.GetArchiveInfo(name)
	GameList:AddChild(Button:New{
		caption  = info.name,
		x        = 0,
		y        = #GameList.children * 30,
		width    = '100%',
		height   = 26,
		OnClick = {
			function(self)
				for key, data in pairs(info) do Spring.Echo(key .. ' = ' .. data) end
				Match.Script.gametype = info.name
				Match:GetChildByName('Game Name'):SetCaption(info.name_pure)
			end
		}
	})
end

Match:AddChild(MapList)
Match:AddChild(GameList)

-- Control will essentially attached to a Menu button
return Match
