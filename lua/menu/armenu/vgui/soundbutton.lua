local PANEL = {}



PANEL.HoverSound = "garrysmod/ui_hover.wav"
PANEL.ClickSound = "garrysmod/ui_click.wav"
PANEL.ReturnSound = "garrysmod/ui_return.wav"

PANEL.CurHover = false

function PANEL:DoHoverSound( snd )
	
	local hover = self:IsHovered()
	if hover != self.CurHover then
		
		snd = snd or self.HoverSound
		
		if hover == true and snd != nil then surface.PlaySound( snd ) end
		self.CurHover = hover
		
	end
	
end

function PANEL:Think()
	
	self:DoHoverSound()
	
end

function PANEL:DoClickSound( snd )
	
	snd = snd or self.ClickSound
	
	if snd != nil then surface.PlaySound( snd ) end
	
end

function PANEL:DoClick()
	
	self:DoClickSound()
	
end



vgui.Register( "SoundButton", PANEL, "DButton" )