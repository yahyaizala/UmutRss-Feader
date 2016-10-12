local sqlite3=require "sqlite3"
local widget=require "widget"
local onTaps=function(event)
	print("clicked")
end
local xml=require("xml").newParser()
local toggle=require("toggle")
display.setStatusBar(display.HiddenStatusBar )
local path=system.pathForFile("umutrssfeader.db",system.DocumentsDirectory)
local newsTable = [[CREATE TABLE IF NOT EXISTS 
news (id INTEGER PRIMARY KEY autoincrement,name TEXT);]]
local rssTable= [[CREATE TABLE IF NOT EXISTS 
rss (id INTEGER PRIMARY KEY autoincrement,to_id INTEGER,category TEXT,urls TEXT);]]
local news={"Haber Türk","Sabah","BBC","Cumhuriyet","A Haber"}
local W=display.contentWidth
local H=display.contentHeight
local utilityBtns={}
local function onCategoryEntered(event)
	catToAdd=event.target.text
	return true
end
local lookUp=function( event )
	-- body
	local myFeed=xml:ParseXmlText(event.response)		
	local items = myFeed.child[1].child
	local item=items[1]
	if items.name=="item" then
			local sql="insert into news(name) values('"..domain.."');"
			db:exec(sql)
			local id=0
			sql="select id from news where name=='"..domain.."';"
			for d in db:nrows(sql) do
				id=d.id
				break
			end
			if id>0 then
				local sql="insert into rss(to_id,category,urls) values('"..id.."','"..catToAdd.."','"..myText.."');"
				db:exec(sql)
				rollBackEdit()
				return true
			end



	else
		native.showAlert("Uyarı!","Hatalı rss feed eklediniz!")
		return false
	end	

end
local onDomainEntered=function(event)
	if event.phase=="ended" or event.phase=="submitted" then
		mText=event.target.text
		if mText=="" then
			return false
		end
		if not mText:match("^%w+://") then
			mText="http://"..mText
		end
		if catToAdd~=nil or catToAdd~="" then
			local util=require("utils").newUtil()
			domain=util:splitUrl(mText)
			network.request(mText,"GET",lookUp,params)			
		end
		return true

	end
	return false	

end
function rollBackEdit( event )
	-- body
	if editPanel~=nil then
		event.target:removeEventListener("tap",rollBackEdit)		
		editPanel:removeSelf()
		editPanel=nil
		event.target:removeSelf()
		event.target=nil
		return true
	end
	return false
end
local function loadSettings(event)
	local fakeBg=display.newRect(0,0,W,H*1.5)
	editPanel=display.newGroup()
	fakeBg.x=0;fakeBg.y=0
	fakeBg.anchorX=0;fakeBg.anchorY=0
	fakeBg:toFront()
	fakeBg:addEventListener("tap",rollBackEdit)
	local msg=display.newText("Kategori Giriniz",W/2-60,H/2-60,300,30)
	msg.anchorX=0
	msg.anchorY=0
	--msg.align="left"
	msg:setFillColor(0,0,0)
	local txt=native.newTextField(W/2,H/2,280,30)
	txt.isEditable=true
	txt:addEventListener("userInput",onCategoryEntered)
	local msg2=display.newText("Rss Kaynağı Giriniz",msg.x,txt.y+txt.height,300,30)
	msg2.anchorX=0
	msg2.anchorY=0
	msg2:setFillColor(0,0,0)
	local txt2=native.newTextField(txt.x,msg2.y+msg2.height+10,280,30)
	txt2.isEditable=true
	txt2:addEventListener("userInput",onDomainEntered)
	msg:toFront()
	txt:toFront()
	editPanel:insert(fakeBg)
	editPanel:insert(msg)
	editPanel:insert(txt)
	editPanel:insert(msg2)
	editPanel:insert(txt2)
	editPanel.alpha=0
	transition.to(editPanel,{alpha=1,time=300})
	return true


