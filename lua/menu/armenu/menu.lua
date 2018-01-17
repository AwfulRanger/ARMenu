includeunsafe = includeunsafe or include

function include( path, ... )
	
	local oldpath = path
	path = string.gsub( path, "/[^/]-/%.%./", "/" )
	
	if file.Exists( "lua/" .. path, "GAME" ) == true then
		
		if file.Exists( path, "LuaMenu" ) == true then return includeunsafe( path, ... ) end
		local func = CompileString( file.Read( "lua/" .. path, "GAME" ), "lua/" .. path )
		if isfunction( func ) == true then return func() end
		
	else
		
		local info = debug.getinfo( 1 )
		local i = 2
		while i > -1 do
			
			local newinfo = debug.getinfo( i )
			if newinfo ~= nil and newinfo.short_src ~= "[C]" then
				
				info = newinfo
				i = i + 1
				
			else
				
				i = -1
				
			end
			
		end
		
		local source = string.gsub( string.GetPathFromFilename( info.short_src ) .. oldpath, "/[^/]-/%.%./", "/" )
		if string.sub( source, 1, 4 ) == "lua/" then source = string.sub( source, 5 ) end
		
		if source ~= nil and source ~= "" and file.Exists( "lua/" .. source, "GAME" ) == true then
			
			if file.Exists( source, "LuaMenu" ) == true then return includeunsafe( source, ... ) end
			local func = CompileString( file.Read( "lua/" .. source, "GAME" ), "lua/" .. source )
			if isfunction( func ) == true then return func() end
			
		else
			
			print( "Couldn't include file '" .. path .. "' (File not found)" )
			
		end
		
	end
	
end

concommand.Add( "armenu_reload", function( ply, cmd, args, arg )
	
	--Clear old panels
	local panels = vgui.GetWorldPanel():GetChildren()
	for i = 1, #panels do
		
		if IsValid( panels[ i ] ) == true then panels[ i ]:Remove() end
		panels[ i ] = nil
		
	end
	
	include( "menu/armenu/menu.lua" )
	
end, nil, "Reload ARMenu" )

concommand.Add( "lua_run_menu", function( ply, cmd, args, arg )
	
	local msg = RunString( arg, "lua_run_menu", false )
	if msg ~= nil then print( msg ) end
	
end )

concommand.Add( "lua_openscript_menu", function( ply, cmd, args, arg )
	
	include( arg )
	
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