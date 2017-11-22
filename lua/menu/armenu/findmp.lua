--TODO: search bar
--TODO: add gamemode icons
local PANEL = {}



language.Add( "armenu_gamemodename", "Gamemode" )
language.Add( "armenu_gamemodeplayers", "Players" )
language.Add( "armenu_gamemodeservers", "Servers" )

language.Add( "armenu_serverhaspass", "Has password" )

local curquery
local curgamemode
local active = false
local stop = false
local servertbl = {}
local playerstbl = {}

function PANEL:CreateServers( gm )
	
	curgamemode = gm
	
	if IsValid( self.servers ) == true then self.servers:Remove() end
	
	local pad = ScrH() * 0.01
	
	self.server = vgui.Create( "DListView" )
	self.server:SetParent( self )
	self.server:Dock( FILL )
	self.server:DockMargin( pad, 0, pad, 0 )
	function self.server:Paint( w, h )
		
		draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdull )
		
	end
	local servername = self.server:AddColumn( "#server_name_header" )
	function servername.Header:Paint( w, h )
		
		draw.RoundedBoxEx( 4, 0, 0, w, h, MenuColor.bgdull, true, false, false, false )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local mapname = self.server:AddColumn( "#server_mapname" )
	function mapname.Header:Paint( w, h )
		
		surface.SetDrawColor( MenuColor.bgdull )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local players = self.server:AddColumn( "#server_players" )
	function players.Header:Paint( w, h )
		
		surface.SetDrawColor( MenuColor.bgdull )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local ping = self.server:AddColumn( "#server_ping" )
	function ping.Header:Paint( w, h )
		
		surface.SetDrawColor( MenuColor.bgdull )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local haspass = self.server:AddColumn( "#armenu_serverhaspass" )
	function haspass.Header:Paint( w, h )
		
		draw.RoundedBoxEx( 4, 0, 0, w, h, MenuColor.bgdull, false, true, false, false )
		
	end
	
	timer.Simple( 0, function()
		
		if IsValid( players ) == true then players:SetWidth( 0 ) end
		if IsValid( ping ) == true then ping:SetWidth( 0 ) end
		if IsValid( haspass ) == true then haspass:SetWidth( 0 ) end
		
	end )
	
	if gm != nil and servertbl[ gm ] != nil then
		
		for i = 1, #servertbl[ gm ] do
			
			local tbl = servertbl[ gm ][ i ]
			
			local button = self.server:AddLine( tbl.name, tbl.map, tbl.players .. "/" .. tbl.maxplayers, tbl.ping, ( tbl.pass == true and "✓" ) or "✘" )
			function button.OnSelect()
				
				self:CreateInfo( tbl.address, tbl.name, tbl.map, tbl.pass )
				
			end
			
		end
		
	end
	
end

local function newcategory( name, tbl, parent, panel )
	
	if IsValid( parent ) != true then return end
	
	local playernum = playerstbl[ name ] or 0
	local servernum = #tbl
	
	local button = parent:AddLine( name, playernum, servernum )
	button.playernum = playernum
	button.servernum = servernum
	local paint = button.Paint
	function button:Paint( ... )
		
		paint( self, ... )
		
		local playernum = playerstbl[ name ] or 0
		local servernum = #tbl
		
		if playernum != self.playernum then
			
			self:SetColumnText( 2, playernum )
			self.playernum = playernum
			
		end
		if servernum != self.servernum then
			
			self:SetColumnText( 3, servernum )
			self.servernum = servernum
			
		end
		
	end
	function button:OnSelect()
		
		panel:CreateServers( name )
		
	end
	
	return button
	
end

