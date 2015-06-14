
local LeftScene = class("LeftScene", function ()
    return display.newScene("LeftScene")
end)
local ContentTableView = require("app.component.ContentTableView")
local scheduler = require("framework.scheduler")

function LeftScene:ctor()
	self.backLayer = cc.LayerColor:create(cc.c4b(255,255,255,255),display.width,display.height):pos(0, 0):addTo(self,1)
	self.leftPageTag = ContentTableView.new{width=display.width - 80,height=40,row=1,column=5,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST}:pos(0, display.height - 40):addTo(self.backLayer)

	cc.ui.UIPushButton.new("Button01.png", {scale9 = true})
                    :setButtonSize(70, 35)
                    :setButtonLabel("normal", cc.ui.UILabel.new({text=">>>",color=display.COLOR_BLACK,size=12}))
                    :onButtonClicked(function(event)
                        app:enterScene("MainScene")
                    end)
                    :align(display.RIGHT_TOP, display.right, display.top)
                    :addTo(self.backLayer,1,1)

    self._intervalTags = {}

    self:initBaseLayer()
    self._schedule = scheduler.scheduleGlobal(handler(self, self.onInterval),1)

	--从其他场景返回的时候,检查是否有开启新的标签
    self:checkFunctionUnlock()


	









end

function LeftScene:checkFunctionUnlock()
	for i,v in ipairs(sysDataTable["scene_two"]["layerButtons"]) do
		print("layerButtons="..v)
        local data = sysDataTable.definitions[v]
        if not GameData["data"][data["unlockKey"]] then
        	print("unlockId="..data["unlockId"])
        	local unlock = sysDataTable.definitions[data["unlockId"]]
            local is_unlock = true
            for i,val in pairs(unlock["input"]) do
                local need = sysDataTable.definitions[val["id"]]
                if GameData["data"][need["key"]] < val["quantity"] then
                    is_unlock = false
                    break
                end
            end
            if is_unlock then 
                self.leftPageTag:addButtonContent(data["buttonImg"], data["buttonText"])
                :onButtonClicked(function (event)
                	print("layerKey="..data["layerKey"])
        			self:leftShow(data["layerKey"])
    			end)
            end
        end
    end

    for i,v in ipairs(sysDataTable["scene_two"]["layers"]) do
		local data = sysDataTable.definitions[v]
		if data["key"] == "build" then 
			for i,cv in ipairs(data["firstContent"]) do
				local contentData = sysDataTable.definitions[cv]
				while true do
					if contentData["unlockKey"] == "" then break end
					if not GameData["data"][contentData["unlockKey"]] then
						showLabel = newRefreshLabel(contentData,false)
		            	self.buildPage1:addStringContent(showLabel)
		            	self:registInterval(v,showLabel)
	            	end
					break
				end
			end
			for i,cv in ipairs(data["secondContent"]) do
				local contentData = sysDataTable.definitions[cv]
				while true do
					if contentData["unlockKey"] == "" then break end
					if not GameData["data"][contentData["unlockKey"]] then
						showLabel = newRefreshLabel(contentData,false)
		            	self.buildPage2:addStringContent(showLabel)
		            	self:registInterval(v,showLabel)
		            end
					break
				end
			end
		end
    end



end




function LeftScene:initBaseLayer()
	self:initBuildLayer()
	-- self:initPeopleLayer()
	refreshLabel(self._intervalTags)
end

