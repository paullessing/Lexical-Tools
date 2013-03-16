include('shared.lua')

local X = -50
local Y = -100
local W = 100
local H = 200

local KeyPos = {
	{X+5   , Y+100  , 25, 25, -2.2, 3.45,  1.3 ,  0  },
	{X+37.5, Y+100  , 25, 25, -0.6, 1.85,  1.3 ,  0  },
	{X+70  , Y+100  , 25, 25,  1.0, 0.25,  1.3 ,  0  },
	
	{X+5   , Y+132.5, 25, 25, -2.2, 3.45,  2.9 , -1.6},
	{X+37.5, Y+132.5, 25, 25, -0.6, 1.85,  2.9 , -1.6},
	{X+70  , Y+132.5, 25, 25,  1.0, 0.25,  2.9 , -1.6},
	
	{X+5   , Y+165  , 25, 25, -2.2, 3.45,  4.55, -3.3},
	{X+37.5, Y+165  , 25, 25, -0.6, 1.85,  4.55, -3.3},
	{X+70  , Y+165  , 25, 25,  1.0, 0.25,  4.55, -3.3},
	
	{X+5   , Y+ 67.5, 40, 25, -2.2, 4.25, -0.3 ,  1.6},
	{X+55  , Y+ 67.5, 40, 25,  0.3, 1.65, -0.3 ,  1.6},
}

surface.CreateFont("Trebuchet34", {
    font   = "Trebuchet";
    size   = 34;
    weight = 400;
})
surface.CreateFont("Trebuchet24AA", {
    font   = "Trebuchet";
    size   = 24;
    weight = 400;
})

function ENT:Draw()
	
	self:DrawModel()
	local Ply = LocalPlayer()
	
	local Dist = (Ply:GetShootPos() - self:GetPos()):Length()
	if (Dist > 750) then return end
	
	local pos = self:GetPos() + (self:GetForward() * 1.1)
	local ang = self:GetAngles()
	local rot = Vector(-90, 90, 0)
	
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	
	cam.Start3D2D(pos, ang, 0.05)
		local trace = Ply:GetEyeTrace()
		
		local pos = self:WorldToLocal(trace.HitPos)
		local Num = self.dt.Password;
		local Access = self.dt.Access;
		local ShowAccess = self.dt.ShowAccess;
		local Secure = self.dt.Secure;
		
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(X-5, Y-5, W+10, H+10)
		
		surface.SetDrawColor(50, 75, 50, 255)
		surface.DrawRect(X+5, Y+5, 90, 50)
		
		for k,v in pairs(KeyPos) do
			local text = k
			local textx = v[1] + 9
			local texty = v[2] + 4
			local x = (pos.y - v[5]) / (v[5] + v[6])
			local y = 1 - (pos.z + v[7]) / (v[7] + v[8])
			
			if (k == 10) then
				text = "ABORT"
				textx = v[1] + 2
				texty = v[2] + 4
				surface.SetDrawColor(150, 25, 25, 255)
			elseif (k == 11) then
				text = "OK"
				textx = v[1] + 12
				texty = v[2] + 5
				surface.SetDrawColor(25, 150, 25, 255)
			else
				surface.SetDrawColor(150, 150, 150, 255)
			end
			
			if (trace.Entity == self) and (x >= 0) and (y >= 0) and (x <= 1) and (y <= 1) then
				if (k <= 9) then
					surface.SetDrawColor(200, 200, 200, 255)
				elseif (k == 10) then
					surface.SetDrawColor(200, 50, 50, 255)
				elseif (k == 11) then
					surface.SetDrawColor(50, 200, 50, 255)
				end
				
				if (Ply:KeyDown(IN_USE)) and not (Ply.KeyOnce) then
                    -- AAAAAAAAAAA WHY IS THIS IN :DRAW()?!?!?!?!
                    local cmd;
                    if (k == 10) then
                        cmd = 'reset';
                    elseif (k == 11) then
                        cmd = 'accept';
                    else
                        cmd = tostring(k);
                    end
                    net.Start('gmod_keypad');
                    net.WriteString(cmd);
                    net.SendToServer();
					Ply.KeyOnce = true
				end
			end
			surface.DrawRect(v[1], v[2], v[3], v[4])
			draw.DrawText(text, "Trebuchet18", textx, texty, Color(0, 0, 0, 255))
		end
		
		if (Num != 0) and not (ShowAccess) then
			if (Secure) then
				local Text = string.rep("*", string.len(Num))
				draw.DrawText(Text, "Trebuchet34", X+17, Y+10, Color(255, 255, 255, 255))
			else
				draw.DrawText(Num, "Trebuchet34", X+17, Y+10, Color(255, 255, 255, 255))
			end
		elseif (Access) and (ShowAccess) then
			draw.DrawText("ACCESS","Trebuchet24AA", X+17, Y+7, Color(0, 255, 0, 255))
			draw.DrawText("GRANTED","Trebuchet24AA", X+7, Y+27, Color(0, 255, 0, 255))
		elseif not (Access) and (ShowAccess) then
			draw.DrawText("ACCESS","Trebuchet24", X+17, Y+7, Color(255, 0, 0, 255))
			draw.DrawText("DENIED","Trebuchet24", X+19, Y+27, Color(255, 0, 0, 255))
		end
		
	cam.End3D2D()
	
end

hook.Add("KeyRelease", "Keypad_KeyReleased", function(Ply, key)
	Ply.KeyOnce = false
end)
