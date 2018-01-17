local PANEL = {}



language.Add( "armenu_demoplay", "Play" )
language.Add( "armenu_demotovideo", "Make video" )
language.Add( "armenu_demodelete", "Delete" )
language.Add( "armenu_demopublish", "Publish" )

language.Add( "armenu_demoplayprompt", "Play this demo?" )
language.Add( "armenu_demotovideoprompt", "Convert this demo to video?" )
language.Add( "armenu_demodeleteprompt", "Are you sure you want to delete this demo?" )

local items = 25

function PANEL:Init()
	
	self.Tags = { "demo" }
	self.ExtraTags = {}
	self.TagSelect = {}

	self.CategoryPrefix = "demos"
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
	
	if self.CacheEnabled == true then
		
		local cacheddata, cachedpages = self:GetCachedList( "local", "", page )
		if cacheddata ~= nil and cachedpages ~= nil then callback( cacheddata, cachedpages ) return end
		
	end
	
	local f = file.Find( "demos/*.dem", "MOD", "datedesc" )
	
	local num = math.min( 25, #f - ( items * ( page - 1 ) ) )
	
	local data = {
		
		numresults = num,
		totalresults = #f,
		results = {}
		
	}
	
	for i = 1, #f do
		
		local a = f[ i + ( items * ( page - 1 ) ) ]
		if a ~= nil then
			
			local strip = string.StripExtension( a )
			table.insert( data.results, {
				
				path = a,
				name = strip,
				preview = "demos/" .. strip .. ".jpg",
				fullpath = "demos/" .. a,
				time = file.Time( "demos/" .. a, "MOD" ),
				
			} )
			
		end
		
	end
	
	if self.CacheEnabled == true then self:CacheList( "local", "", page, data ) end
	callback( data, math.ceil( data.totalresults / items ) )
	
end

function PANEL:PlayDemo( path )
	
	local prompt = vgui.Create( "YesNoPrompt" )
	prompt:SetText( "#armenu_demoplayprompt" )
	function prompt:OnYes() RunConsoleCommand( "playdemo", path ) end
	prompt:MakePopup()
	
end

function PANEL:DemoToVideo( path )
	
	local prompt = vgui.Create( "YesNoPrompt" )
	prompt:SetText( "#armenu_demotovideoprompt" )
	function prompt:OnYes() RunConsoleCommand( "gm_demo_to_video", path ) end
	prompt:MakePopup()
	
end

function PANEL:DeleteDemo( path )
	
	local prompt = vgui.Create( "YesNoPrompt" )
	prompt:SetText( "#armenu_demodeleteprompt" )
	function prompt.OnYes()
		
		file.Delete( path, "MOD" )
		self:CreateList( "local" )
		self:CreateInfo()
		
	end
	prompt:MakePopup()
	
end

function PANEL:CreateInfo( res, ... )
	
	self.BaseClass.CreateInfo( self, res, ... )
	
	if res ~= nil then
		
		local pad = math.Round( ScrH() * 0.01 )
		local tall = math.Round( ScrH() * 0.05 )
		
		local actionbg = vgui.Create( "DPanel" )
		actionbg:SetParent( self.info )
		actionbg:Dock( BOTTOM )
		actionbg:DockMargin( 0, pad, 0, 0 )
		actionbg:SetTall( ( tall * 2 ) + pad )
		function actionbg:Paint( w, h )
		end
		
		local play = vgui.Create( "SoundButton" )
		play:SetParent( actionbg )
		play:Dock( BOTTOM )
		play:SetTall( tall )
		play:SetFont( "DermaLarge" )
		play:SetTextColor( MenuColor.fg_alt )
		play:SetText( "#armenu_demoplay" )
		function play:Paint( w, h )
			
			local color = MenuColor.bg_alt
			if self:IsHovered() == true then color = MenuColor.active end
			if self:IsDown() == true then color = MenuColor.selected end
			draw.RoundedBox( 4, 0, 0, w, h, color )
			
		end
		
		local tovideo = vgui.Create( "SoundButton" )
		tovideo:SetParent( actionbg )
		tovideo:Dock( BOTTOM )
		tovideo:DockMargin( 0, 0, 0, pad )
		tovideo:SetTall( tall )
		tovideo:SetFont( "DermaLarge" )
		tovideo:SetTextColor( MenuColor.fg_alt )
		tovideo:SetText( "#armenu_demotovideo" )
		function tovideo:Paint( w, h )
			
			local color = MenuColor.bg_alt
			if self:IsHovered() == true then color = MenuColor.active end
			if self:IsDown() == true then color = MenuColor.selected end
			draw.RoundedBox( 4, 0, 0, w, h, color )
			
		end
		
		if istable( res ) == true then
			
			function play.DoClick( panel )
				
				panel:DoClickSound()
				
				self:PlayDemo( res.fullpath )
				
			end
			function tovideo.DoClick( panel )
				
				panel:DoClickSound()
				
				self:DemoToVideo( res.fullpath )
				
			end
			
			local delete = vgui.Create( "SoundButton" )
			delete:SetParent( actionbg )
			delete:Dock( BOTTOM )
			delete:DockMargin( 0, pad, 0, pad )
			delete:SetTall( tall )
			delete:SetFont( "DermaLarge" )
			delete:SetTextColor( MenuColor.fg_alt )
			delete:SetText( "#armenu_demodelete" )
			function delete:Paint( w, h )
				
				local color = MenuColor.bg_alt
				if self:IsHovered() == true then color = MenuColor.active end
				if self:IsDown() == true then color = MenuColor.selected end
				draw.RoundedBox( 4, 0, 0, w, h, color )
				
			end
			function delete.DoClick( panel )
				
				panel:DoClickSound()
				
				self:DeleteDemo( res.fullpath )
				
			end
			
			local publish = vgui.Create( "SoundButton" )
			publish:SetParent( actionbg )
			publish:Dock( BOTTOM )
			publish:SetTall( tall )
			publish:SetFont( "DermaLarge" )
			publish:SetTextColor( MenuColor.fg_alt )
			publish:SetText( "#armenu_demopublish" )
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
			
			actionbg:SetTall( ( tall * 4 ) + ( pad * 3 ) )
			
		else
			
			function play.DoClick( panel )
				
				panel:DoClickSound()
				
				steamworks.FileInfo( res, function( info )
					
					if info.previewid ~= nil then
						
						steamworks.Download( info.previewid, true, function( path )
							
							self:PlayDemo( path )
							
						end )
						
					end
					
				end )
				
			end
			function tovideo.DoClick( panel )
				
				panel:DoClickSound()
				
				steamworks.FileInfo( res, function( info )
					
					if info.previewid ~= nil then
						
						steamworks.Download( info.previewid, true, function( path )
							
							self:DemoToVideo( path )
							
						end )
						
					end
					
				end )
				
			end
			
		end
		
	end
	
end

function PANEL:FinishPublish( path, icon, title, desc )
	
	local info = GetDemoFileDetails( path )
	if info == nil then return "Couldn't get demo information!" end
	
	steamworks.Publish( { "demo", info.mapname }, path, icon, title, desc )
	
end



vgui.Register( "MainMenu_Demos", PANEL, "MainMenu_Workshop" )