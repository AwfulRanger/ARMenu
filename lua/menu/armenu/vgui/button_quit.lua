local PANEL = {}



language.Add( "quit.text", "Are you sure you want to quit?" )
language.Add( "quit.yes", "Yes" )
language.Add( "quit.no", "No" )

function PANEL:Init()
	
	self:SetText( "#quit" )
	self:InvalidateLayout( true )
	
end

function PANEL:DoClick()
	
	if IsValid( self.quitmenu ) == true then self.quitmenu:Remove() end
	
	self.quitmenu = vgui.Create( "DPanel" )
	self.quitmenu:SetPos( 0, 0 )
	self.quitmenu:SetSize( ScrW(), ScrH() )
	function self.quitmenu:Paint( w, h )
		
		surface.SetDrawColor( 0, 0, 0, 200 )
		surface.DrawRect( 0, 0, w, h )
		
	end
	self.quitmenu:MakePopup()
	
	local label = vgui.Create( "DLabel" )
	label:SetParent( self.quitmenu )
	label:SetFont( "DermaLarge" )
	label:SetText( "#quit.text" )
	label:SizeToContents()
	label:Center()
	function label:Paint( w, h )
		
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
	
	local yes = vgui.Create( "DButton" )
	yes:SetParent( self.quitmenu )
	yes:SetFont( "DermaLarge" )
	yes:SetText( "#quit.yes" )
	yes:SetPos( ScrW() * 0.35, ScrH() * 0.6 )
	yes:SetSize( ScrW() * 0.1, ScrH() * 0.1 )
	function yes:Paint( w, h )
		
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
	yes.DoClick = function( panel )
		
		self.quitmenu:Remove()
		RunGameUICommand( "quit" )
		
	end
	
	local no = vgui.Create( "DButton" )
	no:SetParent( self.quitmenu )
	no:SetFont( "DermaLarge" )
	no:SetText( "#quit.no" )
	no:SetPos( ScrW() * 0.55, ScrH() * 0.6 )
	no:SetSize( ScrW() * 0.1, ScrH() * 0.1 )
	function no:Paint( w, h )
		
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
	no.DoClick = function( panel )
		
		self.quitmenu:Remove()
		
	end
	
end



vgui.Register( "Button_Quit", PANEL, "MainMenuButton" )