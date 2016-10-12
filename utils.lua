local M={}
function M.newUtil()
	-- body
	utility={}
	function utility:csplit(str,sep )
		local ret={}
        local n=1
        for w in str:gmatch("([^"..sep.."]*)") do
                        ret[n]=ret[n] or w -- only set once (so the blank after a string is ignored)
                        if w=="" then n=n+1 end -- step forwards on a blank but not a string
        end
        return ret
	end
	function utility:splitUrl(url)
		-- body
		--print(url)
		if url~="" then
			local domain = url:match("^%w+://([^/]+)")
			return self:csplit(domain,"%.")[2]
		end
		return nil
	end
	return utility


end
return M