function PANEL:CreateList( query )
	
	servertbl = {}
	playerstbl = {}
	active = true
	
	if query == nil then query = curquery end
	if query == nil then query = "internet" end
	curquery = query
	
	if IsValid( self.categories ) == true then self.categories:Remove() end
	if IsValid( self.servers ) == true then self.servers:Remove() end
	
	self.categories = vgui.Create( "DListView" )
	self.categories:SetParent( self.catbg )
	self.categories:Dock( FILL )
	self.categories:DockMargin( 0, ScrH() * 0.01, 0, 0 )
	self.categories:SetMultiSelect( false )
	function self.categories:Paint( w, h )
		
		draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdull )
		
	end
	
	local name = self.categories:AddColumn( "#armenu_gamemodename" )
	function name.Header:Paint( w, h )
		
		draw.RoundedBoxEx( 4, 0, 0, w, h, MenuColor.bgdull, true, false, false, false )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local players = self.categories:AddColumn( "#armenu_gamemodeplayers" )
	function players.Header:Paint( w, h )
		
		surface.SetDrawColor( MenuColor.bgdull )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local servers = self.categories:AddColumn( "#armenu_gamemodeservers" )
	function servers.Header:Paint( w, h )
		
		draw.RoundedBoxEx( 4, 0, 0, w, h, MenuColor.bgdull, false, true, false, false )
		
	end
	
	timer.Simple( 0, function()
		
		if IsValid( players ) == true then players:SetWidth( 0 ) end
		if IsValid( servers ) == true then servers:SetWidth( 0 ) end
		
	end )
	
	serverlist.Query( {
		
		Type = query,
		Callback = function( ping, name, desc, map, players, maxplayers, botplayers, pass, lastplayed, address, gm, workshopid )
			
			if stop == true or curquery != query then
				
				stop = false
				return false
				
			end
			
			if servertbl[ desc ] == nil then
				
				servertbl[ desc ] = {}
				newcategory( desc, servertbl[ desc ], self.categories, self )
				
			end
			if playerstbl[ desc ] == nil then playerstbl[ desc ] = 0 end
			playerstbl[ desc ] = playerstbl[ desc ] + players
			table.insert( servertbl[ desc ], {
				
				ping = ping,
				name = name,
				desc = desc,
				map = map,
				players = players,
				maxplayers = maxplayers,
				botplayers = botplayers,
				pass = pass,
				lastplayed = lastplayed,
				address = address,
				gm = gm,
				workshopid = workshopid,
				
			} )
			if desc == curgamemode then self.server:AddLine( name, map, players .. "/" .. maxplayers, ping, ( pass == true and "✓" ) or "✘" ) end
			
		end,
		Finished = function()
			
			active = false
			
		end,
		
	} )
	
end

local function hms( seconds )
	
	local h = math.floor( seconds / ( 60 * 60 ) )
	seconds = seconds - ( h * ( 60 * 60 ) )
	local m = math.floor( seconds / 60 )
	seconds = seconds - ( m * 60 )
	
	return string.format( "%02i:%02i:%02i", h, m, seconds )
	
end

