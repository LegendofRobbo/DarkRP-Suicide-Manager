
local SM = {}
SM.DeathTime = 10

if SERVER then
util.AddNetworkString( "SM_KillYourself" )
util.AddNetworkString( "SM_CancelSuicide" )

local crybaby = {
	"vo/npc/male01/gordead_ans12.wav",
	"vo/npc/male01/gordead_ans11.wav",
	"vo/npc/male01/gordead_ans13.wav",
	"vo/npc/male01/gordead_ans02.wav",
}

hook.Add( "CanPlayerSuicide", "emofaggotsgetout", function( ply )
	if !ply:IsValid() or !ply:Alive() then return false end
	if !ply:GetNWBool( "sm_suiciding" ) then
		ply:EmitSound( table.Random(crybaby), 100, 100 )
		ply:SetNWBool( "sm_suiciding", true )
		net.Start( "SM_KillYourself" )
		net.Send( ply )
		timer.Create( "suicidetimer_"..ply:UniqueID(), SM.DeathTime, 1, function() if ply:IsValid() and ply:Alive() then ply:Kill() end end)
	end
return false
end)

net.Receive( "SM_CancelSuicide", function( len, ply ) ply:SetNWBool( "sm_suiciding", false ) timer.Remove( "suicidetimer_"..ply:UniqueID() ) end )

hook.Add("PlayerSpawn", "reset_sm_suicides", function(ply) ply:SetNWBool( "sm_suiciding", false ) end)
hook.Add("PlayerDeath", "reset_sm_suicides2", function(ply, inf, atk ) ply:SetNWBool( "sm_suiciding", false ) timer.Remove( "suicidetimer_"..ply:UniqueID() ) end)

end


if CLIENT then
	
local function SuicideMenu()
if vgui_SuicideMenu then vgui_SuicideMenu:Remove() end

local deathtime = CurTime() + SM.DeathTime
vgui_SuicideMenu = vgui.Create("DFrame")
vgui_SuicideMenu:SetSize(350,150)
vgui_SuicideMenu:SetTitle("Suiciding...")
vgui_SuicideMenu:Center()
vgui_SuicideMenu:ShowCloseButton( false )
vgui_SuicideMenu:MakePopup()

vgui_SuicideMenu.Paint = function( self, w, h)
surface.SetDrawColor( Color(0, 0, 0, 195) )
surface.DrawRect( 0, 0, w, h )
surface.SetDrawColor( Color(50, 50, 50, 255) )
surface.DrawOutlinedRect( 0, 0, w, h )
draw.SimpleText("You will die in: "..math.Round( (deathtime + 0.25) - CurTime()).." seconds", "DermaLarge", 15, 45, Color(255, 255, 255, 200), 0, 1)
end

vgui_SuicideMenu.Think = function( self )
if !LocalPlayer():Alive() or (deathtime - CurTime()) < 0 then self:Remove() end
end


    local faggot = vgui.Create("DButton", vgui_SuicideMenu)
    faggot:SetSize( 200, 35 )
    faggot:SetPos( 75, 80 )
    faggot:SetText("Stop! I want to live!")
    faggot:SetTextColor(Color(255, 255, 255, 255))
    faggot.Paint = function(panel, w, h)
        surface.SetDrawColor(100, 200, 100 ,255)
        surface.DrawOutlinedRect(0, 0, w, h)
        surface.SetDrawColor(0, 50, 0 ,155)
        surface.DrawRect(0, 0, w, h)
    end
    faggot.DoClick = function()
    	net.Start( "SM_CancelSuicide" )
    	net.SendToServer()
    	vgui_SuicideMenu:Remove()
    end

end

net.Receive( "SM_KillYourself", SuicideMenu)

hook.Add("HUDPaint", "sm_drawemos", function() 
	local trace = {}
	trace.start = LocalPlayer():EyePos()
	trace.endpos = trace.start + LocalPlayer():GetAimVector() * 500
	trace.filter = LocalPlayer()
	
	local tr = util.TraceLine( trace )
	if !tr.Entity:IsValid() then return end
	if tr.Entity:IsPlayer() and tr.Entity:GetNWBool( "sm_suiciding" ) then
	local tpos = (tr.Entity:GetPos() + Vector(0,0,50)):ToScreen()
		draw.SimpleText("SUICIDING!", "DermaLarge", tpos.x, tpos.y, Color(255, 5, 5, 255), 1, 1)
	end

end)


end