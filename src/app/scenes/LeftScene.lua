
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
		            	self:registInterval(cv,showLabel)
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
		            	self:registInterval(cv,showLabel)
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

    self.buildPage3 = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "barH.png",
        bgScale9 = true,
        viewRect = cc.rect(30, 0, 260, display.height - 180),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        -- scrollbarImgV = "bar.png"
        }
        :onTouch(handler(self, self.touchListener))
        :addTo(self.buildLayer,2)
    self.buildPage3:setAlignment(display.LEFT_TO_RIGHT)

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

            local clickButton
            local itemShowLabel
            local item
            for i,cv in ipairs(data["thirdContent"]) do
                local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockTechId"] ~= 0 then 
                        if GameData["data"]["unlockTeches"] and GameData["data"]["unlockTeches"][contentData["unlockTechId"]] then
                            clickButton = newClickButton(contentData)
                            :onButtonClicked(function (event)
                                -- self:addResourceAndRefresh(data["clickEffectKey"], data["clickAddDuration"])
                                -- refreshLabel(self._intervalTags)
                            end)

                            itemShowLabel = newRefreshLabel(contentData,true)
                            self:registInterval(cv,itemShowLabel)
                            item = self.buildPage3:newItem()
                            item:setItemSize(240, 40)
                            content = display.newNode()
                            clickButton:addTo(content)
                            itemShowLabel:addTo(content)
                            item:addContent(content)
                            self.buildPage3:addItem(item)
                        end
                    else
                        clickButton = newClickButton(contentData)
                            :onButtonClicked(function (event)
                                -- self:addResourceAndRefresh(data["clickEffectKey"], data["clickAddDuration"])
                                -- refreshLabel(self._intervalTags)
                            end)

                            itemShowLabel = newRefreshLabel(contentData,true)
                            self:registInterval(cv,itemShowLabel)
                            item = self.buildPage3:newItem()
                            item:setItemSize(240, 40)
                            content = display.newNode()
                            clickButton:addTo(content)
                            itemShowLabel:addTo(content)
                            item:addContent(content)
                            self.buildPage3:addItem(item)
                    end
            end
            self.buildPage3:reload()
		end
    end

    


    -- local item = self.buildPage3:newItem()
    -- item:setItemSize(240, 40)
    -- -- item:align(display.BOTTOM_LEFT, 0, 0)
    -- local content = display.newNode()
    -- local l = cc.ui.UILabel.new(
    --                 {text = "铁匠铺",
    --                 size = 12,
    --                 align = cc.ui.TEXT_ALIGN_LEFT,
    --                 color = display.COLOR_BLACK})
    -- l:addTo(content)
    -- l:pos(30, 0)
    -- -- l:align(display.BOTTOM_LEFT, 0, 0)

    -- local b = cc.ui.UIPushButton.new("barH.png",{bgScale9 = true})
    -- b:addTo(content)
    -- b:setButtonSize(40, 20)
    -- b:pos(120, 0)

    -- local b1 = cc.ui.UIPushButton.new("barH.png",{bgScale9 = true})
    -- b1:addTo(content)
    -- b1:setButtonSize(40, 20)
    -- b1:pos(170, 0)
    -- -- b:align(display.BOTTOM_LEFT, 120, 0)
    -- -- local content = cc.ui.UILabel.new(
    -- --                 {text = "铁匠铺",
    -- --                 size = 12,
    -- --                 align = cc.ui.TEXT_ALIGN_LEFT,
    -- --                 color = display.COLOR_BLACK})

    -- item:addContent(content)
    
    -- self.buildPage3:addItem(item)
    -- self.buildPage3:reload()



    -- self.buildPage3 = ContentTableView.new{width=100,height=220,row=11,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST}
    --         :pos(20, display.height - 385)
    --         :addTo(self.buildLayer,2)

    -- self.buildPage4 = ContentTableView.new{width=100,height=220,row=11,column=1,arrange=ContentTableView.ARRANGE_VERTICAL_FIRST,columnH=20,columnW=20}
    --         :pos(140, display.height - 385)
    --         :addTo(self.buildLayer,2)
end

function LeftScene:touchListener(event)
    local listView = event.listView
    if "clicked" == event.name then

    elseif "moved" == event.name then
        self.bListViewMove = true
    elseif "ended" == event.name then
        self.bListViewMove = false
    else
        print("event name:" .. event.name)
    end
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