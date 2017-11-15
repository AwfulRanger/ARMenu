include( "vgui/dlistbox.lua" )

language.Add( "armenu_arbrowser.name", "Web Browser" )
language.Add( "armenu_arbrowser.desc", "Enable a button on the main menu that opens a web browser" )

local name = "arbrowser"
AddPlugin( name, {
	
	Name = "#armenu_arbrowser.name",
	Desc = "#armenu_arbrowser.desc",
	OnEnabled = function()
		
		local x = CreateClientConVar( "arbrowser_x", 0.1, true, false, "X position (screen width * this)" )
		local y = CreateClientConVar( "arbrowser_y", 0.1, true, false, "Y position (screen height * this)" )
		local w = CreateClientConVar( "arbrowser_w", 0.8, true, false, "Width (screen width * this)" )
		local h = CreateClientConVar( "arbrowser_h", 0.8, true, false, "Height (screen height * this)" )
		local autopos = CreateClientConVar( "arbrowser_autopos", 1, true, false, "Automatically set position and size to their values when the browser was last exited" )
		local home = CreateClientConVar( "arbrowser_home", "https://www.google.com", true, false, "Page to open when the browser is first opened" )
		local newtab = CreateClientConVar( "arbrowser_newtab", "about:home", true, false, "Page to open for a new tab" )
		local query = CreateClientConVar( "arbrowser_query", "https://www.google.com/search?q=<query>", true, false, "Page to open when searching, <query> will be replaced with the search" )
		local popup = CreateClientConVar( "arbrowser_popup", 1, true, false, "Allow pages to open popups" )
		local opentab = CreateClientConVar( "arbrowser_opentab", 1, true, false, "Allow pages to open tabs" )
		local lua = CreateClientConVar( "arbrowser_lua", 0, true, false, "Allow pages to run Lua" )
		local log = CreateClientConVar( "arbrowser_log", 0, true, false, "Print log messages to the console" )
		local logsize = CreateClientConVar( "arbrowser_logsize", 100, true, false, "How many logged messages to store" )
		local optionsize = CreateClientConVar( "arbrowser_optionsize", 0.4, true, false, "Options menu size" )

		local function addtab( frame, sheet, url )
			
			if url == nil then url = "" end
			if url == "about:home" then url = home:GetString() end
			if url != "" and string.find( url, "%." ) == nil and string.find( url, ":" ) == nil then url = string.Replace( query:GetString(), "<query>", url ) end
			
			local panel = vgui.Create( "DPanel" )
			
			local html = vgui.Create( "DHTML" )
			html:SetParent( panel )
			html:Dock( FILL )
			html:SetAllowLua( lua:GetBool() )
			html:OpenURL( url )
			
			local control = vgui.Create( "DPanel" )
			control:SetParent( panel )
			control:Dock( TOP )
			
			local search = vgui.Create( "DTextEntry" )
			search:SetParent( control )
			search:Dock( FILL )
			function search:OnEnter()
				
				local url_ = self:GetValue()
				if string.find( url_, "%." ) == nil and string.find( url_, ":" ) == nil then url_ = string.Replace( query:GetString(), "<query>", url_ ) end
				html:OpenURL( url_ )
				
			end
			
			local back = vgui.Create( "DButton" )
			back:SetParent( control )
			back:Dock( LEFT )
			back:SetImage( "icon16/arrow_left.png" )
			back:SetText( "" )
			function back:DoClick()
				
				html:GoBack()
				
			end
			back:SetWide( back:GetTall() )
			
			local forward = vgui.Create( "DButton" )
			forward:SetParent( control )
			forward:Dock( LEFT )
			forward:SetImage( "icon16/arrow_right.png" )
			forward:SetText( "" )
			function forward:DoClick()
				
				html:GoForward()
				
			end
			forward:SetWide( forward:GetTall() )
			
			local refresh = vgui.Create( "DButton" )
			refresh:SetParent( control )
			refresh:Dock( RIGHT )
			refresh:SetImage( "icon16/arrow_refresh.png" )
			refresh:SetText( "" )
			function refresh:DoClick()
				
				html:Refresh()
				
			end
			refresh:SetWide( refresh:GetTall() )
			
			local logs = {}
			local tab = sheet:AddSheet( url, panel )
			tab.Tab.browser = {
				
				html = html,
				control = control,
				search = search,
				back = back,
				forward = forward,
				refresh = refresh,
				logs = logs,
				
			}
			function html:OnBeginLoadingDocument( doc )
				
				search:SetValue( doc )
				
				refresh:SetImage( "icon16/cross.png" )
				function refresh:DoClick()
					
					html:OpenURL( "" )
					
				end
				
				http.Fetch( doc, function( body, size, headers, code )
					
					tab.Tab.browser.body = body
					
				end, function( msg )
					
					print( msg )
					
				end, {
					
					[ "User-Agent" ] = "ARBrowser",
					
				} )
				
			end
			function html:OnFinishLoadingDocument( doc )
				
				refresh:SetImage( "icon16/arrow_refresh.png" )
				function refresh:DoClick()
					
					html:Refresh()
					
				end
				
			end
			function tab.Tab:DoClick()
				
				sheet:SetActiveTab( self )
				frame:SetTitle( "ARBrowser (" .. self:GetText() .. ")" )
				
			end
			function tab.Tab:DoRightClick()
				
				local menu = vgui.Create( "DMenu" )
				local mx, my = gui.MousePos()
				menu:SetPos( mx, my )
				
				menu:AddOption( "Remove", function()
					
					if #sheet.Items <= 1 then
						
						addtab( frame, sheet, newtab:GetString() )
						
					end
					sheet:CloseTab( self, true )
					
				end )
				
				menu:Open()
				
			end
			
			function html:OnChangeTitle( title )
				
				tab.Tab:SetText( title )
				tab.Tab:SetTooltip( title .. " (" .. search:GetValue() .. ")" )
				sheet.tabScroller:InvalidateLayout( true )
				
				if sheet:GetActiveTab() == tab.Tab then
					
					frame:SetTitle( "ARBrowser (" .. title .. ")" )
					
				end
				
			end
			
			function html:OnChildViewCreated( source, target, ispopup )
				
				if ispopup == true then
					
					if popup:GetBool() == true then
						
						ARBrowser:CreateBrowser( target )
						
					else
						
						print( source, "attempting to open popup", target )
						
					end
					
				else
					
					if opentab:GetBool() == true then
						
						addtab( frame, sheet, target )
						
					else
						
						print( source, "attempting to open tab", target )
						
					end
					
				end
				
			end
			
			local function dolog( msg )
				
				table.insert( logs, msg )
				while #logs > logsize:GetInt() do table.remove( logs ) end
				
			end
			
			function html:ConsoleMessage( msg, file, line )
				
				if isstring( msg ) != true then msg = "*js variable*" end
				
				if isstring( file ) == true and isnumber( line ) == true then
					
					if #file > 64 then file = string.sub( file, 1, 64 ) .. "..." end
					dolog( file .. ":" .. line .. ": " .. msg )
					if log:GetBool() == true then MsgC( Color( 255, 160, 255 ), "[HTML] ", Color( 255, 255, 255 ), file, ":", line, ": ", msg, "\n" ) end
					return
					
				end
				
				dolog( msg )
				
				if lua:GetBool() == true and msg:StartWith( "RUNLUA:" ) == true then
					
					SELF = self
					RunString( msg:sub( 8 ) )
					SELF = nil
					return
					
				end
				
				if log:GetBool() == true then MsgC( Color( 255, 160, 255 ), "[HTML] ", Color( 255, 255, 255 ), msg, "\n" ) end
				
			end
			
		end

		ARBrowser = {}
		ARBrowser.Browsers = {}

		local lastframe = 0
		hook.Add( "CreateMove", "ARBrowser_CreateMove", function( cmd )
			
			if lastframe == CurTime() then return end
			lastframe = CurTime()
			
			local m4 = input.WasMousePressed( MOUSE_4 )
			local m5 = input.WasMousePressed( MOUSE_5 )
			
			if m4 == true or m5 == true then
				
				for i = 1, #ARBrowser.Browsers do
					
					local frame = ARBrowser.Browsers.frame
					if IsValid( frame ) != true then return end
					local sheet = ARBrowser.Browsers.sheet
					if IsValid( sheet ) != true then return end
					local tab = sheet:GetActiveTab()
					if IsValid( tab ) != true or tab.browser == nil then return end
					local html = tab.browser.html
					if IsValid( html ) != true then return end
					
					local mx, my = gui.MousePos()
					local fx, fy, fw, fh = frame:GetBounds()
					if mx >= fx and my >= fy and mx <= fx + fw and my <= fy + fh then
						
						if m4 == true then html:GoBack() end
						if m5 == true then html:GoForward() end
						
					end
					
				end
				
			end
			
		end )

		function ARBrowser:CreateBrowser( url )
			
			local tbl = {}
			local id = #self.Browsers + 1
			
			local frame = vgui.Create( "DFrame" )
			frame:SetPos( ScrW() * x:GetFloat(), ScrH() * y:GetFloat() )
			frame:SetSize( ScrW() * w:GetFloat(), ScrH() * h:GetFloat() )
			frame:SetTitle( "ARBrowser" )
			frame:SetSizable( true )
			frame:SetDraggable( true )
			frame:MakePopup()
			function frame:OnRemove()
				
				if autopos:GetBool() == true then
					
					local px, py, pw, ph = self:GetBounds()
					RunConsoleCommand( x:GetName(), px / ScrW() )
					RunConsoleCommand( y:GetName(), py / ScrH() )
					RunConsoleCommand( w:GetName(), pw / ScrW() )
					RunConsoleCommand( h:GetName(), ph / ScrH() )
					
				end
				
				table.remove( ARBrowser.Browsers, id )
				
			end
			tbl.frame = frame
			
			frame.btnMinim:SetDisabled( false )
			function frame.btnMinim:DoClick()
				
				frame:SetVisible( false )
				
			end
			
			local sheet = vgui.Create( "DPropertySheet" )
			sheet:SetParent( frame )
			sheet:Dock( FILL )
			sheet:SetPadding( 0 )
			tbl.sheet = sheet
			
			local new = vgui.Create( "DButton" )
			new:SetParent( frame )
			new:SetImage( "icon16/add.png" )
			new:SetText( "" )
			function new:DoClick()
				
				addtab( frame, sheet, newtab:GetString() )
				
			end
			function new:Think()
				
				local pl, pt, pr, pb = frame:GetDockPadding()
				local px, py = sheet:GetPos()
				self:SetPos( sheet.tabScroller:GetWide() + pr, py )
				
			end
			new:SetWide( new:GetTall() )
			
			local opt = vgui.Create( "DButton" )
			opt:SetParent( frame )
			opt:SetImage( "icon16/wrench.png" )
			opt:SetText( "" )
			function opt:DoClick()
				
				if IsValid( tbl.menu ) == true then
					
					tbl.menu:Remove()
					
				else
					
					tbl.menu = vgui.Create( "DPanel" )
					tbl.menu:SetParent( frame )
					tbl.menu:Dock( RIGHT )
					function tbl.menu:Think()
						
						self:SetWide( frame:GetWide() * optionsize:GetFloat() )
						
					end
					
					local scroll = vgui.Create( "DScrollPanel" )
					scroll:SetParent( tbl.menu )
					scroll:Dock( FILL )
					
					local o = vgui.Create( "DForm" )
					o:SetParent( scroll )
					o:Dock( TOP )
					o:SetExpanded( false )
					o:SetLabel( "Options" )
					o:CheckBox( "Remember position", autopos:GetName() ):SetTooltip( autopos:GetHelpText() )
					local home1, home2 = o:TextEntry( "Home page", home:GetName() )
					home1:SetTooltip( home:GetHelpText() )
					home2:SetTooltip( home:GetHelpText() )
					local newtab1, newtab2 = o:TextEntry( "New tab", newtab:GetName() )
					newtab1:SetTooltip( newtab:GetHelpText() )
					newtab2:SetTooltip( newtab:GetHelpText() )
					local query1, query2 = o:TextEntry( "Query", query:GetName() )
					query1:SetTooltip( query:GetHelpText() )
					query2:SetTooltip( query:GetHelpText() )
					o:CheckBox( "Enable popups", popup:GetName() ):SetTooltip( popup:GetHelpText() )
					o:CheckBox( "Enable popup tabs", opentab:GetName() ):SetTooltip( opentab:GetHelpText() )
					o:CheckBox( "Enable Lua", lua:GetName() ):SetTooltip( lua:GetHelpText() )
					o:CheckBox( "Log to console", log:GetName() ):SetTooltip( log:GetHelpText() )
					o:NumberWang( "Log size", logsize:GetName(), 0, 9999, 0 ):SetTooltip( logsize:GetHelpText() )
					
					local l = vgui.Create( "DForm" )
					l:SetParent( scroll )
					l:Dock( TOP )
					l:SetExpanded( false )
					l:SetLabel( "Logs" )
					local listbox = l:ListBox( "" )
					local logs = sheet:GetActiveTab().browser.logs
					local h = 0
					for i = 1, #logs do
						
						local item = listbox:AddItem( logs[ i ] )
						if item:GetTall() > h then h = item:GetTall() end
						
					end
					listbox:SetTall( h * 10 )
					
					local b = vgui.Create( "DForm" )
					b:SetParent( scroll )
					b:Dock( TOP )
					b:SetExpanded( false )
					b:SetLabel( "Body" )
					local body = vgui.Create( "DTextEntry" )
					body:Dock( FILL )
					body:SetTall( ScrH() * 0.3 )
					body:SetMultiline( true )
					body:SetVerticalScrollbarEnabled( true )
					body:SetEditable( false )
					local bodystr = tostring( sheet:GetActiveTab().browser.body )
					body:SetText( bodystr )
					b:AddItem( body )
					
				end
				
			end
			function opt:Think()
				
				local pl, pt, pr, pb = frame:GetDockPadding()
				local px, py = sheet:GetPos()
				self:SetPos( sheet.tabScroller:GetWide() + new:GetWide() + pr, py )
				
			end
			opt:SetWide( opt:GetTall() )
			
			sheet.tabScroller:DockMargin( 0, 0, new:GetWide() + opt:GetWide(), 0 )
			
			frame:SetMinWidth( new:GetWide() * 10 )
			frame:SetMinHeight( new:GetTall() * 10 )
			
			if url == nil or url == "" then url = "about:home" end
			addtab( frame, sheet, url )
			
			self.Browsers[ id ] = tbl
			
		end

		function ARBrowser:Unhide()
			
			for i = 1, #self.Browsers do
				
				local frame = self.Browsers[ i ].frame
				if IsValid( frame ) == true then frame:SetVisible( true ) frame:MakePopup() end
				
			end
			
		end

		concommand.Add( "arbrowser_open", function( ply, cmd, args, arg ) ARBrowser:CreateBrowser( arg ) end )
		concommand.Add( "arbrowser_unhide", function( ply, cmd, args, arg ) ARBrowser:Unhide() end )
		
		hook.Add( "PreCreateMenuButtons", name, function()
			
			local button = vgui.Create( "MainMenuButton" )
			button:SetText( "#armenu_arbrowser.name" )
			function button:DoClick()
				
				if #ARBrowser.Browsers > 0 then
					
					RunConsoleCommand( "arbrowser_unhide" )
					
				else
					
					RunConsoleCommand( "arbrowser_open" )
					
				end
				
			end
			AddMenuButton( button, 190 )
			
		end )
		
		local canvas = GetMenuButtonCanvas()
		if IsValid( canvas ) == true then canvas:CreateChildren() end
		
	end,
	OnDisabled = function()
		
		concommand.Remove( "arbrowser_open" )
		concommand.Remove( "arbrowser_unhide" )
		hook.Remove( "PreCreateMenuButtons", name )
		
		local canvas = GetMenuButtonCanvas()
		if IsValid( canvas ) == true then canvas:CreateChildren() end
		
	end,
	
} )