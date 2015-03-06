local Options = Control:New{
	x = 14, y = 14, right = 0, bottom = 14,
	name = 'Options',
}

Options:AddChild(Stack{
  name = 'Graphics',
  scroll = true,
  x = 0,
  width = '40%',
  children = {
    ComboBox{y=0,title='Water',name='Water', --not 'ReflectiveWater' because we use SendCommands instead of SetConfigInt to apply settings (some settings seem to only take effect immediately this way)
      labels={'Basic','Reflective','Dynamic','Refractive','Bump-Mapped'},
      options={0,1,2,3,4},},
    ComboBox{y=40,title='Shadows',name='Shadows',
      labels={'Off','On','Units Only'},
      options={0,1,2},},
    ComboBox{y=40,title='Shadow Resolution',name='ShadowMapSize', --disabled because it seems this can't be changed ingame
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