end
local function cleanHtml(tString)
		-- body
	local cleaner = {
		{ "&amp;", "&" },
		{ "&#151;", "-" },
		{ "&#146;", "'" },
		{ "&#160;", " " },
		{ "<br.*/>", "\n" },
		{ "</p>", "\n" },
		{ "(%b<>)", "\n" },
		{ "\n\n*", "\n" },
		{ "\n*$", "\n" },
		{ "^\n*", ""},
		{"<a/*","\n"},
		{"Devamı için tıklayınız","\n"
		}	
	}
	for i=1, #cleaner do
		local cleans = cleaner[i]
		tString = string.gsub( tString, cleans[1], cleans[2] )

	end
	return tString
end
local ht={
	id=1,
	{name="Gündem",url="http://www.haberturk.com/rss/manset.xml"},
	{name="Siyaset",url="http://www.haberturk.com/rss/kategori/siyaset.xml"},
    {name="Dünya",url="http://www.haberturk.com/rss/kategori/dunya.xml"},
    {name="Yaşam", url="http://www.haberturk.com/rss/kategori/yasam.xml"},
    {name="Sanat",url="http://www.haberturk.com/rss/kultur-sanat.xml"},
    {name="Ekonomi",url="http://www.haberturk.com/rss/ekonomi.xml"},
    {name="Spor",url="http://www.haberturk.com/rss/spor.xml"}}
local sbh={
	id=2,
	{name="Gündem",url="http://www.sabah.com.tr/rss/gundem.xml"},
	{name="Sağlık",url="http://www.sabah.com.tr/rss/saglik.xml"},
    {name="Dünya",url="http://www.sabah.com.tr/rss/dunya.xml"},
    {name="Yaşam", url="http://www.sabah.com.tr/rss/yasam.xml"},
    {name="Sanat",url="http://www.sabah.com.tr/rss/kultur_sanat.xml"},
    {name="Ekonomi",url="http://www.sabah.com.tr/rss/ekonomi.xml"},
    {name="Spor",url="http://www.sabah.com.tr/rss/spor.xml"},
    {name="Oyun",url="http://www.sabah.com.tr/rss/oyun.xml"},
    {name="Son Dakika",url="http://www.sabah.com.tr/rss/sondakika.xml"},
    {name="Teknoloji",url="http://www.sabah.com.tr/rss/teknoloji.xml"}
}
local bbc={id=3,{name="Gündem",url="http://feeds.bbci.co.uk/turkce/rss.xml"}}
local cumh={
	id=4,
	{name="Gündem",url="http://www.cumhuriyet.com.tr/rss/1.xml"},
    {name="Dünya",url="http://www.cumhuriyet.com.tr/rss/5.xml"},
    {name="Yaşam", url="http://www.cumhuriyet.com.tr/rss/10.xml"},
    {name="Sanat",url="http://www.cumhuriyet.com.tr/rss/7.xml"},
    {name="Son Dakika",url="http://www.cumhuriyet.com.tr/rss/son_dakika.xml"}
}
local ahbr={
	id=5,
	{name="Gündem",url="http://www.ahaber.com.tr/rss/gundem.xml"},
	{name="Sağlık",url="http://www.ahaber.com.tr/rss/saglik.xml"},
    {name="Dünya",url="http://www.ahaber.com.tr/rss/dunya.xml"},
    {name="Yaşam", url="http://www.ahaber.com.tr/rss/yasam.xml"},
    {name="Ana sayfa",url="http://www.ahaber.com.tr/rss/anasayfa.xml"},
    {name="Ekonomi",url="http://www.ahaber.com.tr/rss/ekonomi.xml"},
    {name="Spor",url="http://www.ahaber.com.tr/rss/spor.xml"},
    {name="Manşet",url="http://www.ahaber.com.tr/rss/haberler.xml"},
    {name="Özel Haber",url="http://www.ahaber.com.tr/rss/ozel-haberler.xml"},
    {name="Teknoloji",url="http://www.ahaber.com.tr/rss/teknoloji.xml"}
}
local httpHeader={}
httpHeader["Content-Type"]="application/x-www-from-urlencoded"
httpHeader["Accept-Language"]="tr-TR"
local params={}
params.headers=httpHeader
local function rollBack( event )
	-- body
	utility.x=-W
	event.target:removeEventListener("tap",rollBack)
	event.target:removeSelf()
	event.target=nil
	return true
