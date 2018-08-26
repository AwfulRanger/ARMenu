local PANEL = {}



language.Add( "armenu_addonsubscribe", "Subscribe" )
language.Add( "armenu_addonunsubscribe", "Unsubscribe" )
language.Add( "armenu_addonmount", "Mount" )
language.Add( "armenu_addonunmount", "Unmount" )
language.Add( "armenu_addonsubscribeselected", "Subscribe selected" )
language.Add( "armenu_addonunsubscribeselected", "Unsubscribe selected" )
language.Add( "armenu_addonmountselected", "Mount selected" )
language.Add( "armenu_addonunmountselected", "Unmount selected" )

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
	
	self.SelectedAddons = {}
	
end

local notsubscribed = Material( "html/img/notinstalled.png" )
local unmounted = Material( "html/img/notowned.png" )
local mounted = Material( "html/img/enabled.png" )
local checkmat = Material( "html/img/enabled.png" )

function PANEL:CreateButton( parent, x, y, w, h, res, ... )
	
	local button = self.BaseClass.CreateButton( self, parent, x, y, w, h, res, ... )
	local paint = button.Paint
	function button:Paint( w, h, ... )
		
		local ret = paint( self, w, h, ... )
		
		local spad = math.Round( h * 0.1 )
		local s = math.min( 16, h - ( spad * 2 ) )
		local bgpad = math.min( 2, h )
		
		local mat = mounted
		if steamworks.ShouldMountAddon( res ) ~= true then mat = unmounted end
		if steamworks.IsSubscribed( res ) ~= true then mat = notsubscribed end
		
		draw.RoundedBox( 4, w - s - spad - bgpad, h - s - spad - bgpad, s + ( bgpad * 2 ), s + ( bgpad * 2 ), MenuColor.bgdim )
		
		surface.SetDrawColor( MenuColor.white )
		surface.SetMaterial( mat )
		surface.DrawTexturedRect( w - s - spad, h - s - spad, s, s )
		
		return ret
		
	end
	
	local check = vgui.Create( "DCheckBox" )
	check:SetParent( button )
	check:SetChecked( self.SelectedAddons[ res ] == true )
	function check.OnChange( panel, new )
		
		self.SelectedAddons[ res ] = new or nil
		
	end
	function check:Paint( w, h )
		
		local checked = self:GetChecked()
		
		surface.SetDrawColor( MenuColor.bgdim_alt )
		if checked == true then surface.SetDrawColor( MenuColor.selected ) end
		surface.DrawRect( 0, 0, w, h )
		
		if checked == true then
			
			local s = math.min( 16, w, h )
			surface.SetDrawColor( MenuColor.white )
			surface.SetMaterial( checkmat )
			surface.DrawTexturedRect( ( w * 0.5 ) - ( s * 0.5 ), ( h * 0.5 ) - ( s * 0.5 ), s, s )
			
		end
		
		surface.SetDrawColor( MenuColor.fg_alt )
		surface.DrawOutlinedRect( 0, 0, w, h )
		
	end
	
	local buttondoclick = button.DoClick
	function button.DoClick( ... )
		
		if input.IsShiftDown() == true then
			
			check:Toggle()
			
		else
			
			buttondoclick( ... )
			
		end
		
	end
	function button:PerformLayout( w, h )
		
		local spad = math.Round( h * 0.1 )
		local s = math.min( 16, h - ( spad * 2 ) )
		
		check:SetPos( spad, h - s - spad )
		check:SetSize( s, s )
		
	end
	
	return button
	
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

function PANEL:CreateCategories( ... )
	
	self.BaseClass.CreateCategories( self, ... )
	
	local pad = ScrH() * 0.01
	
	local unmount = vgui.Create( "SoundButton" )
	unmount:SetParent( self.catbg )
	unmount:Dock( BOTTOM )
	unmount:DockMargin( 0, 0, 0, pad )
	unmount:SetTall( ScrH() * 0.025 )
	unmount:SetFont( "DermaDefaultBold" )
	unmount:SetText( "#armenu_addonunmountselected" )
	function unmount:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function unmount.DoClick( button )
		
		button:DoClickSound()
		
		for _, v in pairs( self.SelectedAddons ) do
			
			if v == true then steamworks.SetShouldMountAddon( _, false ) end
			
		end
		
		steamworks.ApplyAddons()
		
	end
	
	local mount = vgui.Create( "SoundButton" )
	mount:SetParent( self.catbg )
	mount:Dock( BOTTOM )
	mount:DockMargin( 0, 0, 0, pad )
	mount:SetTall( ScrH() * 0.025 )
	mount:SetFont( "DermaDefaultBold" )
	mount:SetText( "#armenu_addonmountselected" )
	function mount:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function mount.DoClick( button )
		
		button:DoClickSound()
		
		for _, v in pairs( self.SelectedAddons ) do
			
			if v == true then steamworks.SetShouldMountAddon( _, true ) end
			
		end
		
		steamworks.ApplyAddons()
		
	end
	
	local unsubscribe = vgui.Create( "SoundButton" )
	unsubscribe:SetParent( self.catbg )
	unsubscribe:Dock( BOTTOM )
	unsubscribe:DockMargin( 0, 0, 0, pad )
	unsubscribe:SetTall( ScrH() * 0.025 )
	unsubscribe:SetFont( "DermaDefaultBold" )
	unsubscribe:SetText( "#armenu_addonunsubscribeselected" )
	function unsubscribe:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function unsubscribe.DoClick( button )
		
		button:DoClickSound()
		
		for _, v in pairs( self.SelectedAddons ) do
			
			if v == true then steamworks.Unsubscribe( _ ) end
			
		end
		
		steamworks.ApplyAddons()
		
	end
	
	local subscribe = vgui.Create( "SoundButton" )
	subscribe:SetParent( self.catbg )
	subscribe:Dock( BOTTOM )
	subscribe:DockMargin( 0, 0, 0, pad )
	subscribe:SetTall( ScrH() * 0.025 )
	subscribe:SetFont( "DermaDefaultBold" )
	subscribe:SetText( "#armenu_addonsubscribeselected" )
	function subscribe:Paint( w, h )
		
		local color = MenuColor.bg_alt
		if self:IsHovered() == true then color = MenuColor.active end
		if self:IsDown() == true then color = MenuColor.selected end
		draw.RoundedBox( 4, 0, 0, w, h, color )
		
	end
	function subscribe.DoClick( button )
		
		button:DoClickSound()
		
		for _, v in pairs( self.SelectedAddons ) do
			
			if v == true then steamworks.Subscribe( _ ) end
			
		end
		
		steamworks.ApplyAddons()
		
	end
	
end



vgui.Register( "MainMenu_Addons", PANEL, "MainMenu_Workshop" )