function PANEL:CreateInfo( ip, name, map, pass )
	
	if IsValid( self.info ) == true then self.info:Remove() end
	
	local pad = ScrW() * 0.0025
	
	self.info = vgui.Create( "DPanel" )
	self.info:SetParent( self )
	self.info:Dock( RIGHT )
	self.info:SetWide( ScrW() * 0.15 )
	function self.info:Paint( w, h )
		
		draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdull )
		
	end
	
	if name != nil then
		
		local namelabel = vgui.Create( "DLabel" )
		namelabel:SetParent( self.info )
		namelabel:Dock( TOP )
		namelabel:DockMargin( pad, 0, pad, 0 )
		namelabel:SetText( name or "" )
		namelabel:SetTextColor( MenuColor.fg_alt )
		
	end
	if ip != nil then
		
		local iplabel = vgui.Create( "DLabel" )
		iplabel:SetParent( self.info )
		iplabel:Dock( TOP )
		iplabel:DockMargin( pad, 0, pad, 0 )
		iplabel:SetText( ip or "" )
		iplabel:SetTextColor( MenuColor.fg_alt )
		
	end
	if map != nil then
		
		local maplabel = vgui.Create( "DLabel" )
		maplabel:SetParent( self.info )
		maplabel:Dock( TOP )
		maplabel:DockMargin( pad, 0, pad, 0 )
		maplabel:SetText( map or "" )
		maplabel:SetTextColor( MenuColor.fg_alt )
		
	end
	local passentry
	if pass == true then
		
		local passlabel = vgui.Create( "DLabel" )
		passlabel:SetParent( self.info )
		passlabel:Dock( TOP )
		passlabel:DockMargin( pad, pad, pad, 0 )
		passlabel:SetText( "#server_password" )
		passlabel:SetTextColor( MenuColor.fg_alt )
		
		passentry = vgui.Create( "DTextEntry" )
		passentry:SetParent( self.info )
		passentry:Dock( TOP )
		passentry:DockMargin( pad, 0, pad, 0 )
		
	end
	
	if ip != nil then
		
		local joinpad = ScrH() * 0.01
		local join = vgui.Create( "DButton" )
		join:SetParent( self.info )
		join:Dock( BOTTOM )
		join:DockMargin( joinpad, joinpad, joinpad, joinpad )
		join:SetText( "" )
		join:SetTall( ScrH() * 0.05 )
		function join:Paint( w, h )
			
			local color = MenuColor.bg_alt
			if self:IsHovered() == true then color = MenuColor.active end
			if self:IsDown() == true then color = MenuColor.selected end
			draw.RoundedBox( 4, 0, 0, w, h, color )
			
			surface.SetFont( "DermaLarge" )
			local tw, th = surface.GetTextSize( "#servers_join_server" )
			surface.SetTextPos( ( w * 0.5 ) - ( tw * 0.5 ), ( h * 0.5 ) - ( th * 0.5 ) )
			surface.SetTextColor( MenuColor.fg_alt )
			surface.DrawText( "#servers_join_server" )
			
		end
		function join:DoClick()
			
			if IsValid( passentry ) == true then RunConsoleCommand( "password", passentry:GetValue() ) end
			JoinServer( ip )
			
		end
		
	end
	
	local listview = vgui.Create( "DListView" )
	listview:SetParent( self.info )
	listview:Dock( FILL )
	listview:DockMargin( 0, pad, 0, 0 )
	listview:SetMultiSelect( false )
	function listview:Paint( w, h )
	end
	local name = listview:AddColumn( "#playerlist_name" )
	function name.Header:Paint( w, h )
		
		draw.RoundedBoxEx( 4, 0, 0, w, h, MenuColor.bgdull, true, false, false, false )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local score = listview:AddColumn( "#playerlist_score" )
	function score.Header:Paint( w, h )
		
		surface.SetDrawColor( MenuColor.bgdull )
		surface.DrawRect( 0, 0, w, h )
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawRect( w - 1, 0, 1, h )
		
	end
	local time = listview:AddColumn( "#playerlist_time" )
	function time.Header:Paint( w, h )
		
		draw.RoundedBoxEx( 4, 0, 0, w, h, MenuColor.bgdull, false, true, false, false )
		
	end
	
	timer.Simple( 0, function()
		
		if IsValid( score ) == true then score:SetWidth( 0 ) end
		if IsValid( time ) == true then time:SetWidth( 0 ) end
		
	end )
	
	if ip != nil then
		
		serverlist.PlayerList( ip, function( tbl )
			
			if IsValid( self.info ) == true then
				
				local curtime = CurTime()
				
				for i = 1, #tbl do
					
					local line = listview:AddLine( tbl[ i ].name, tbl[ i ].score, hms( tbl[ i ].time ) )
					local paint = line.Paint
					function line:Paint( ... )
						
						paint( self, ... )
						
						self:SetColumnText( 3, hms( tbl[ i ].time + ( CurTime() - curtime ) ) )
						
					end
					
				end
				
			end
			
		end )
		
	end
	