end
local function setValues()
	-- body
	if utility~=nil then
		utility:toFront()
		if utility.x>=0 then
				transition.to(utility,{x=-W,time=200})
				if bg ~=nil then
					bg:removeSelf()
					bg=nil
				end
			end
		end
end
local function hideUtility(event)
	setValues()
end
local function swifeEffect( event )		
	local phase=event.phase
	if event.limitReached then
		if event.direction=="right" then
			if utility.x<0 then			
				transition.to(utility,{x=0,time=300})
			bg=display.newRect(10,10,W*2,H*2)
				bg.anchorX=0.5
				bg.anchorY=0.5
				bg.x=W/2
				bg.alpha=0.8
				bg.y=H/2
				bg:addEventListener("tap",rollBack)
				bg:toFront()					
				utility:toFront()
				timer.performWithDelay(3000,hideUtility)
				
			end

		end
	end
	
	return true

end


local function fadeHomeMenu(e)
	-- body
	if hWidget then
		hWidget:removeSelf()
		rssScrollView:removeSelf()
		utilityScrollView:removeSelf()
		
		if #utilityBtns>0  and utilityBtns~=nil then
			for i=1,#utilityBtns do
			if utilityBtns[i]~=nil then
				utilityBtns[i]:removeSelf()
				table.remove(utilityBtns[i])				
				utilityBtns[i]=nil				
			end			
				
			end			
		end	
		if utility~=nil and utility.numChildren>0 then	
			for k=1,utility.numChildren do			
				utility[k]:removeSelf()
			end	
		end
		--print(utility.numChildren)	
		utilityScrollView=nil
		utility:removeSelf()
		utility=nil
		rssScrollView=nil 		
		hWidget=nil
		buildGUI()
	end
	
end
local function goBack(event)
	
	if hWidget~=nil and rssScrollView~=nil then
		transition.to(hWidget,{alpha=0,time=600,onComplete=fadeHomeMenu})
		transition.to(rssScrollView,{alpha=0,time=400})
		transition.to(utility,{alpha=0,time=200})
	end	
	

end
local function onToggle(event)
	if event.target.category==selected then 
		setValues()
		return true 

	end
	if #utilityBtns>0 then
		for i=1,#utilityBtns do
			if utilityBtns[i] ~=nil and utilityBtns[i].url~="" then
				utilityBtns[i]:setOff()
			end

		end
	end
	local url=event.target.url
	local category=event.target.category
	selected=category
	event.target:toggle()
	local headerTexts=hWidget[3]
	headerTexts.text=habers[id].name.."-"..selected		
	network.request(url,"GET",getDataFromWeb,params)
	return true
