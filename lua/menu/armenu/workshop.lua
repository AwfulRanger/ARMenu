local PANEL = {}



language.Add( "armenu_prevpage", "Previous" )
language.Add( "armenu_nextpage", "Next" )
language.Add( "armenu_createdby", "Created by " )
language.Add( "armenu_createdon", "Created on " )
language.Add( "armenu_updatedon", ", last updated on " )
language.Add( "armenu_docache", "Cache pages" )
language.Add( "armenu_clearcache", "Clear cache" )

local upmat = Material( "html/img/thumb-up.png" )
local downmat = Material( "html/img/thumb-down.png" )

local cacheworkshop = CreateClientConVar( "armenu_cacheworkshop", 0, true, false, "Cache workshop pages" )
PANEL.CacheEnabled = cacheworkshop:GetBool()

PANEL.Tags = {}
PANEL.ExtraTags = {}
PANEL.TagSelect = {
	
	--[[
	"gamemode",
	"map",
	"weapon",
	"vehicle",
	"npc",
	"tool",
	"effects",
	"model",
	"entity",
	--"servercontent",
	--"save",
	--"demo",
	--"dupe",
	--"addon",
	--"scenes",
	--"machines",
	--"buildings",
	--"courses",
	--"others",
	]]--
	
}

function PANEL:Init()
	
	self.CacheEnabled = cacheworkshop:GetBool()
	
	self.Tags = {}
	self.ExtraTags = {}
	self.TagSelect = {}
	
	self.CategoryPrefix = "addons"
	self.Categories = {
		
		{
			
			{ "subscribed" },
			
		},
		{
			
			{ "trending" },
			{ "popular" },
			{ "latest" },
			
		},
		{
			
			{ "friends" },
			{ "mine" },
			
		},
		
	}
	self.DefaultCategory = "subscribed"
	
end

function PANEL:GetTags( tags )
	
	if tags ~= nil then return tags end
	
	tags = table.Copy( self.Tags )
	for _, v in pairs( self.ExtraTags ) do
		
		if v == true then table.insert( tags, _ ) end
		
	end
	
	return tags
	
end

local items = 25

local pagescache = {}
local listcache = {}
local matcache = {}
local matpathcache = {}
local infocache = {}
local votecache = {}

local function clearcache( extra )
	
	pagescache = {}
	listcache = {}
	
	if extra == true then
		
		matcache = {}
		matpathcache = {}
		infocache = {}
		votecache = {}
		
	end
	
end

function PANEL:GetCachedList( itemtype, tags, page, search )
	
	tags = self:GetTags( tags )
	search = search or ""
	
	if istable( tags ) == true then
		
		local tagstr = ""
		for i = 1, #tags do
			
			tagstr = tagstr .. tags[ i ]
			if i ~= #tags then tagstr = tagstr .. "," end
			
		end
		
		tags = tagstr
		
	end
	
	if listcache[ itemtype ] ~= nil and listcache[ itemtype ][ tags ] ~= nil and listcache[ itemtype ][ tags ][ page ] ~= nil and listcache[ itemtype ][ tags ][ page ][ search ] ~= nil then
		
		return listcache[ itemtype ][ tags ][ page ][ search ], pagescache[ itemtype ][ tags ][ search ]
		
	end
	
end

function PANEL:CacheList( itemtype, tags, page, data, search )
	
	tags = self:GetTags( tags )
	search = search or ""
	
	if istable( tags ) == true then
		
		local tagstr = ""
		for i = 1, #tags do
			
			tagstr = tagstr .. tags[ i ]
			if i ~= #tags then tagstr = tagstr .. "," end
			
		end
		
		tags = tagstr
		
	end
	
	local pages = math.ceil( data.totalresults / items )
	if pagescache[ itemtype ] == nil then pagescache[ itemtype ] = {} end
	if pagescache[ itemtype ][ tags ] == nil then pagescache[ itemtype ][ tags ] = {} end
	if pagescache[ itemtype ][ tags ][ search ] == nil then pagescache[ itemtype ][ tags ][ search ] = pages end
	if self.CacheEnabled == true then pages = pagescache[ itemtype ][ tags ][ search ] end
	
	if listcache[ itemtype ] == nil then listcache[ itemtype ] = {} end
	if listcache[ itemtype ][ tags ] == nil then listcache[ itemtype ][ tags ] = {} end
	if listcache[ itemtype ][ tags ][ page ] == nil then listcache[ itemtype ][ tags ][ page ] = {} end
	listcache[ itemtype ][ tags ][ page ][ search ] = data
	
