local PANEL = {}



language.Add( "armenu_saveload", "Load" )
language.Add( "armenu_savedelete", "Delete" )
language.Add( "armenu_savepublish", "Publish" )

language.Add( "armenu_saveloadprompt", "Load this save?" )
language.Add( "armenu_savedeleteprompt", "Are you sure you want to delete this save?" )

local items = 25

function PANEL:Init()
	
	self.Tags = { "save" }
	self.TagSelect = {
		
		"scenes",
		"machines",
		"buildings",
		"courses",
		"others",
		
	}

	self.CategoryPrefix = "saves"
	self.Categories = {
		
		{
			
			{ "local" },
			{ "subscribed_ugc" },
			
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
	self.DefaultCategory = "local"
	
end

function PANEL:GetLocal( callback, page )
	
	if cachevalue == true then
		
		local cacheddata, cachedpages = self:GetCachedList( "local", "", page )
		if cacheddata != nil and cachedpages != nil then callback( cacheddata, cachedpages ) return end
		
	end
	
	local f = file.Find( "saves/*.gms", "MOD", "datedesc" )
	
	local num = math.min( 25, #f - ( items * ( page - 1 ) ) )
	
	local data = {
		
		numresults = num,
		totalresults = #f,
		results = {}
		
	}
	
	for i = 1, #f do
		
		local a = f[ i + ( items * ( page - 1 ) ) ]
		if a != nil then
			
			local strip = string.StripExtension( a )
			table.insert( data.results, {
				
				path = a,
				name = strip,
				preview = "saves/" .. strip .. ".jpg",
				fullpath = "saves/" .. a,
				time = file.Time( "saves/" .. a, "MOD" ),
				
			} )
			
		end
		
	end
	
	if cachevalue == true then self:CacheList( "local", "", page, data ) end
	callback( data, math.ceil( data.totalresults / items ) )
	
end

function PANEL:LoadSave( path )
	
	local prompt = vgui.Create( "YesNoPrompt" )
	prompt:SetText( "#armenu_saveloadprompt" )
	function prompt:OnYes() RunConsoleCommand( "playdemo", path ) end
	prompt:MakePopup()
	
end

function PANEL:DeleteSave( path )
	
	local prompt = vgui.Create( "YesNoPrompt" )
	prompt:SetText( "#armenu_savedeleteprompt" )
	function prompt.OnYes()
		
		file.Delete( path, "MOD" )
		self:CreateList( "local" )
		self:CreateInfo()
		
	end
	prompt:MakePopup()
	
end

function PANEL:CreateInfo( res, ... )
	
	self.BaseClass.CreateInfo( self, res, ... )
	
	if res != nil then
		
		local pad = math.Round( ScrH() * 0.01 )
		local tall = math.Round( ScrH() * 0.05 )
		
		local actionbg = vgui.Create( "DPanel" )
		actionbg:SetParent( self.info )
		actionbg:Dock( BOTTOM )
		actionbg:DockMargin( 0, pad, 0, 0 )
		actionbg:SetTall( ( tall * 2 ) + pad )
		function actionbg:Paint( w, h )
		end
		
		local load = vgui.Create( "SoundButton" )
		load:SetParent( actionbg )
		load:Dock( BOTTOM )
		load:SetTall( tall )
		load:SetFont( "DermaLarge" )
		load:SetTextColor( MenuColor.fg_alt )
		load:SetText( "#armenu_saveload" )
		function load:Paint( w, h )
			
			local color = MenuColor.bg_alt
			if self:IsHovered() == true then color = MenuColor.active end
			if self:IsDown() == true then color = MenuColor.selected end
			draw.RoundedBox( 4, 0, 0, w, h, color )
			
		end
		
		if istable( res ) == true then
			
			function load.DoClick( panel )
				
				panel:DoClickSound()
				
				self:LoadSave( res.fullpath )
				
			end
			
			local delete = vgui.Create( "SoundButton" )
			delete:SetParent( actionbg )
			delete:Dock( BOTTOM )
			delete:DockMargin( 0, pad, 0, pad )
			delete:SetTall( tall )
			delete:SetFont( "DermaLarge" )
			delete:SetTextColor( MenuColor.fg_alt )
			delete:SetText( "#armenu_savedelete" )
			function delete:Paint( w, h )
				
				local color = MenuColor.bg_alt
				if self:IsHovered() == true then color = MenuColor.active end
				if self:IsDown() == true then color = MenuColor.selected end
				draw.RoundedBox( 4, 0, 0, w, h, color )
				
			end
			function delete.DoClick( panel )
				
				panel:DoClickSound()
				
				self:DeleteSave( res.fullpath )
				
			end
			
			local publish = vgui.Create( "SoundButton" )
			publish:SetParent( actionbg )
			publish:Dock( BOTTOM )
			publish:SetTall( tall )
			publish:SetFont( "DermaLarge" )
			publish:SetTextColor( MenuColor.fg_alt )
			publish:SetText( "#armenu_savepublish" )
			function publish:Paint( w, h )
				
				local color = MenuColor.bg_alt
				if self:IsHovered() == true then color = MenuColor.active end
				if self:IsDown() == true then color = MenuColor.selected end
				draw.RoundedBox( 4, 0, 0, w, h, color )
				
			end
			function publish.DoClick( panel )
				
				panel:DoClickSound()
				
				self:Publish( res.fullpath, res.preview )
				
			end
			
			actionbg:SetTall( ( tall * 3 ) + ( pad * 2 ) )
			
		else
			
			function load.DoClick( panel )
				
				panel:DoClickSound()
				
				steamworks.FileInfo( res, function( info )
					
					if info.previewid != nil then
						
						steamworks.Download( info.previewid, true, function( path )
							
							self:LoadSave( path )
							
						end )
						
					end
					
				end )
				
			end
			
		end
		
	end
	
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
		
		local tag
		
		local function findtag( tagname )
			
			local check = panel:Find( "tag_" .. tagname )
			if check:GetChecked() != true then return true end
			
			if tag != nil then error_:SetText( "Choose only one tag!" ) return false end
			
			tag = tagname
			return true
			
		end
		
		if findtag( "scenes" ) != true then return end
		if findtag( "machines" ) != true then return end
		if findtag( "buildings" ) != true then return end
		if findtag( "courses" ) != true then return end
		if findtag( "others" ) != true then return end
		
		if tag == nil then error_:SetText( "Choose a tag!" ) return end
		
		if title:GetText() == "" then error_:SetText( "You must provide a title!" ) return end
		
		local err = self:FinishPublish( path, icon, title:GetText(), description:GetText(), tag )
		if err != nil then error_:SetText( err ) return end
		
		panel:Remove()
		
	end
	
end

function PANEL:FinishPublish( path, icon, title, desc, tag )
	
	local info = GetSaveFileDetails( path )
	if info == nil then return "Couldn't get demo information!" end
	
	steamworks.Publish( { "save", info.map, tag }, path, icon, title, desc )
	
end



vgui.Register( "MainMenu_Saves", PANEL, "MainMenu_Workshop" )