local Welcome = Control:New{
	x = 0, y = 0, right = 0, bottom = 0,
	name = 'Welcome',
}

Welcome:AddChild(Image:New{
	x      = 0,
	y      = 0,
	height = 100,
	width  = 100,
	file   = 'LuaUI/images/armcom.dds',
})

Welcome:AddChild(Label:New{caption = 'Welcome',x = 150,fontsize = 75})

return Welcome