end

function PANEL:GetList( callback, itemtype, tags, days, page, search )
	
	self.CurrentSearch = search
	
	itemtype = itemtype or ""
	tags = self:GetTags( tags )
	days = days or 0
	page = page or 1
	
	local tagstr = ""
	for i = 1, #tags do
		
		tagstr = tagstr .. tags[ i ]
		if i ~= #tags then tagstr = tagstr .. "," end
		
	end
	
	if self.CacheEnabled == true and ( search == nil or search == "" ) then
		
		local cacheddata, cachedpages = self:GetCachedList( itemtype, tagstr, page, search )
		if cacheddata ~= nil and cachedpages ~= nil then callback( cacheddata, cachedpages ) return end
		
	end
	
	if itemtype == "local" then self:GetLocal( callback, page, search ) return end
	if itemtype == "subscribed" then self:GetSubscribed( callback, false, page, tags, search ) return end
	if itemtype == "subscribed_ugc" then self:GetSubscribed( callback, true, page, tags, search ) return end
	
	local id = "0"
	if itemtype == "mine" then id = "1" end
	
	if search == nil or search == "" then
		
		steamworks.GetList( itemtype, tags, items * ( page - 1 ), items, days, id, function( data )
			
			if self.CacheEnabled == true then self:CacheList( itemtype, tags, page, data, search ) end
			callback( data, math.ceil( data.totalresults / items ) )
			
		end )
		
	else
		
		--absolutely disgusting
		
		local restbl = {}
		local resdone = 0
		local function getlist()
			
			if search ~= self.CurrentSearch then return end
			
			steamworks.GetList( itemtype, tags, resdone, items, days, id, function( data )
				
				if search ~= self.CurrentSearch then return end
				
				local infodone = 0
				for i = 1, #data.results do
					
					resdone = resdone + 1
					self:GetInfo( data.results[ i ], function( info )
						
						if search ~= self.CurrentSearch then return end
						
						infodone = infodone + 1
						
						if #restbl < items and info ~= nil and string.find( string.lower( info.title ), string.lower( search ) ) ~= nil then table.insert( restbl, data.results[ i ] ) end
						
						if infodone >= #data.results then
							
							if #restbl < items and #data.results >= items then getlist() end
							
							callback( {
								
								numresults = #restbl,
								totalresults = #restbl,
								results = restbl,
								
							}, 1 )
							
						end
						
					end )
					
				end
				
			end )
			
		end
		getlist( search )
		
	end
	
end

function PANEL:GetLocal( callback, page, search )
end

