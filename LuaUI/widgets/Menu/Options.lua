local Options = Window:New{
	height = 525,
	width = 400,
	x = Center(400).x,
	y = Center(525).y,
	name = 'Options',
	panelRight = true,
}

Options:AddChild(Stack{
  name = 'Graphics',
  scroll = true,
  x = 0,
  width = '100%',
  children = {
		ComboBox{name='Skin',
				labels=Chili.SkinHandler.GetAvailableSkins()},
		ComboBox{title='Cursor', name = 'CursorName',
				labels={'Chili Default','Chili Static','Spring Default','CA Classic','CA Static','Erom','Masse','K_haos_girl'},
				options={'zk','zk_static','ba','ca','ca_static','erom','masse','k_haos_girl'}},
    ComboBox{title='Water',name = 'Water', --not 'ReflectiveWater' because we use SendCommands instead of SetConfigInt to apply settings (some settings seem to only take effect immediately this way)
      labels={'Basic','Reflective','Dynamic','Refractive','Bump-Mapped'},
      options={0,1,2,3,4},},
    ComboBox{title='Shadows',name='Shadows',
      labels={'Off','On','Units Only'},
      options={0,1,2},},
    ComboBox{title='Shadow Resolution',name='ShadowMapSize',
      labels={'Very Low','Low','Medium','High'},
      options={32,1024,2048,4096},
      OnSelect = function(obj, listID)
        local value = obj.options[listID] or ''
        Spring.SendCommands('Shadows '..Spring.GetConfigInt('Shadows')..' '..value)
        Spring.SetConfigInt('ShadowMapSize', tonumber(value))
      end },
    Slider{name='UnitLodDist',title='Unit Draw Distance', max = 600, step = 1},
    Slider{name='UnitIconDist',title='Unit Icon Distance', max = 600, step = 1},
    Slider{name='MaxParticles',title='Max Particles', max = 5000},
    Slider{name='MaxNanoParticles',title='Max Nano Particles', max = 5000},
    CheckBox{title = 'Advanced Map Shading', name = 'AdvMapShading', tooltip = "Toggle advanced map shading mode"},
    CheckBox{title = 'Advanced Model Shading', name = 'AdvModelShading', tooltip = "Toggle advanced model shading mode"},
    CheckBox{title = 'Deferred Map Shading', name = 'AllowDeferredMapRendering', tooltip = "Toggle deferred model shading mode (requires advanced map shading)"},
    CheckBox{title = 'Deferred Model Shading', name = 'AllowDeferredModelRendering', tooltip = "Toggle deferred model shading mode (requires advanced model shading)"},
    CheckBox{title = 'Draw Engine Trees', name = '3DTrees', tooltip = "Enable/Disable rendering of engine trees"},
    CheckBox{title = 'Dynamic Sky', name = 'DynamicSky', tooltip = "Enable/Disable dynamic-sky rendering"},
    CheckBox{title = 'Dynamic Sun', name = 'DynamicSun', tooltip = "Enable/Disable dynamic-sun rendering"},
    CheckBox{title = 'Show Map Marks', name = 'MapMarks', tooltip = "Enables/Disables rendering of map drawings/marks"},
    CheckBox{title = 'Hide Map Border', name = 'MapBorder', tooltip = "Set or toggle map border rendering"}, --something is weird with parity here
    CheckBox{title = 'Vertical Sync', name = 'VSync', tooltip = "Enables/Disables V-sync"},

  }
})

-- Options:AddChild(Stack{
  -- name = 'Sound',
  -- scroll = true,
  -- x = '60%',
  -- width = '40%'
-- })

return Options
