function widget:GetInfo()
  return {
	name      = 'Chili Markup',
	desc      = 'WIP Chili + markup',
	author    = 'funk',
	date      = 'Dec, 2015',
	license   = 'GPL-v2',
	layer     = 1010,
	enabled   = true,
  handler   = true
  }
end

-- Make WebView_API an HTML widget interface?
--  possibly scan a HTMLwidget directory and handle them

HTML_DIR = 'libs/html/'
HTML_FILE = VFS.LoadFile(HTML_DIR..'Test.html')

function widget:Initialize()
  Chili = WG.Chili
  test = Chili.Markup:New{html = HTML_FILE}
  Chili.Screen0:AddChild(test)
end

function widget:Shutdown()
	test:Dispose()
end
