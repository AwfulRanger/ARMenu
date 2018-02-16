include( "vgui/dhorizontaldivider.lua" )

language.Add( "armenu_openurl.whitelist", "Whitelist" )
language.Add( "armenu_openurl.add", "Add" )
language.Add( "armenu_openurl.remove", "Remove" )
language.Add( "armenu_openurl.tip", "Supports asterisks (*) as wildcards if patterns are disabled" )
language.Add( "armenu_openurl.patterns", "Patterns" )
language.Add( "armenu_openurl.patternstip", "Enable Lua patterns" )
language.Add( "armenu_openurl.fuzzy", "Fuzzy" )
language.Add( "armenu_openurl.fuzzytip", "Ignore things like \"http://\" and \"www.\" when not specified in the whitelist" )

local whitelist = util.JSONToTable( file.Read( "armenu/openurl.dat" ) or "" ) or { num = {}, str = {} }

local patterns = CreateConVar( "armenu_urlpatterns", 0, FCVAR_ARCHIVE, "Enable Lua patterns in the URL whitelist" )
local fuzzy = CreateConVar( "armenu_urlfuzzy", 1, FCVAR_ARCHIVE, "Ignore things like \"http://\" and \"www.\" when not specified in whitelisted URLs" )

local function fuzz( url )
	
	local ps, pe = string.find( url, "://" )
	if pe ~= nil then url = string.sub( url, pe + 1 ) end
	
	if string.sub( url, 1, 4 ) == "www." then url = string.sub( url, 5 ) end
	
	return url
	
end

