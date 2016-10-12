local M={}
function M.newToggle(title)
	local grp=display.newGroup()	
	local btn=display.newRect(0,0,128,50)
	local txt=display.newText(title,0,0,native.systemFont,12)
	txt:setFillColor(0,0,0)
	btn.strokeWidth=1.5
	btn:setStrokeColor(0.9,0.9,0.9)
	btn.isOn=true
	function grp:toggle()
		if btn.isOn then 
			btn.isOn=false
			btn:setStrokeColor(0.5,0.5,0.0)
		else
			btn.isOn=true
			btn:setStrokeColor(0.9,0.9,0.9)
		end
	end
	function grp:setOff(  )
		-- body
		if btn~=nil then
			btn.isOn=true
			btn:setStrokeColor(0.9,0.9,0.9)
		end
	end
	function grp:setOn()
		if btn~=nil then
			btn.isOn=false
			btn:setStrokeColor(0.5,0.5,0.0)
		end
		
	end
	btn.anchorX=0
	btn.anchorY=0
	txt.anchorX=0
	txt.anchorY=0
	txt.x=btn.width/2-txt.width/2
	txt.y=btn.height/2-txt.height/2
	grp:insert(btn)
	grp:insert(txt)
	grp.x=100

	return grp
	
end
return M