end
function getDataFromWeb(event)	
	if event.isError then
		print("Network Error"..event.response)
	else	
		local myFeed=xml:ParseXmlText(event.response)		
		local items = myFeed.child[1].child
		w=display.contentWidth
		if rssScrollView~=nil then
			rssScrollView:removeSelf()
			rssScrollView=nil
		end
		rssScrollView=widget.newScrollView({scrollHeight=800,width=320,listener=swifeEffect})
		rssScrollView.anchorX=0
		rssScrollView.anchorY=0
		rssScrollView.y=hWidget.height+10
		rssScrollView.x=0
		local gaps=0
		local title,link,description,pubDate
		for i=1,#items do
			local item=items[i]			
			--if item.name=="title" then print(item.value) end
			--if item.name=="link" then print(item.value) end					
			if item.name=="item" then
				local newsData={}				
				for j=1, #item.child do					
					if item.child[j].name=="title" then
						title=item.child[j].value						 
					 end					
					if item.child[j].name=="link" then link=item.child[j].value end
					if item.child[j].name=="description" then description=cleanHtml(item.child[j].value) end
					if item.child[j].name=="pubDate" then pubDate=item.child[j].value end					
					if title ~=nil and description~=nil and link~=nil and pubDate~=nil then
						local openNews=function(event)
							--print(event.target.link)
							--local webView=native.newWebView(display.contentCenterX,display.contentCenterY,320,480)
							--webView.request(event.target.link)							
							native.showWebPopup(5,5,W,H,event.target.link)
							--system.openURL(event.target.link)
							return true

						end					
						local titleX=0
						local titleY=50					
						local rss=display.newGroup()					
						local titleText=display.newText(title,titleX,titleX,native.systemFontBold,14)
						titleText:setFillColor(0,0,0)
						titleText.anchorX=0
						titleText.anchorY=0
						titleText.y=0
						local tOpt={text=description,x=titleX,y=titleY,align="left",font=native.systemFont,width=320,height=300,fontSize=12}
						local descText=display.newText(tOpt)						
						descText.anchorX=0
						descText.anchorY=0
						descText.y=titleText.y+titleText.height/2+10					
						descText:setFillColor(0,0,0)
						local pubText=display.newText({text=pubDate,x=titleX,y=titleX,font=native.systemFont,
							fontSize=10,align="right",width=320,height=30})
						pubText:setFillColor(0,1,0)
						pubText.anchorX=0;pubText.anchorY=0
						pubText.y=descText.y+descText.height/2-pubText.height/2-50
						pubText.link=link
						descText.link=link						
						titleText:addEventListener("tap",openNews)
						descText:addEventListener("tap",openNews)						
						rss:insert(titleText)
						rss:insert(descText)
						rss:insert(pubText)					
						rss.y=rssScrollView.y+titleY*gaps*3
						rssScrollView:insert(rss)
						gaps =gaps+1
						link=nil
						title=nil
						description=nil
						thumb=nil
						pubDate=nil
						rss=nil
						
					end 
					
				end
			end			
			setValues()
		end

	end
end
local function buildIndexPage()
	selected=nil
	local gaps=0
	if utilityScrollView~=nil then
		utilityScrollView:removeSelf()
	end	

	utilityScrollView=widget.newScrollView({scrollHeight=500,width=128})
	local backBtn=widget.newButton({defaultFile="back_btn.png",overFile="back_btn_dwn.png",
						width=50,labelAlign="left"})	
	backBtn:addEventListener("tap",goBack)				
	hWidget:insert(backBtn)
	local setBtn=widget.newButton({defaultFile="set_btn.png",overFile="set_btn_dwn.png",width=50,labelAlign="left"})
	setBtn:addEventListener("tap",loadSettings)
	hWidget:insert(setBtn)
	setBtn.x=display.contentWidth-setBtn.width
	for d in ipairs(categories) do
		if categories[d].id==id then
			local url=categories[d].urls
			local category=categories[d].category
			if selected==nil then
				selected=category
				local headerText=display.newText({text=habers[id].name.."-"..selected})
				headerText.y=backBtn.height/2
				headerText.x=backBtn.x+headerText.width-backBtn.width/2
				hWidget:insert(headerText)
				network.request(url,"GET",getDataFromWeb,params)
			end	

			local tgl=toggle.newToggle(category)
			if selected==category then
				tgl:setOn()		
			end	
			if tgl~=nil then		
				table.insert(utilityBtns,tgl)
			end
			tgl.url=url	
			tgl.category=category	
			tgl:addEventListener("tap",onToggle)
			tgl.x=0
			tgl.y=(gaps+1)*tgl.height
			gaps=gaps+1
			utilityScrollView:insert(tgl)
			tgl=nil	


		end

	end
	utility.y=hWidget.height
	utility:insert(utilityScrollView)
	

