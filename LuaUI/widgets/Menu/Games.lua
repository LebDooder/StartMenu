local Match = Window:New{
	name = 'Launch Game',
	panelWidth = 120,
	x = Center(400).x,
	y = Center(400).y,
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

	GameList:AddChild(Button:New{
		caption  = info.game or info.name,
		tooltip  = info.name .. info.description,
		width    = '100%',
		y        = #GameList.children * 45,
		height   = 40,
		fontSize = 20,
		OnClick = {
			function(self)
				Match.Script.gametype = info.name
				StartScript()
			end
		}
	})
end

for _, archive in pairs(VFS.GetAllArchives()) do
	local info = VFS.GetArchiveInfo(archive)
	if info.modtype == 1 then AddGame(info) end
end

----------------------

Match:AddChild(GameList)

-- Control will essentially attached to a Menu button
return Match
