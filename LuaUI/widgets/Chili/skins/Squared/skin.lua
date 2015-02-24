
local skin = {
  info = {
    name    = "Squared",
    version = "1",
    author  = "Funk",
		depend = {
      "Robocracy",
    },
  }
}

skin.general = {
  borderColor = {1, 0.5, 0, 1},
  focusColor  = {0.8,0,0,0.6},
  backgroundColor = {0,0,0,0.6},
  draggable   = false,
  font        = {
    color        = {1,1,1,1},
    outline      = false,
    shadow       = false,
    size         = 14,
  },
}

skin.panel = {
	TileImageBK = ":cl:bg.png",
	TileImageFG = ":cl:panel_fg.png",
	tiles = {62, 62, 62, 62},

	backgroundColor = {0.1,0.1,0.4,0.2},
	borderColor = {1,1,1,0.5},

	DrawControl = DrawPanel,
}

skin.scrollpanel = {
	borderColor = {1, 0.5, 0, 0.3},
}

skin.button = {
	TileImageBK = ":cl:bg.png",
	TileImageFG = ":cl:button_fg.png",
	tiles = {26, 26, 26, 26},

	focusColor  = {1, 0.5, 0, 0.6},
	backgroundColor = {1, 0, 0, 0.4},
	borderColor = {1, 0.5, 0, 0.6},

	DrawControl = DrawButton,
}

skin.editbox = {
	borderColor = {1, 0.5, 0, 1},
}

skin.tabbaritem = {
  TileImageBK = ":cl:bg.png",
  TileImageFG = ":cl:tab_fg.png",
  tiles = {32, 32, 32, 0}, --// tile widths: left,top,right,bottom
  padding = {5, 3, 3, 2},

  backgroundColor = {0, 0, 0, 0.5},
  borderColor = {1, 0.5, 0, 1},

  DrawControl = DrawTabBarItem,
}

skin.window = {
  TileImage = ":c:window_fg.png",
  tiles = {62, 62, 62, 62}, --// tile widths: left,top,right,bottom
  padding = {13, 13, 13, 13},
  hitpadding = {4, 4, 4, 4},

  captionColor = {1, 1, 1, 0.45},

  boxes = {
    resize = {-21, -21, -10, -10},
    drag = {0, 0, "100%", 10},
  },

  NCHitTest = NCHitTestWithPadding,
  NCMouseDown = WindowNCMouseDown,
  NCMouseDownPostChildren = WindowNCMouseDownPostChildren,

  DrawControl = DrawWindow,
  DrawDragGrip = function() end,
  DrawResizeGrip = DrawResizeGrip,
}

skin.control = skin.general


return skin
