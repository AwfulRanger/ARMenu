local PANEL = {}



language.Add( "armenu_promptyes", "Yes" )
language.Add( "armenu_promptno", "No" )

function PANEL:Init()
	
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), ScrH() )
	
	self.label = vgui.Create( "DLabel" )
	self.label:SetParent( self )
	self.label:SetFont( "DermaLarge" )
	self.label:SetText( "" )
	function self.label:Paint( w, h )
		
		local text = self:GetText()
	
		surface.SetFont( self:GetFont() )
		
		local tw, th = surface.GetTextSize( text )
		
		local x = ( w * 0.5 ) - ( tw * 0.5 )
		local y = ( h * 0.5 ) - ( th * 0.5 )
		local sh = ScrW() * 0.0015
		
		surface.SetTextColor( MenuColor.bg )
		surface.SetTextPos( x + sh, y + sh )
		surface.DrawText( text )
		
		surface.SetTextColor( MenuColor.fg )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		return true
		
	end
	
	self.yes = vgui.Create( "SoundButton" )
	self.yes:SetParent( self )
	self.yes:SetFont( "DermaLarge" )
	self.yes:SetText( "#armenu_promptyes" )
	function self.yes:Paint( w, h )
		
		local color = MenuColor.dullinactive
		if self:IsHovered() == true then color = MenuColor.dullactive end
		
		draw.RoundedBox( 8, 0, 0, w, h, color )
		
		local text = self:GetText()
	
		surface.SetFont( self:GetFont() )
		
		local tw, th = surface.GetTextSize( text )
		
		local x = ( w * 0.5 ) - ( tw * 0.5 )
		local y = ( h * 0.5 ) - ( th * 0.5 )
		local sh = ScrW() * 0.0015
		
		surface.SetTextColor( MenuColor.bg )
		surface.SetTextPos( x + sh, y + sh )
		surface.DrawText( text )
		
		surface.SetTextColor( MenuColor.fg )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		return true
		
	end
	self.yes.DoClick = function( panel )
		
		panel:DoClickSound()
		
		self:Remove()
		self:OnYes()
		
	end
	
	self.no = vgui.Create( "SoundButton" )
	self.no:SetParent( self )
	self.no:SetFont( "DermaLarge" )
	self.no:SetText( "#armenu_promptno" )
	function self.no:Paint( w, h )
		
		local color = MenuColor.dullinactive
		if self:IsHovered() == true then color = MenuColor.dullactive end
		
		draw.RoundedBox( 8, 0, 0, w, h, color )
		
		local text = self:GetText()
	
		surface.SetFont( self:GetFont() )
		
		local tw, th = surface.GetTextSize( text )
		
		local x = ( w * 0.5 ) - ( tw * 0.5 )
		local y = ( h * 0.5 ) - ( th * 0.5 )
		local sh = ScrW() * 0.0015
		
		surface.SetTextColor( MenuColor.bg )
		surface.SetTextPos( x + sh, y + sh )
		surface.DrawText( text )
		
		surface.SetTextColor( MenuColor.fg )
		surface.SetTextPos( x, y )
		surface.DrawText( text )
		
		return true
		
	end
	self.no.ClickSound = self.no.ReturnSound
	self.no.DoClick = function( panel )
		
		panel:DoClickSound()
		
		self:Remove()
		self:OnNo()
		
	end
	
end

function PANEL:PerformLayout( w, h )
	
	self.label:SizeToContents()
	self.label:Center()
	
	self.yes:SetPos( w * 0.35, h * 0.6 )
	self.yes:SetSize( w * 0.1, h * 0.1 )
	
	self.no:SetPos( w * 0.55, h * 0.6 )
	self.no:SetSize( w * 0.1, h * 0.1 )
	
end

function PANEL:Paint( w, h )
	
	surface.SetDrawColor( MenuColor.bgdim )
	surface.DrawRect( 0, 0, w, h )
	
end

function PANEL:OnYes()
end

function PANEL:OnNo()
end

function PANEL:SetText( ... )
	
	self.label:SetText( ... )
	
end



vgui.Register( "YesNoPrompt", PANEL, "DPanel" )