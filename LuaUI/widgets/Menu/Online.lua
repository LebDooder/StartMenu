local Online = Control:New{
	x = 0, y = 0, right = 0, bottom = 0,
	name = 'Online',
}

local BattleList = WG.BattleList()
Online:AddChild(BattleList.battlePanel)

return Online