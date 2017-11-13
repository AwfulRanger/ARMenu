language.Add( "armenu_plugins", "Plugins" )

local enabled = util.JSONToTable( file.Read( "armenu/plugins.dat" ) or "" ) or {}
local plugins = {}

local function getenabled( name )
	
	return enabled[ name ] or false
	
end

local function setenabled( name, bool )
	
	enabled[ name ] = bool
	file.Write( "armenu/plugins.dat", util.TableToJSON( enabled ) )
	local plugin = plugins[ name ]
	if plugin != nil then
		
		if bool == true and plugin.OnEnabled != nil then
			
			plugin.OnEnabled()
			
		elseif bool != true and plugin.OnDisabled != nil then
			
			plugin.OnDisabled()
			
		end
		
	end
	
end

function AddPlugin( name, tbl )
	
	plugins[ name ] = tbl
	
end

local _, plugindir = file.Find( "lua/menu/armenu/plugins/*", "GAME" )
for i = 1, #plugindir do
	
	local path = "menu/armenu/plugins/" .. plugindir[ i ] .. "/" .. plugindir[ i ] .. ".lua"
	if file.Exists( "lua/" .. path, "GAME" ) == true then include( path ) end
	
end

hook.Add( "MenuLoaded", "Plugins", function()
	
	for _, v in pairs( plugins ) do
		
		if enabled[ _ ] == true and v.OnEnabled != nil then v.OnEnabled() end
		
	end
	
end )

local menu
hook.Add( "PreCreateMenuButtons", "Plugins", function()
	
	pluginbutton = vgui.Create( "MainMenuButton" )
	pluginbutton:SetText( "#armenu_plugins" )
	function pluginbutton:DoClick()
		
		if IsValid( menu ) == true then menu:Remove() end
		menu = vgui.Create( "DFrame" )
		menu:SetSize( ScrW() * 0.4, ScrH() * 0.8 )
		menu:Center()
		menu:SetTitle( "#armenu_plugins" )
		menu:SetSizable( true )
		menu:MakePopup()
		
		local scroll = vgui.Create( "DScrollPanel" )
		scroll:SetParent( menu )
		scroll:Dock( FILL )
		
		local dock = ScrH() * 0.005
		
		for _, v in pairs( plugins ) do
			
			local panel = vgui.Create( "DPanel" )
			panel:SetParent( scroll )
			panel:Dock( TOP )
			panel:DockPadding( dock, dock, dock, dock )
			panel:SetTall( ScrH() * 0.1 )
			
			local top = vgui.Create( "DPanel" )
			top:SetParent( panel )
			top:Dock( TOP )
			top:DockMargin( 0, 0, 0, dock )
			function top:Paint( w, h )
			end
			
			local title = vgui.Create( "DLabel" )
			title:SetParent( top )
			title:Dock( FILL )
			title:SetTextColor( MenuColor.fg_alt )
			title:SetText( v.Name or "" )
			
			local check = vgui.Create( "DCheckBox" )
			check:SetParent( top )
			check:Dock( RIGHT )
			check:SetValue( getenabled( _ ) )
			function check:OnChange( bool )
				
				setenabled( _, bool )
				
			end
			check:InvalidateParent( true )
			check:SetWide( check:GetTall() )
				
			
			local c = MenuColor.fg_alt
			
			local desc = vgui.Create( "RichText" )
			desc:SetParent( panel )
			desc:Dock( FILL )
			desc:InsertColorChange( c.r, c.g, c.b, c.a )
			desc:AppendText( v.Desc or "" )
			
		end
		
	end
	AddMenuButton( pluginbutton, 700 )
	
end )