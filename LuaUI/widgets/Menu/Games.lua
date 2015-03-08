local Match = Window:New{
	name = 'Games',
	x      = Center(400).x,
	y      = Center(400).y,
	height = 400,
	width  = 400,
	padding = {5,5,5,5},
	bots = {},
	botNames = {'Fred','Fred Jr.','Steve','John','Greg'},
	allyTeams = 0,
	Script = {
		player0  =  {
			isfromdemo = 0,
			name = 'Local',
			rank = 0,
			spectator = 1,
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

		gametype = Settings['game'] or 'Pick A Game',
		hostip = '127.0.0.1',
		hostport = 8452,
		ishost = 1,
		mapname = 'Blank v1',
		myplayername = 'Local',
		nohelperais = 0,
		numplayers = 1,
		numusers = 2,
		startpostype = 2,
	}
}

-- Adds bots to script table, then starts the game with a generated script
local function StartScript()
	Spring.Reload(ScriptTXT(Match.Script))
end

local GameList = Stack{
	name   = 'Game Selection',
	parent = match,
	scroll = true,
	x = 0,
	width = '100%',
	children = {Label:New{caption = '-- Select Game --', y = 6, fontSize = 18,  x = '0%', width = '100%', align = 'center'}}
}

-- fill list of games
local function AddGame(info)
	-- info.sides = include(dir .. "gamedata/sidedata.lua")
	if info.modtype == 0 then return end
	info.version = info.version or ''
	GameList:AddChild(Button:New{
		caption  = info.name,
		tooltip  = info.version,
		width    = '100%',
		y        = #GameList.children * 45,
		height   = 40,
		fontSize = 20,
		OnClick = {
			function(self)
				Match.Script.gametype = info.name .. ' ' ..  info.version
				StartScript()
			end
		}
	})
end

for _, dir in pairs(VFS.SubDirs("games/")) do
	if dir:match('.sdd') and VFS.FileExists(dir .. "modinfo.lua") then
		AddGame(include(dir .. "modinfo.lua"))
	end
end

for _, filename in pairs(VFS.DirList("games/")) do
	if filename:match('.sd7') or filename:match('.sdz') then
		AddGame(VFS.UseArchive(filename, function() return include("modinfo.lua") end))
	end
end
----------------------

Match:AddChild(GameList)

-- Control will essentially attached to a Menu button
return Match