function LeftScene:initBuildLayer()
	self.buildLayer = cc.LayerColor:create(cc.c4b(255,255,255,255),display.width,display.height - 40):pos(0, 0):addTo(self.backLayer,1)
    display.newLine(
                {{display.left, display.top - 41}, {display.right, display.height - 41}},
                {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
                :addTo(self.buildLayer)

    display.newLine(
                {{display.left, display.top - 161}, {display.right, display.height - 161}},
                {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
                :addTo(self.buildLayer)

    self.buildPage1 = ContentTableView.new{width=100,height=110,row=5,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,showline=true}
            :pos(5, display.height - 155)
            :addTo(self.buildLayer,2)

    self.buildPage2 = ContentTableView.new{width=200,height=110,row=6,column=2,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,showline=true}
            :pos(115, display.height - 155)
            :addTo(self.buildLayer,2)

    for i,v in ipairs(sysDataTable["scene_two"]["layers"]) do
		local data = sysDataTable.definitions[v]
		if data["key"] == "build" then 
			for i,cv in ipairs(data["firstContent"]) do
				local contentData = sysDataTable.definitions[cv]
					if contentData["unlockKey"] ~= "" then 
						if GameData["data"][contentData["unlockKey"]] then
							showLabel = newRefreshLabel(contentData,false)
				            self.buildPage1:addStringContent(showLabel)
				            self:registInterval(cv,showLabel)
						end
					else
						showLabel = newRefreshLabel(contentData,false)
			            self.buildPage1:addStringContent(showLabel)
			            self:registInterval(cv,showLabel)
		            end
			end

			for i,cv in ipairs(data["secondContent"]) do
				local contentData = sysDataTable.definitions[cv]
					if contentData["unlockKey"] ~= "" then 
						if GameData["data"][contentData["unlockKey"]] then
							showLabel = newRefreshLabel(contentData,false)
				            self.buildPage2:addStringContent(showLabel)
				            self:registInterval(cv,showLabel)
						end
					else
						showLabel = newRefreshLabel(contentData,false)
		            	self.buildPage2:addStringContent(showLabel)
		           	 	self:registInterval(cv,showLabel)
					end
			end
		end
    end

    self.buildPage3 = ContentTableView.new{width=100,height=220,row=11,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST}
            :pos(20, display.height - 385)
            :addTo(self.buildLayer,2)

    self.buildPage4 = ContentTableView.new{width=100,height=220,row=11,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,columnH=20,columnW=20}
            :pos(140, display.height - 385)
            :addTo(self.buildLayer,2)
end

function LeftScene:initPeopleLayer()
	self.peopleLayer = cc.LayerColor:create(cc.c4b(255,255,255,255),display.width,display.height - 40):pos(0, 0):addTo(self.backLayer,1)
    display.newLine(
                {{display.left, display.top - 41}, {display.right, display.top - 41}},
                {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
                :addTo(self.peopleLayer)
    display.newLine(
                {{display.left, display.top - 161}, {display.right, display.height - 161}},
                {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
                :addTo(self.peopleLayer)
    self.peoplePage1 = ContentTableView.new{width=100,height=110,row=6,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,showline=true}
            :pos(5, display.height - 155)
            :addTo(self.peopleLayer,2)

    self.peoplePage2 = ContentTableView.new{width=200,height=110,row=6,column=2,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,showline=true}
            :pos(110, display.height - 155)
            :addTo(self.peopleLayer,2)

    self.peopleManage1 = ContentTableView.new{width=100,height=180,row=9,column=2,arrange=ContentTableView.ARRANGE_HORIZONTAL_FIRST,showline=false,columnH=20,columnW=20}
            :pos(display.right - 100, display.height - 390)
            :addTo(self.peopleLayer,2)

    self.peopleManage3 = ContentTableView.new{width=100,height=30,row=1,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,showline=false}
            :pos(20, display.height - 200)
            :addTo(self.peopleLayer,2)

    self.peopleManage2 = ContentTableView.new{width=100,height=180,row=9,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,showline=false}
            :pos(20, display.height - 390)
            :addTo(self.peopleLayer,2)
	
end

function LeftScene:leftShow(tableName)
    self.buildLayer:hide()
    self.peopleLayer:hide()
    -- self.techLayer:hide()
    -- self.dealLayer:hide()
    -- self.godLayer:hide()

    if tableName == "build" then self.buildLayer:show() end
    if tableName == "people" then self.peopleLayer:show() end
    -- if tableName == "tech" then self.techLayer:show() end
    -- if tableName == "deal" then self.dealLayer:show() end
    -- if tableName == "god" then self.godLayer:show() end
end

function LeftScene:addResourceAndRefresh(id,add)
    addResource(id, add)
end

function LeftScene:registInterval(id,label)
    local labelData = {}
    labelData.id = id
    labelData.label = label
    self._intervalTags[#self._intervalTags + 1] = labelData
end

function LeftScene:onInterval(dt)
    refreshLabel(self._intervalTags)
end

function LeftScene:onEnter()


end

function LeftScene:onExit()
	scheduler.unscheduleGlobal(self._schedule)
end



return LeftScene