function PANEL:GetSubscribed( callback, ugc, page, tags, search )
	
	ugc = ugc or false
	page = page or 1
	tags = self:GetTags( tags )
	
	local addons
	if ugc == true then
		
		addons = engine.GetUserContent()
		
	else
		
		addons = engine.GetAddons()
		
	end
	addons = table.Copy( addons )
	
	for i = #addons, 1, -1 do
		
		local doremove
		if tags ~= nil then for i_ = 1, #tags do if string.find( string.lower( addons[ i ].tags ), string.lower( tags[ i_ ] ) ) == nil then doremove = true end end end
		if search ~= nil and search ~= "" and string.find( string.lower( addons[ i ].title ), string.lower( search ) ) == nil then doremove = true end
		if doremove == true then table.remove( addons, i ) end
		
	end
	
	local num = math.min( 25, #addons - ( items * ( page - 1 ) ) )
	
	local data = {
		
		numresults = num,
		totalresults = #addons,
		results = {},
		
	}
	
	for i = 1, num do
		
		local a = addons[ i + ( items * ( page - 1 ) ) ]
		if a ~= nil then data.results[ i ] = a.wsid end
		
	end
	
	local itemtype = "subscribed"
	if ugc == true then itemtype = itemtype .. "_ugc" end
	if self.CacheEnabled == true then self:CacheList( itemtype, tags, page, data ) end
	
	callback( data, math.ceil( data.totalresults / items ) )
	
end

function PANEL:GetMat( id, callback )
	
	if matcache[ id ] ~= nil then callback( matcache[ id ] ) return end
	steamworks.Download( id, false, function( path )
		
		if path ~= nil then
			
			matcache[ id ] = AddonMaterial( path )
			callback( matcache[ id ] )
			
		end
		
	end )
	
end

function PANEL:GetMatPath( path )
	
	if matpathcache[ path ] ~= nil then return matpathcache[ path ] end
	
	local mat = Material( path )
	matpathcache[ path ] = mat
	
	return mat
	
end

function PANEL:GetInfo( id, callback )
	
	if infocache[ id ] ~= nil then callback( infocache[ id ] ) return end
	steamworks.FileInfo( id, function( info )
		
		infocache[ id ] = info
		callback( info )
		
	end )
	
end

function PANEL:GetVotes( id, callback )
	
	if votecache[ id ] ~= nil then callback( votecache[ id ] ) return end
	steamworks.VoteInfo( id, function( info )
		
		votecache[ id ] = info
		callback( info )
		
	end )
	
end

local textcache = {}
function PANEL:TextWidth( text, w, font )
	
	if textcache[ font ] ~= nil and textcache[ font ][ text ] ~= nil and textcache[ font ][ w ][ text ] ~= nil then return textcache[ font ][ w ][ text ] end
	
	local str = "…"
	
	if surface.GetTextSize( text ) <= w then
		
		str = text
		
	else
		
		if #text <= 1 then return str end
		
		for i = 1, #text - 1 do
			
			local str_ = string.Left( text, #text - i ) .. "…"
			if surface.GetTextSize( str_ ) <= w then str = str_ break end
			
		end
		
	end
	
	if textcache[ font ] == nil then textcache[ font ] = {} end
	if textcache[ font ][ w ] == nil then textcache[ font ][ w ] = {} end
	textcache[ font ][ w ][ text ] = str
	
	return str
	
end

function PANEL:CreateButton( parent, x, y, w, h, res )
	
	local mat
	
	local button = vgui.Create( "SoundButton" )
	button:SetParent( parent )
	button:SetText( "" )
	button:SetPos( x, y )
	button:SetSize( w, h )
	function button.Paint( panel, w, h )
		
		local pad = math.Round( w * 0.05 )
		
		local color = MenuColor.bgdull
		if panel:IsHovered() == true then color = MenuColor.active end
		if self.CurrentAddon == res then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
		if mat ~= nil then
			
			surface.SetDrawColor( MenuColor.white )
			
			surface.SetMaterial( mat )
			surface.DrawTexturedRect( pad, pad, w - ( pad * 2 ), h - ( pad * 2 ) )
			
		end
		
		surface.SetFont( panel:GetFont() )
		local text = self:TextWidth( panel:GetText(), math.max( 0, w - 8 ), panel:GetFont() )
		local tw, th = surface.GetTextSize( text )
		
		draw.RoundedBoxEx( 4, 0, 0, w, th, MenuColor.bgdim, true, true, false, false )
		
		local x = ( w * 0.5 ) - ( tw * 0.5 )
		if tw > w then x = 0 end
		surface.SetTextPos( x, 0 )
		surface.SetTextColor( MenuColor.fg )
		surface.DrawText( text )
		
		return true
		
	end
	function button.DoClick( panel )
		
		panel:DoClickSound()
		
		self.CurrentAddon = res
		self:CreateInfo( res )
		
	end
	
	if istable( res ) == true then
		
		if res.name ~= nil then button:SetText( res.name ) end
		if res.preview ~= nil then mat = self:GetMatPath( res.preview ) end
		
	else
		
		self:GetInfo( res, function( info )
			
			if info == nil then return end
			
			if IsValid( button ) == true then
				
				if info.title ~= nil then button:SetText( info.title ) end
				if info.previewid ~= nil then self:GetMat( info.previewid, function( addonmat ) mat = addonmat end ) end
				
			end
			
		end )
		
	end
	
end

function PANEL:CreateList( itemtype, tags, days, page, search )
	
	if IsValid( self.addons ) == true then self.addons:Remove() end
	
	itemtype = itemtype or ""
	tags = self:GetTags( tags )
	days = days or 0
	page = page or 1
	
	self.CurrentItemType = itemtype
	
	local id = 0
	if itemtype == "mine" then id = 1 end
	
	self.addons = vgui.Create( "DPanel" )
	self.addons:SetParent( self )
	self.addons:Dock( LEFT )
	function self.addons:Paint( w, h )
	end
	
	local pagebg = vgui.Create( "DPanel" )
	pagebg:SetParent( self.addons )
	pagebg:Dock( BOTTOM )
	pagebg:DockMargin( 0, ScrH() * 0.01, 0, 0 )
	function pagebg:Paint( w, h )
	end
	
	local addonsbg = vgui.Create( "DPanel" )
	addonsbg:SetParent( self.addons )
	addonsbg:Dock( FILL )
	function addonsbg:Paint( w, h )
	end
	
	self:InvalidateParent( true )
	self.addons:InvalidateParent( true )
	self.addons:InvalidateLayout( true )
	
	local h = addonsbg:GetTall()
	local sep = h * 0.02
	
	local pad = ScrH() * 0.01
	
	self.addons:DockMargin( sep, 0, sep, 0 )
	
	self.addons:SetWide( addonsbg:GetTall() )
	
	local pw, ph = pagebg:GetSize()
	
	local wang = vgui.Create( "DNumberWang" )
	wang:SetParent( pagebg )
	wang:SetPos( h * 0.425, 0 )
	wang:SetSize( h * 0.075, ph )
	wang:SetMinMax( 1, page )
	wang:SetValue( page )
	wang:HideWang()
	wang:SetDecimals( 0 )
	wang:SetUpdateOnType( false )
	function wang:OnChange()
	end
	function wang:OnEnter()
		
		self:OnValueChanged( self:GetValue() )
		
	end
	function wang.OnValueChanged( panel, val )
		
		val = tonumber( val )
		if val == nil then return end
		self:CreateList( itemtype, tags, days, math.Clamp( val, panel:GetMin(), panel:GetMax() ), search )
		
	end
	
	local pagenum = vgui.Create( "DLabel" )
	pagenum:SetParent( pagebg )
	pagenum:SetPos( h * 0.5, 0 )
	pagenum:SetSize( h * 0.075, ph )
	pagenum:SetTextColor( MenuColor.fg_alt )
	pagenum:SetText( " / " )
	
	local prev = vgui.Create( "SoundButton" )
	prev:SetParent( pagebg )
	prev:SetPos( h * 0.325, 0 )
	prev:SetSize( h * 0.075, ph )
	prev:SetTextColor( MenuColor.fg_alt )
	prev:SetText( "#armenu_prevpage" )
	function prev:Paint( w, h )
		
		local color = MenuColor.bgdull
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function prev:DoClick()
		
		self:DoClickSound()
		
		if wang:GetValue() - 1 >= wang:GetMin() then wang:SetValue( wang:GetValue() - 1 ) end
		
	end
	
	local next_ = vgui.Create( "SoundButton" )
	next_:SetParent( pagebg )
	next_:SetPos( h * 0.6, 0 )
	next_:SetSize( h * 0.075, ph )
	next_:SetTextColor( MenuColor.fg_alt )
	next_:SetText( "#armenu_nextpage" )
	function next_:Paint( w, h )
		
		local color = MenuColor.bgdull
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function next_:DoClick()
		
		self:DoClickSound()
		
		if wang:GetValue() + 1 <= wang:GetMax() then wang:SetValue( wang:GetValue() + 1 ) end
		
	end
	
	local docache = vgui.Create( "DCheckBoxLabel" )
	docache:SetParent( pagebg )
	docache:Dock( LEFT )
	docache:SetTextColor( MenuColor.fg_alt )
	docache:SetText( "#armenu_docache" )
	docache:SetChecked( self.CacheEnabled )
	function docache.OnChange( panel, val )
		
		if self.CacheEnabled ~= val then
			
			clearcache()
			
			RunConsoleCommand( "armenu_cacheworkshop", ( val == true and 1 ) or 0 )
			self.CacheEnabled = val
			
			self:CreateList( itemtype, tags, days, page, search )
			
		end
		
	end
	
	local clear = vgui.Create( "SoundButton" )
	clear:SetParent( pagebg )
	clear:Dock( RIGHT )
	clear:SetTextColor( MenuColor.fg_alt )
	clear:SetText( "#armenu_clearcache" )
	function clear:Paint( w, h )
		
		local color = MenuColor.bgdull
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function clear.DoClick( panel )
		
		panel:DoClickSound()
		
		clearcache( true )
		
		self:CreateList( itemtype, tags, days, page, search )
		
	end
	
	local grid = 5
	local size = ( h * ( 1 / grid ) ) - ( sep * ( 1 - ( 1 / grid ) ) )
	
	self:GetList( function( data, pages )
		
		if IsValid( self ) ~= true then return end
		
		pages = pages or math.ceil( data.totalresults / items )
		if IsValid( pagenum ) == true then pagenum:SetText( " / " .. pages ) end
		if IsValid( wang ) == true then wang:SetMax( pages ) end
		
		for i = 1, data.numresults do
			
			local res = data.results[ i ]
			
			local row = ( i - 1 ) % grid
			local col = math.floor( ( i - 1 ) / grid )
			
			local x = ( size + sep ) * row
			local y = ( size + sep ) * col
			
			self:CreateButton( addonsbg, x, y, size, size, res )
			
		end
		
	end, itemtype, tags, days, page, search )
	
end

function PANEL:Publish( path, icon )
	
	local size = math.min( ScrW(), ScrH() )
	
	local panel = vgui.Create( "DFrame" )
	panel:SetTitle( "Publish Creation" )
	panel:SetSize( size * 0.5, size * 0.4 )
	panel:LoadGWENFile( "resource/ui/saveupload.gwen" )
	panel:Center()
	panel:MakePopup()
	
	local submit = panel:Find( "upload" )
	local title = panel:Find( "name" )
	local description = panel:Find( "description" )
	local error_ = panel:Find( "error" )
	local image = panel:Find( "image" )
	
	image:SetImage( "../" .. icon )
	
	function submit:DoClick()
		
		if title:GetText() == "" then error_:SetText( "You must provide a title!" ) return end
		
		local err = self:FinishPublish( path, icon, title:GetText(), description:GetText() )
		if err ~= nil then error_:SetText( err ) return end
		
		panel:Remove()
		
	end
	
end

function PANEL:FinishPublish( path, icon, title, desc )
end

function PANEL:CreateInfo( res )
	
	if IsValid( self.info ) == true then self.info:Remove() end
	
	local pad = ScrH() * 0.01
	
	self.info = vgui.Create( "DPanel" )
	self.info:SetParent( self )
	self.info:Dock( FILL )
	self.info:DockPadding( pad, pad, pad, pad )
	function self.info:Paint( w, h )
		
		draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdull )
		
	end
	
	if res ~= nil then
		
		local islocal = istable( res )
		
		local title = vgui.Create( "DLabel" )
		title:SetParent( self.info )
		title:Dock( TOP )
		title:SetFont( "DermaLarge" )
		title:SetTextColor( MenuColor.fg_alt )
		title:SetText( "" )
		title:SetCursor( "hand" )
		title:SizeToContents()
		
		local createdby
		local author
		
		if islocal ~= true then
			
			local authorbg = vgui.Create( "DPanel" )
			authorbg:SetParent( self.info )
			authorbg:Dock( TOP )
			function authorbg:Paint( w, h )
			end
			
			createdby = vgui.Create( "DLabel" )
			createdby:SetParent( authorbg )
			createdby:Dock( LEFT )
			createdby:SetFont( "DermaDefault" )
			createdby:SetTextColor( MenuColor.fg_alt )
			createdby:SetText( "" )
			createdby:SizeToContents()
			
			author = vgui.Create( "DLabel" )
			author:SetParent( authorbg )
			author:Dock( LEFT )
			author:SetFont( "DermaDefaultBold" )
			author:SetTextColor( MenuColor.fg_alt )
			author:SetText( "" )
			author:SetCursor( "hand" )
			
			authorbg:SizeToContents()
			
		end
		
		local timebg = vgui.Create( "DPanel" )
		timebg:SetParent( self.info )
		timebg:Dock( TOP )
		timebg:DockMargin( 0, 0, 0, pad * 4 )
		function timebg:Paint( w, h )
		end
		
		local createdon = vgui.Create( "DLabel" )
		createdon:SetParent( timebg )
		createdon:Dock( LEFT )
		createdon:SetFont( "DermaDefault" )
		createdon:SetTextColor( MenuColor.fg_alt )
		createdon:SetText( "#armenu_createdon" )
		createdon:SizeToContents()
		
		local createtime = vgui.Create( "DLabel" )
		createtime:SetParent( timebg )
		createtime:Dock( LEFT )
		createtime:SetFont( "DermaDefaultBold" )
		createtime:SetTextColor( MenuColor.fg_alt )
		createtime:SetText( "" )
		
		local updatedon
		local updatetime
		
		if islocal ~= true then
			
			updatedon = vgui.Create( "DLabel" )
			updatedon:SetParent( timebg )
			updatedon:Dock( LEFT )
			updatedon:SetFont( "DermaDefault" )
			updatedon:SetTextColor( MenuColor.fg_alt )
			updatedon:SetText( "" )
			updatedon:SizeToContents()
			
			updatetime = vgui.Create( "DLabel" )
			updatetime:SetParent( timebg )
			updatetime:Dock( LEFT )
			updatetime:SetFont( "DermaDefaultBold" )
			updatetime:SetTextColor( MenuColor.fg_alt )
			updatetime:SetText( "" )
			
		end
		
		timebg:SizeToContents()
		
		if islocal ~= true then
			
			local desc = vgui.Create( "RichText" )
			desc:SetParent( self.info )
			desc:Dock( FILL )
			local c = MenuColor.fg_alt
			desc:InsertColorChange( c.r, c.g, c.b, c.a )
			
			self:GetInfo( res, function( info )
				
				if info == nil then return end
				
				if IsValid( title ) == true and info.title ~= nil then
					
					title:SetText( info.title )
					if info.id ~= nil then function title:DoClick() gui.OpenURL( "http://steamcommunity.com/sharedfiles/filedetails/?id=" .. info.id ) end end
					
				end
				if info.ownername ~= nil then
					
					if IsValid( createdby ) == true then
						
						createdby:SetText( "#armenu_createdby" )
						createdby:SizeToContents()
						
					end
					if IsValid( author ) == true then
						
						author:SetText( info.ownername )
						author:SizeToContents()
						if info.owner ~= nil then function author:DoClick() gui.OpenURL( "http://steamcommunity.com/profiles/" .. info.owner ) end end
						
					end
					
				end
				if info.created ~= nil then
					
					if IsValid( createdon ) == true then
						
						createdon:SetText( "#armenu_createdon" )
						createdon:SizeToContents()
						
					end
					if IsValid( createtime ) == true then
						
						createtime:SetText( os.date( "%c", info.created ) )
						createtime:SizeToContents()
						
					end
					
				end
				if info.updated ~= nil then
					
					if IsValid( updatedon ) == true then
						
						updatedon:SetText( "#armenu_updatedon" )
						updatedon:SizeToContents()
						
					end
					if IsValid( updatetime ) == true then
						
						updatetime:SetText( os.date( "%c", info.updated ) )
						updatetime:SizeToContents()
						
					end
					
				end
				if IsValid( desc ) == true and info.description ~= nil then desc:AppendText( info.description ) end
				
			end )
			
			local votebg = vgui.Create( "DPanel" )
			votebg:SetParent( self.info )
			votebg:Dock( BOTTOM )
			votebg:DockMargin( 0, pad, 0, 0 )
			function votebg:Paint( w, h )
			end
			
			local upvote = vgui.Create( "SoundButton" )
			upvote:SetParent( votebg )
			upvote:Dock( LEFT )
			upvote:SetFont( "DermaDefaultBold" )
			upvote:SetTextColor( MenuColor.fg_alt )
			upvote:SetText( "" )
			function upvote:Paint( w, h )
				
				surface.SetDrawColor( MenuColor.yes )
				surface.DrawRect( 0, 0, w, h )
				
				local s = math.min( 16, w * 0.4, h * 0.4 )
				
				surface.SetDrawColor( MenuColor.white )
				surface.SetMaterial( upmat )
				surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
				
			end
			function upvote:DoClick()
				
				self:DoClickSound()
				
				steamworks.Vote( res, true )
				
			end
			
			local downvote = vgui.Create( "SoundButton" )
			downvote:SetParent( votebg )
			downvote:Dock( RIGHT )
			downvote:SetFont( "DermaDefaultBold" )
			downvote:SetTextColor( MenuColor.fg_alt )
			downvote:SetText( "" )
			function downvote:Paint( w, h )
				
				surface.SetDrawColor( MenuColor.no )
				surface.DrawRect( 0, 0, w, h )
				
				local s = math.min( 16, w * 0.4, h * 0.4 )
				
				surface.SetDrawColor( MenuColor.white )
				surface.SetMaterial( downmat )
				surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
				
			end
			function downvote:DoClick()
				
				self:DoClickSound()
				
				steamworks.Vote( res, false )
				
			end
			
			local votepercent = -1
			
			local votestotal = vgui.Create( "DPanel" )
			votestotal:SetParent( votebg )
			votestotal:Dock( FILL )
			votestotal:DockPadding( pad, 0, pad, 0 )
			votestotal:DockMargin( pad, 0, pad, 0 )
			function votestotal:Paint( w, h )
				
				if votepercent >= 0 and votepercent <= 1 then
					
					if votepercent > 0 then
						
						surface.SetDrawColor( MenuColor.no )
						surface.DrawRect( w * votepercent, 0, w - ( w * votepercent ), h )
						
					end
					if votepercent < 1 then
						
						surface.SetDrawColor( MenuColor.yes )
						surface.DrawRect( 0, 0, w * votepercent, h )
						
					end
					
				end
				
			end
			
			local uptotal = vgui.Create( "DLabel" )
			uptotal:SetParent( votestotal )
			uptotal:Dock( LEFT )
			uptotal:SetFont( "DermaDefaultBold" )
			uptotal:SetTextColor( MenuColor.fg_alt )
			uptotal:SetText( "" )
			
			local downtotal = vgui.Create( "DLabel" )
			downtotal:SetParent( votestotal )
			downtotal:Dock( RIGHT )
			downtotal:SetFont( "DermaDefaultBold" )
			downtotal:SetTextColor( MenuColor.fg_alt )
			downtotal:SetText( "" )
			
			self:GetVotes( res, function( info )
				
				if info.score ~= nil then votepercent = info.score end
				if IsValid( uptotal ) == true and info.up ~= nil then
					
					uptotal:SetText( info.up )
					uptotal:SizeToContents()
					
				end
				if IsValid( downtotal ) == true and info.down ~= nil then
					
					downtotal:SetText( info.down )
					downtotal:SizeToContents()
					
				end
				
			end )
			
		else
			
			if res.name ~= nil then
				
				title:SetText( res.name )
				if res.fullpath ~= nil then function title:DoClick() OpenFolder( string.Trim( string.GetPathFromFilename( res.fullpath ), "/" ) ) end end
				
			end
			if res.time ~= nil then
				
				createtime:SetText( os.date( "%c", res.time ) )
				createtime:SizeToContents()
				
			end
			
		end
		
	end
	
end

PANEL.CategoryPrefix = "addons"
PANEL.Categories = {
	
	{
		
		{ "subscribed" },
		
	},
	{
		
		{ "trending" },
		{ "popular" },
		{ "latest" },
		
	},
	{
		
		{ "friends" },
		{ "mine" },
		
	},
	
}
PANEL.DefaultCategory = "subscribed"

function PANEL:CreateCategories()
	
	if IsValid( self.catbg ) == true then self.catbg:Remove() end
	
	local pad = ScrH() * 0.01
	
	self.catbg = vgui.Create( "DPanel" )
	self.catbg:SetParent( self )
	self.catbg:Dock( LEFT )
	self.catbg:DockPadding( pad, pad, pad, pad )
	self.catbg:SetWide( ScrW() * 0.15 )
	function self.catbg:Paint( w, h )
		
		draw.RoundedBox( 4, 0, 0, w, h, MenuColor.bgdull )
		
	end
	
	local searchbar
	
	for i = 1, #self.Categories do
		
		for i_ = 1, #self.Categories[ i ] do
			
			local cat = self.Categories[ i ][ i_ ]
			
			local button = vgui.Create( "SoundButton" )
			button:SetParent( self.catbg )
			button:Dock( TOP )
			button:SetFont( "DermaDefaultBold" )
			button:SetText( "#" .. self.CategoryPrefix .. "." .. cat[ 1 ] )
			button:SizeToContents()
			function button:Paint( w, h )
			end
			function button.DoClick( panel )
				
				panel:DoClickSound()
				
				self:CreateInfo()
				self:CreateList( cat[ 1 ], nil, nil, nil, searchbar:GetValue() )
				
			end
			
			if cat[ 2 ] ~= nil then for _, v in pairs( cat[ 2 ] ) do button[ _ ] = v end end
			
			if i_ == #self.Categories[ i ] then
				
				if i == #self.Categories then
					
					button:DockMargin( 0, 0, 0, pad * 3 )
					
				else
					
					button:DockMargin( 0, 0, 0, pad )
					
				end
				
			end
			
		end
		
	end
	
	searchbar = vgui.Create( "DTextEntry" )
	searchbar:SetParent( self.catbg )
	searchbar:Dock( TOP )
	searchbar:DockMargin( 0, 0, 0, pad * 3 )
	function searchbar.OnChange( panel )
		
		self:CreateList( self.CurrentItemType, nil, nil, nil, panel:GetValue() )
		
	end
	
	for i = 1, #self.TagSelect do
		
		local check = vgui.Create( "DCheckBoxLabel" )
		check:SetParent( self.catbg )
		check:Dock( TOP )
		check:DockMargin( 0, 0, 0, pad )
		check:SetTextColor( MenuColor.fg_alt )
		check:SetText( "#" .. self.CategoryPrefix .. "." .. self.TagSelect[ i ] )
		check:SetChecked( self.ExtraTags[ self.TagSelect[ i ] ] or false )
		function check.OnChange( panel, val )
			
			self.ExtraTags[ self.TagSelect[ i ] ] = val
			self:CreateList( self.CurrentItemType, nil, nil, nil, searchbar:GetValue() )
			
		end
		
	end
	
	local openpage = vgui.Create( "SoundButton" )
	openpage:SetParent( self.catbg )
	openpage:Dock( BOTTOM )
	openpage:SetTall( ScrH() * 0.05 )
	openpage:SetFont( "DermaLarge" )
	openpage:SetText( "#open_workshop" )
	function openpage:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function openpage:DoClick()
		
		self:DoClickSound()
		
		steamworks.OpenWorkshop()
		
	end
	
end

function PANEL:MenuSetup()
	
	local pad = ScrH() * 0.01
	self:DockPadding( pad, pad, pad, pad )
	
	self:CreateCategories()
	
	self:CreateList( self.DefaultCategory )
	
	self:CreateInfo()
	
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox( 8, 0, 0, w, h, MenuColor.bg_alt )
	
end



vgui.Register( "MainMenu_Workshop", PANEL, "EditablePanel" )