local function getwhitelisted( url )
	
	local wl = whitelist.str[ url ]
	
	if wl == nil then
		
		if fuzzy:GetBool() == true then url = fuzz( url ) end
		
		for i = 1, #whitelist.num do
			
			local tbl = whitelist.num[ i ]
			local rep = tbl[ 1 ]
			local swc = rep[ 1 ] == "*"
			local ewc = rep[ #rep ] == "*"
			if patterns:GetBool() ~= true then rep = string.gsub( string.PatternSafe( rep ), "%%%*", ".-" ) end
			local spos, epos = string.find( url, rep )
			if ( swc == true or spos == 1 ) and ( ewc == true or epos == #url ) then wl = tbl[ 2 ] break end
			
		end
		
	end
	
	return wl or false
	
end

local function setwhitelisted( url, bool )
	
	local found
	if bool == true then
		
		whitelist.str[ url ] = true
		found = false
		for i = 1, #whitelist.num do
			
			if whitelist.num[ i ][ 1 ] == url then
				
				found = true
				whitelist.num[ i ] = { url, true }
				break
				
			end
			
		end
		if found ~= true then table.insert( whitelist.num, { url, true } ) end
		
	else
		
		whitelist.str[ url ] = nil
		for i = 1, #whitelist.num do
			
			if whitelist.num[ i ][ 1 ] == url then
				
				table.remove( whitelist.num, i )
				break
				
			end
			
		end
		
	end
	file.Write( "armenu/openurl.dat", util.TableToJSON( whitelist ) )
	
	return found
	
end



local PANEL = {}



function PANEL:Init()
	
	self:SetPos( ScrW() * 0.3, ScrH() * 0.6 )
	self:SetSize( ScrW() * 0.4, ScrH() * 0.3 )
	self:SetTitle( "#armenu_openurl.whitelist" )
	self:MakePopup()
	
	local cbbg = vgui.Create( "Panel" )
	cbbg:SetParent( self )
	cbbg:Dock( TOP )
	
	local patternscb = vgui.Create( "DCheckBoxLabel" )
	patternscb:SetParent( cbbg )
	patternscb:Dock( LEFT )
	patternscb:DockMargin( 0, 0, ScrW() * 0.01, 0 )
	patternscb:SetText( "#armenu_openurl.patterns" )
	patternscb:SetTooltip( "#armenu_openurl.patternstip" )
	patternscb:SetConVar( patterns:GetName() )
	
	local fuzzycb = vgui.Create( "DCheckBoxLabel" )
	fuzzycb:SetParent( cbbg )
	fuzzycb:Dock( LEFT )
	fuzzycb:SetText( "#armenu_openurl.fuzzy" )
	fuzzycb:SetTooltip( "#armenu_openurl.fuzzytip" )
	fuzzycb:SetConVar( fuzzy:GetName() )
	
	local urls = vgui.Create( "DListView" )
	urls:SetParent( self )
	urls:Dock( FILL )
	urls:SetMultiSelect( false )
	urls:AddColumn( "URL" )
	for _, v in SortedPairs( whitelist.str ) do urls:AddLine( _ ) end
	function urls:OnRowRightClick( index, line )
		
		local menu = DermaMenu()
		menu:AddOption( "#armenu_openurl.remove", function()
			
			setwhitelisted( line:GetColumnText( 1 ), false )
			self:RemoveLine( index )
			
		end )
		menu:Open()
		
	end
	
	local urlbg = vgui.Create( "Panel" )
	urlbg:SetParent( self )
	urlbg:Dock( BOTTOM )
	
	self.url = vgui.Create( "DTextEntry" )
	self.url:SetParent( urlbg )
	self.url:Dock( FILL )
	self.url:SetTooltip( "#armenu_openurl.tip" )
	function self.url:OnEnter() if setwhitelisted( self:GetText(), true ) ~= true then urls:AddLine( self:GetText() ) end end
	
	local add = vgui.Create( "DButton" )
	add:SetParent( urlbg )
	add:Dock( RIGHT )
	add:SetText( "#armenu_openurl.add" )
	function add.DoClick() if setwhitelisted( self.url:GetText(), true ) ~= true then urls:AddLine( self.url:GetText() ) end end
	
end

function PANEL:SetURL( url )
	
	self.url:SetText( url )
	
end



vgui.Register( "OpenURLWhitelist", PANEL, "DFrame" )



local panel
local options
local function createoptions( url )
	
	if IsValid( options ) == true then options:Remove() end
	
	options = vgui.Create( "OpenURLWhitelist" )
	if url ~= nil then options:SetURL( url ) end
	
end

function RequestOpenURL( url )
	
	if getwhitelisted( url ) == true then gui.OpenURL( url ) return end
	
	gui.ActivateGameUI()
	
	local usetime = SysTime() + 0.75
	
	if IsValid( panel ) == true then panel:Remove() end
	
	panel = vgui.Create( "DFrame" )
	panel:SetSize( ScrW() * 0.4, ScrH() * 0.1 )
	panel:Center()
	panel:SetTitle( "#openurl.title" )
	panel:MakePopup()
	hook.Add( "Think", panel, function()
		
		if SysTime() > usetime and gui.IsGameUIVisible() ~= true then panel:Remove() end
		
	end )
	
	local label = vgui.Create( "DLabel" )
	label:SetParent( panel )
	label:Dock( TOP )
	label:SetText( "#openurl.text" )
	label:SetContentAlignment( 5 )
	
	local text = vgui.Create( "DTextEntry" )
	text:SetParent( panel )
	text:Dock( TOP )
	text:SetText( url )
	text:SetDisabled( true )
	
	local buttons = vgui.Create( "Panel" )
	buttons:SetParent( panel )
	buttons:Dock( BOTTOM )
	
	local no = vgui.Create( "DButton" )
	no:SetParent( buttons )
	no:Dock( RIGHT )
	no:SetText( "#openurl.nope" )
	function no:DoClick()
		
		panel:Remove()
		gui.HideGameUI()
		
	end
	
	local yes = vgui.Create( "DButton" )
	yes:SetParent( buttons )
	yes:Dock( RIGHT )
	yes:SetText( "#openurl.yes" )
	function yes:DoClick()
		
		if SysTime() > usetime then
			
			gui.OpenURL( url )
			panel:Remove()
			gui.HideGameUI()
			
		end
		
	end
	
	local options = vgui.Create( "DButton" )
	options:SetParent( buttons )
	options:Dock( LEFT )
	options:SetText( "#armenu_openurl.whitelist" )
	function options:DoClick()
		
		createoptions( url )
		
	end
	
end

concommand.Add( "armenu_openurlwhitelist", createoptions, nil, "Open the gui.OpenURL whitelist menu" )