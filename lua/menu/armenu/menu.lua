concommand.Add( "armenu_reload", function( ply, cmd, args, arg )
	
	--Clear old panels
	local panels = vgui.GetWorldPanel():GetChildren()
	for i = 1, #panels do
		
		if IsValid( panels[ i ] ) == true then panels[ i ]:Remove() end
		panels[ i ] = nil
		
	end
	
	include( "menu/armenu/menu.lua" )
	
end, nil, "Reload ARMenu" )

--[[
concommand.Add( "lua_run_menu", function( ply, cmd, args, arg )
	
	local msg = RunString( arg, "lua_run_menu", false )
	if msg != nil then print( msg ) end
	
end )

concommand.Add( "lua_openscript_menu", function( ply, cmd, args, arg )
	
	if file.Exists( "lua/" .. arg, "GAME" ) == true then
		
		CompileString( file.Read( "lua/" .. arg, "GAME" ), arg )()
		
	else
		
		print( "Couldn't include file '" .. arg .. "' (File not found)" )
		
	end
	
end, function( cmd, arg )
	
	if arg == " " then
		
		arg = ""
		
	else
		
		arg = string.Right( arg, #arg - 1 )
		
	end
	
	local files, dirs = file.Find( "lua/" .. arg .. "*", "GAME" )
	for i = 1, #dirs do dirs[ i ] = dirs[ i ] .. "/" end
	local ret = table.Add( dirs, files )
	for i = 1, #ret do
		
		ret[ i ] = string.GetPathFromFilename( arg ) .. ret[ i ]
		ret[ i ] = cmd .. " " .. ret[ i ]
		
	end
	
	table.insert( ret, "" ) --For some reason the last value in an autocomplete doesn't show
	
	return ret
	
end )
]]--



include( "../mount/mount.lua" )

include( "../getmaps.lua" )
include( "../loading.lua" )
include( "mainmenu.lua" )
include( "../video.lua" )
include( "../demo_to_video.lua" )

include( "../menu_save.lua" )
include( "../menu_demo.lua" )
include( "../menu_addon.lua" )
include( "../menu_dupe.lua" )
include( "../errors.lua" )

include( "../motionsensor.lua" )
include( "../util.lua" )

include( "../mount/mount.lua" )