end

local function hideHomePage(event)
	group:removeSelf()
	print(#utilityBtns)
	utility=display.newGroup()
	utility.x=-display.contentWidth
	mWidget=display.newGroup()
	hWidget=display.newGroup()
	hWidget.height=50
	hWidget.anchorX=0
	hWidget.anchorY=0
	hWidget.x=10
	hWidget.y=0
	if categories~=nil then
		buildIndexPage()
		return
	end
	categories={}
	local sql="select to_id,category,urls from rss order by id asc"
	for d in db:nrows(sql) do
		local ids=d.to_id
		local category=d.category
		local urls=d.urls
		local nCat={id=ids,category=category,urls=urls}
		table.insert(categories,nCat)
	end
	buildIndexPage()

end
function onTap(event)
	id=event.target.id
	transition.to(group,{alpha=0,time=600,transition=easing.outQuart,onComplete=hideHomePage})
end
buildGUI=function()
	group = widget.newScrollView(
    {
        top = 10,
        left = 10,
        width = 300,
        height = 400,
        scrollWidth = 600,
        scrollHeight = 800
    }) 
    local j=0
    for d in ipairs(habers) do    	
    	local btn=widget.newButton({defaultFile="btn_bg.png",overFile="btn_bg_down.png",id=habers[d].id,width=300,height=50,label=habers[d].name,labelAlign="left"})
		--btn.x=0--display.contentCenterX
		btn.y=btn.height*(j+1)
		j=j+1
		btn:addEventListener("tap",onTap)
		group:insert(btn)
	end		



end
local loadNews=function()
	local sql="select id,name from news order by id"
	if habers ~=nil then
		buildGUI()
		return
	end
	habers={}
	for d in db:nrows(sql) do
		local name=d.name
		local id=d.id
		local nTable={id=id,name=name}		
		table.insert(habers,nTable)		
	end	
	buildGUI()

	
end
local createDB=function()
	if db==nil then
		db=sqlite3.open(path)
	end
	db:exec( newsTable )
	db:exec(rssTable)	
	local sql="select count(id) as count from rss"	
	local entered=false	
	for k in db:nrows(sql) do
		if k.count>0 then			
			entered=true
		end		
	end
	if entered then		
		loadNews()
		return
	end
	for d in ipairs(news) do
		local sql="insert into news(name) values('"..news[d].."');"
		db:exec(sql)
	end
	for d in ipairs(ht) do
		local sql="insert into rss(to_id,category,urls) values('"..ht.id.."','"..ht[d].name.."','"..ht[d].url.."');"
		db:exec(sql)
	end
	for d in ipairs(sbh) do
		local sql="insert into rss(to_id,category,urls) values('"..sbh.id.."','"..sbh[d].name.."','"..sbh[d].url.."');"
		db:exec(sql)
	end
	for d in ipairs(ahbr) do
		local sql="insert into rss(to_id,category,urls) values('"..ahbr.id.."','"..ahbr[d].name.."','"..ahbr[d].url.."');"
		db:exec(sql)
	end
	for d in ipairs(bbc) do
		local sql="insert into rss(to_id,category,urls) values('"..bbc.id.."','"..bbc[d].name.."','"..bbc[d].url.."');"
		db:exec(sql)
	end
	for d in ipairs(cumh) do
		local sql="insert into rss(to_id,category,urls) values('"..cumh.id.."','"..cumh[d].name.."','"..cumh[d].url.."');"
		db:exec(sql)
	end

end
createDB()
function onSystemEvent(event)
	if ( event.type == "applicationExit" ) then              
        db:close()
    end
end
local function onKeyEvent(event)
	-- body

	local keyName=event.keyName
	local phase=event.phase
	if "back"==keyName and "up"==phase then
		native.cancelWebPopup()
		return true
	end
	return false

end

Runtime:addEventListener("key",onKeyEvent)
Runtime:addEventListener( "system", onSystemEvent )
