local PANEL = {}



local notinstalled = Material( "../../html/img/notinstalled.png" )
local notowned = Material( "../../html/img/notowned.png" )
local checkmat = Material( "../../html/img/enabled.png" )

local gameicons = {}
local games = engine.GetGames()
table.SortByMember( games, "title", true )
for i = 1, #games do gameicons[ i ] = Material( "games/16/" .. games[ i ].folder .. ".png" ) end

function PANEL:Init()
	
	local pad = ScrH() * 0.005
	
	local scroll = vgui.Create( "DScrollPanel" )
	scroll:SetParent( self )
	scroll:Dock( FILL )
	
	local bgpanel = vgui.Create( "DPanel" )
	bgpanel:SetParent( scroll )
	bgpanel:Dock( FILL )
	function bgpanel:Paint( w, h )
	end
	
	local games = engine.GetGames()
	table.SortByMember( games, "title", true )
	for i = 1, #games do
		
		local panel = vgui.Create( "DPanel" )
		panel:SetParent( bgpanel )
		panel:Dock( TOP )
		panel:DockMargin( pad, pad, pad, 0 )
		panel:SetTall( ScrH() * 0.025 )
		panel:SetTooltip( games[ i ].folder .. " (" .. games[ i ].depot .. ")" )
		function panel:Paint( w, h )
			
			draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bg_alt )
			
		end
		
		local image
		if games[ i ].installed != true then image = notinstalled end
		if games[ i ].owned != true then image = notowned end
		
		local spad = math.Round( panel:GetTall() * 0.1 )
		local s = math.min( 16, panel:GetTall() - ( spad * 2 ) )
		local hpad = math.floor( panel:GetTall() * 0.5 ) - math.Round( s * 0.5 )
		local hpadb = math.ceil( panel:GetTall() * 0.5 ) - math.Round( s * 0.5 )
		local psize = panel:GetTall() - ( spad * 2 )
		if image == nil then
			
			local check = vgui.Create( "DCheckBox" )
			check:SetParent( panel )
			check:Dock( LEFT )
			check:DockMargin( spad, spad, spad, spad )
			check:SetSize( psize, psize )
			check:SetChecked( games[ i ].mounted )
			local tip = "#armenu_unmounted"
			if games[ i ].mounted == true then tip = "#armenu_mounted" end
			check:SetTooltip( tip )
			function check:OnChange( new )
				
				engine.SetMounted( games[ i ].depot, new )
				
				local tip = "#armenu_unmounted"
				if new == true then tip = "#armenu_mounted" end
				self:SetTooltip( tip )
				
			end
			function check:Paint( w, h )
				
				surface.SetDrawColor( MenuColor.fg_alt )
				surface.DrawRect( 0, 0, w, h )
				
				local w_ = math.ceil( w * 0.01 )
				local h_ = math.ceil( h * 0.01 )
				
				surface.SetDrawColor( MenuColor.bg_alt )
				surface.DrawRect( w_, h_, w - ( w_ * 2 ), h - ( h_ * 2 ) )
				
				if self:GetChecked() == true then
					
					local s = math.min( 16, w, h )
					surface.SetDrawColor( MenuColor.white )
					surface.SetMaterial( checkmat )
					surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
					
				end
				
			end
			
		else
			
			local status = vgui.Create( "DImage" )
			status:SetParent( panel )
			status:Dock( LEFT )
			status:DockMargin( spad, hpad, spad, hpad )
			status:SetSize( psize, psize )
			status:SetMaterial( image )
			if games[ i ].owned != true then
				
				status:SetTooltip( "#armenu_notowned" )
				
			elseif games[ i ].installed != true then
				
				status:SetTooltip( "#armenu_notinstalled" )
				
			end
			function status:Paint( w, h )
				
				if self:GetMaterial() != nil then
					
					local s = math.min( 16, w, h )
					surface.SetDrawColor( MenuColor.white )
					surface.SetMaterial( self:GetMaterial() )
					surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
					
				end
				
			end
			
		end
		
		local mat = gameicons[ i ]
		--if mat != nil and mat:IsError() != true then
			
			local icon = vgui.Create( "DImage" )
			icon:SetParent( panel )
			icon:Dock( LEFT )
			icon:DockMargin( 0, hpad, spad, hpadb )
			icon:SetSize( s, s )
			if mat != nil and mat:IsError() != true then icon:SetMaterial( mat ) end
			
		--end
		
		local name = vgui.Create( "DLabel" )
		name:SetParent( panel )
		name:Dock( FILL )
		name:SetText( games[ i ].title )
		name:SetTextColor( MenuColor.fg_alt )
		
	end
	
	bgpanel:InvalidateLayout( true )
	bgpanel:SizeToChildren( false, true )
	bgpanel:SetTall( bgpanel:GetTall() + pad )
	
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdim )
	
end



vgui.Register( "MountMenu", PANEL, "DPanel" )