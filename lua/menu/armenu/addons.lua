local PANEL = {}



language.Add( "armenu_addonsubscribe", "Subscribe" )
language.Add( "armenu_addonunsubscribe", "Unsubscribe" )
language.Add( "armenu_addonmount", "Mount" )
language.Add( "armenu_addonunmount", "Unmount" )

function PANEL:Init()
	
	self.Tags = { "addon" }
	self.ExtraTags = {}
	self.TagSelect = {
		
		"gamemode",
		"map",
		"weapon",
		"vehicle",
		"npc",
		"tool",
		"effects",
		"model",
		"entity",
		
	}

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
		actionbg:SetTall( tall )
		function actionbg:Paint( w, h )
		end
		
		local subscribe = vgui.Create( "SoundButton" )
		subscribe:SetParent( actionbg )
		subscribe:Dock( BOTTOM )
		subscribe:DockMargin( 0, pad, 0, 0 )
		subscribe:SetTall( tall )
		subscribe:SetFont( "DermaLarge" )
		subscribe:SetTextColor( MenuColor.fg_alt )
		subscribe:SetText( "#armenu_addonsubscribe" )
		if steamworks.IsSubscribed( res ) == true then subscribe:SetText( "#armenu_addonunsubscribe" ) end
		function subscribe:Paint( w, h )
			
			local color = MenuColor.bg_alt
			if self:IsHovered() == true then color = MenuColor.active end
			if self:IsDown() == true then color = MenuColor.selected end
			draw.RoundedBox( 4, 0, 0, w, h, color )
			
		end
		function subscribe:DoClick()
			
			self:DoClickSound()
			
			if steamworks.IsSubscribed( res ) == true then
				
				steamworks.Unsubscribe( res )
				
			else
				
				steamworks.Subscribe( res )
				
			end
			steamworks.ApplyAddons()
			
		end
		
		if steamworks.IsSubscribed( res ) == true then
			
			local mount = vgui.Create( "SoundButton" )
			mount:SetParent( actionbg )
			mount:Dock( BOTTOM )
			mount:SetTall( tall )
			mount:SetFont( "DermaLarge" )
			mount:SetTextColor( MenuColor.fg_alt )
			mount:SetText( "#armenu_addonmount" )
			if steamworks.ShouldMountAddon( res ) == true then mount:SetText( "#armenu_addonunmount" ) end
			function mount:Paint( w, h )
				
				local color = MenuColor.bg_alt
				if self:IsHovered() == true then color = MenuColor.active end
				if self:IsDown() == true then color = MenuColor.selected end
				draw.RoundedBox( 4, 0, 0, w, h, color )
				
			end
			function mount:DoClick()
				
				self:DoClickSound()
				
				steamworks.SetShouldMountAddon( res, !steamworks.ShouldMountAddon( res ) )
				steamworks.ApplyAddons()
				
			end
			
			actionbg:SetTall( ( tall * 2 ) + pad )
			
		end
		
		hook.Add( "GameContentChanged", "RefreshAddonInfo", function()
			
			if IsValid( self ) == true then self:CreateInfo( res ) end
			
		end )
		
	end
	
end



vgui.Register( "MainMenu_Addons", PANEL, "MainMenu_Workshop" )