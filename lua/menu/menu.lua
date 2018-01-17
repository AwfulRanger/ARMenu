file.CreateDir( "armenu" )
if file.Exists( "armenu/enabled.dat", "DATA" ) ~= true then file.Write( "armenu/enabled.dat", "true" ) end

local enabled = tobool( file.Read( "armenu/enabled.dat", "DATA" ) )

concommand.Add( "armenu_toggle", function( ply, cmd, args, arg )
	
	--Clear old panels
	local panels = vgui.GetWorldPanel():GetChildren()
	for i = 1, #panels do
		
		if IsValid( panels[ i ] ) == true then panels[ i ]:Remove() end
		panels[ i ] = nil
		
	end
	
	if enabled ~= true then
		
		include( "menu/armenu/menu.lua" )
		enabled = true
		print( "ARMenu enabled" )
		
	else
		
		include( "menu/menu_default.lua" )
		enabled = false
		print( "ARMenu disabled" )
		
	end
	
	file.Write( "armenu/enabled.dat", tostring( enabled ) )
	
end, nil, "Toggle ARMenu (restarting is recommended)" )


if enabled == true then
	
	include( "armenu/menu.lua" )
	
else
	
	include( "menu_default.lua" )
	
end