end

function PANEL:MenuSetup()
	
	local pad = ScrH() * 0.01
	self:DockPadding( pad, pad, pad, pad )
	
	self.catbg = vgui.Create( "DPanel" )
	self.catbg:SetParent( self )
	self.catbg:Dock( LEFT )
	self.catbg:DockPadding( pad, pad, pad, pad )
	self.catbg:SetWide( ScrW() * 0.15 )
	function self.catbg:Paint( w, h )
	end
	
	self:CreateList()
	
	local internetbutton = vgui.Create( "DButton" )
	internetbutton:SetParent( self.catbg )
	internetbutton:Dock( TOP )
	internetbutton:SetText( "#servers_internet" )
	internetbutton:SetFont( "DermaDefaultBold" )
	function internetbutton:Paint( w, h )
	end
	function internetbutton.DoClick()
		
		self:CreateInfo()
		self:CreateServers()
		self:CreateList( "internet" )
		
	end
	
	local favoritebutton = vgui.Create( "DButton" )
	favoritebutton:SetParent( self.catbg )
	favoritebutton:Dock( TOP )
	favoritebutton:SetText( "#servers_favorites" )
	favoritebutton:SetFont( "DermaDefaultBold" )
	function favoritebutton:Paint( w, h )
	end
	function favoritebutton.DoClick()
		
		self:CreateInfo()
		self:CreateServers()
		self:CreateList( "favorite" )
		
	end
	
	local historybutton = vgui.Create( "DButton" )
	historybutton:SetParent( self.catbg )
	historybutton:Dock( TOP )
	historybutton:SetText( "#servers_history" )
	historybutton:SetFont( "DermaDefaultBold" )
	function historybutton:Paint( w, h )
	end
	function historybutton.DoClick()
		
		self:CreateInfo()
		self:CreateServers()
		self:CreateList( "history" )
		
	end
	
	local lanbutton = vgui.Create( "DButton" )
	lanbutton:SetParent( self.catbg )
	lanbutton:Dock( TOP )
	lanbutton:SetText( "#servers_local" )
	lanbutton:SetFont( "DermaDefaultBold" )
	function lanbutton:Paint( w, h )
	end
	function lanbutton.DoClick()
		
		self:CreateInfo()
		self:CreateServers()
		self:CreateList( "lan" )
		
	end
	
	local refresh = vgui.Create( "DButton" )
	refresh:SetParent( self.catbg )
	refresh:Dock( TOP )
	refresh:DockMargin( 0, ScrH() * 0.01, 0, 0 )
	refresh:SetText( "#servers_refresh" )
	refresh:SetFont( "DermaDefaultBold" )
	function refresh:Paint( w, h )
		
		if active != self.active then
			
			self.active = active
			
			if active == true then
				
				self:SetText( "#servers_stoprefresh" )
				
			else
				
				self:SetText( "#servers_refresh" )
				
			end
			
		end
		
	end
	function refresh.DoClick()
		
		if active == true then
			
			stop = true
			active = false
			
		else
			
			self:CreateInfo()
			self:CreateServers()
			self:CreateList()
			
		end
		
	end
	
	local legacy = vgui.Create( "DButton" )
	legacy:SetParent( self.catbg )
	legacy:Dock( TOP )
	legacy:SetText( "#legacy_browser" )
	legacy:SetFont( "DermaDefaultBold" )
	function legacy:Paint( w, h )
	end
	function legacy:DoClick()
		
		RunConsoleCommand( "gamemenucommand", "openserverbrowser" )
		
	end
	
	self:CreateInfo()
	self:CreateServers()
	
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 8, 0, 0, w, h, MenuColor.bg_alt )
	
end



vgui.Register( "MainMenu_FindMP", PANEL, "EditablePanel" )