
local LeftScene = class("LeftScene", function ()
    return display.newScene("LeftScene")
end)
local ContentTableView = require("app.component.ContentTableView")
local listenner

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
    self._unlockLabel = {}
    self._unlockButton = {}

    self:initBaseLayer()
    self._schedule = scheduler.scheduleGlobal(handler(self, self.onInterval),1)

	--从其他场景返回的时候,检查是否有开启新的标签
    self:checkFunctionUnlock()
    if app._showleftPageName == "" then
        app._showleftPageName = "build"
    end
    self:leftShow(app._showleftPageName)
    
end

function LeftScene:initBaseLayer()
    self.menuLayer = cc.LayerColor:create(cc.c4b(0,0,0,100),display.width,display.height):pos(0, 0):addTo(self.backLayer,3):hide()
    self:initBuildLayer()
    self:initPeopleLayer()
    self:initTechLayer()
    for i,v in ipairs(sysDataTable["scene_two"]["layerButtons"]) do
        local data = sysDataTable.definitions[v]
        if GameData["data"][data["unlockKey"]] then
            self.leftPageTag:addButtonContent(data["buttonImg"], data["buttonText"])
                :onButtonClicked(function (event)
                    self:leftShow(data["layerKey"])
                end)
        end
    end

    for i,v in ipairs(sysDataTable["scene_two"]["layers"]) do
        local data = sysDataTable.definitions[v]
        if data["key"] == "build" then 
            for i,cv in ipairs(data["firstContent"]) do
                if not self:existUnlockLabel(cv) then
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then 
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.buildPage1:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    else
                        showLabel = newRefreshLabel(contentData,false)
                        self.buildPage1:addStringContent(showLabel)
                        self:registInterval(cv,showLabel)
                        self:registUnlockLabel(cv)
                    end
                end
                
            end

            for i,cv in ipairs(data["secondContent"]) do
                if not self:existUnlockLabel(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then 
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.buildPage2:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    else
                        showLabel = newRefreshLabel(contentData,false)
                        self.buildPage2:addStringContent(showLabel)
                        self:registInterval(cv,showLabel)
                        self:registUnlockLabel(cv)
                    end
                end
            end

            local clickButton
            local itemShowLabel
            local item
            for i,cv in ipairs(data["thirdContent"]) do
                if not self:existUnlockButton(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    local isShow = true
                    if contentData["unlockTechId"] ~= 0 then 
                        if not GameData["data"]["unlockTeches"][contentData["unlockTechId"]] then
                            isShow = false
                        end
                    end

                    if isShow then 
                        clickButton = newClickButton(contentData)
                            :onButtonClicked(function (event)
                                local menuData = {}
                                menuData.title = contentData["buttonText"]
                                menuData.items = {}
                                for j,amount in ipairs(contentData["clickEffect"]) do
                                    table.insert(menuData.items,self:getBuildingMenuData(contentData["buildId"],amount))
                                end
                                self:updateMenu(menuData,self.batchProduce,false)
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
                        self:registUnlockButton(cv)
                    end
                end
            end
            self.buildPage3:reload()
        end

        if data["key"] == "people" then 
            for i,cv in ipairs(data["firstContent"]) do
                if not self:existUnlockLabel(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then 
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.peoplePage1:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    else
                        showLabel = newRefreshLabel(contentData,false)
                        self.peoplePage1:addStringContent(showLabel)
                        self:registInterval(cv,showLabel)
                        self:registUnlockLabel(cv)
                    end
                end
            end

            for i,cv in ipairs(data["secondContent"]) do
                if not self:existUnlockLabel(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then 
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.peoplePage2:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    else
                        showLabel = newRefreshLabel(contentData,false)
                        self.peoplePage2:addStringContent(showLabel)
                        self:registInterval(cv,showLabel)
                        self:registUnlockLabel(cv)
                    end
                end
            end

            for i,cv in ipairs(data["thirdContent"]) do
                if not self:existUnlockButton(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    local isShow = true
                    if contentData["unlockTechId"] ~= 0 then 
                        if not GameData["data"]["unlockTeches"][contentData["unlockTechId"]] then
                            isShow = false
                        end
                    end

                    if isShow then 
                        item = self.peoplePage3:newItem()
                        item:setItemSize(240, 40)
                        local content = self:newPeopleOptItem(contentData)
                        item:addContent(content)
                        self.peoplePage3:addItem(item)
                        self:registUnlockButton(cv)
                    end
                end
            end
            self.peoplePage3:reload()
        end

        if data["key"] == "tech" then 
            for i,cv in ipairs(data["thirdContent"]) do
                if not self:existUnlockButton(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    local isShow = true
                    for i,v in ipairs(contentData["unlockNeedTeches"]) do
                        if not GameData["data"]["unlockTeches"][v] then
                            isShow = false
                            break
                        end
                    end

                    if isShow then 
                        item = self.techPage:newItem()
                        item:setItemSize(240, 40)
                        local content = cc.ui.UIPushButton.new(contentData["buttonImg"], {scale9 = true})
                            :setButtonSize(contentData["buttonW"], contentData["buttonH"])
                            :setButtonLabel("normal", cc.ui.UILabel.new({text=contentData["buttonText"],color=display.COLOR_BLACK,size=contentData["buttonTextSize"]}))
                            :onButtonClicked(function(event)
                                    -- TODO
                                end)
                        item:addContent(content)
                        self.techPage:addItem(item)
                        self:registUnlockButton(cv)
                    end
                end
            end
            self.techPage:reload()
        end

    end
    refreshLabel(self._intervalTags)
end

function LeftScene:newPeopleOptItem(data)
    local content = display.newNode()
    local leftButton = cc.ui.UIPushButton.new(data["buttonImg"], {scale9 = true})
                :setButtonSize(data["buttonW"], data["buttonH"])
                :setButtonLabel("normal", cc.ui.UILabel.new({text=data["leftButtonText"],color=display.COLOR_BLACK,size=data["buttonTextSize"]}))
                :onButtonClicked(function(event)
                        local menuData = {}
                        menuData.title = data["leftMenuTitle"]
                        menuData.items = {}
                        for j,amount in ipairs(data["leftClickEffect"]) do
                            table.insert(menuData.items,self:getPeopleMenuData(data["workerId"],amount))
                        end
                        self:updateMenu(menuData,self.batchProduce,true)
                    end)
                :align(display.CENTER, data["leftPositionX"], data["leftPositionY"])
                :addTo(content)
    local rightButton = cc.ui.UIPushButton.new(data["buttonImg"], {scale9 = true})
                :setButtonSize(data["buttonW"], data["buttonH"])
                :setButtonLabel("normal", cc.ui.UILabel.new({text=data["rightButtonText"],color=display.COLOR_BLACK,size=data["buttonTextSize"]}))
                :onButtonClicked(function(event)
                        local menuData = {}
                        menuData.title = data["rightMenuTitle"]
                        menuData.items = {}
                        for j,amount in ipairs(data["rightClickEffect"]) do
                            table.insert(menuData.items,self:getPeopleMenuData(data["workerId"],amount))
                        end
                        self:updateMenu(menuData,self.batchProduce,true)
                    end)
                :align(display.CENTER, data["rightPositionX"], data["rightPositionY"])
                :addTo(content)
    local label = cc.ui.UILabel.new({text = data["LabelText"], size = data["LabelTextSize"], color = display.COLOR_BLACK})
        :align(display.CENTER, (data["rightPositionX"] + data["leftPositionX"])/2 , (data["rightPositionY"] + data["leftPositionY"])/2)
        :addTo(content)
    self:registInterval(data["id"],label)
    return content
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

    self.peoplePage3 = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "barH.png",
        bgScale9 = true,
        viewRect = cc.rect(30, 0, 260, display.height - 240),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        -- scrollbarImgV = "bar.png"
        }
        :onTouch(handler(self, self.touchListener))
        :addTo(self.peopleLayer,2)
    self.peoplePage3:setAlignment(display.LEFT_TO_RIGHT)

    local contentData = sysDataTable.definitions[27000]
    if contentData["unlockKey"] and GameData["data"][contentData["unlockKey"]] then 
        local clickButton = newClickButton(contentData)
            :onButtonClicked(function (event)
                local menuData = {}
                menuData.title = contentData["buttonText"]
                menuData.items = {}
                for j,amount in ipairs(contentData["clickEffect"]) do
                    table.insert(menuData.items,self:getBuildingMenuData(contentData["workerId"],amount))
                end
                self:updateMenu(menuData,self.batchProduce,true)
            end)
            :addTo(self.peopleLayer,2)
        local itemShowLabel = newRefreshLabel(contentData,false)
            :align(display.CENTER_LEFT, contentData["positionX"] + contentData["buttonW"]/2 + 10 , contentData["positionY"])
            :addTo(self.peopleLayer,2)
        self:registInterval(27000,itemShowLabel)
        self:registUnlockButton(27000)
    end
end

function LeftScene:initTechLayer()
    self.techLayer = cc.LayerColor:create(cc.c4b(255,255,255,255),display.width,display.height - 40):pos(0, 0):addTo(self.backLayer,1)
    display.newLine(
                {{display.left, display.top - 41}, {display.right, display.top - 41}},
                {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
                :addTo(self.techLayer)
    self.techPage = cc.ui.UIListView.new {
        -- bgColor = cc.c4b(200, 200, 200, 120),
        -- bg = "barH.png",
        bgScale9 = true,
        viewRect = cc.rect(30, 0, 260, display.height - 100),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        -- scrollbarImgV = "bar.png"
        }
        :onTouch(handler(self, self.touchListener))
        :addTo(self.techLayer,2)
    -- self.techPage:setAlignment(display.LEFT_TO_RIGHT)
end

function LeftScene:leftShow(tableName)
    self.buildLayer:hide()
    self.peopleLayer:hide()
    self.techLayer:hide()
    -- self.dealLayer:hide()
    -- self.godLayer:hide()

    if tableName == "build" then self.buildLayer:show() end
    if tableName == "people" then self.peopleLayer:show() end
    if tableName == "tech" then self.techLayer:show() end
    -- if tableName == "deal" then self.dealLayer:show() end
    -- if tableName == "god" then self.godLayer:show() end
    app._showleftPageName = tableName
end

function LeftScene:checkFunctionUnlock()
	for i,v in ipairs(sysDataTable["scene_two"]["layerButtons"]) do
        if not self:existUnlockLabel(v) then
            local data = sysDataTable.definitions[v]
            if not GameData["data"][data["unlockKey"]] then
                local unlock = sysDataTable.definitions[data["unlockId"]]
                local is_unlock = true
                if not GameData["data"][data["unlockKey"]] then
                    for i,val in pairs(unlock["input"]) do
                        local need = sysDataTable.definitions[val["id"]]
                        if GameData["data"][need["key"]] < val["quantity"] then
                            is_unlock = false
                            break
                        end
                    end
                end
                
                if is_unlock then 
                    self.leftPageTag:addButtonContent(data["buttonImg"], data["buttonText"])
                        :onButtonClicked(function (event)
                            self:leftShow(data["layerKey"])
                        end)
                    self:registUnlockLabel(v)
                    GameData["data"][data["unlockKey"]] = true
                end
            end
        end
    end

    for i,v in ipairs(sysDataTable["scene_two"]["layers"]) do
		local data = sysDataTable.definitions[v]
		if data["key"] == "build" then 
			for i,cv in ipairs(data["firstContent"]) do
                if not self:existUnlockLabel(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then 
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.buildPage1:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    end
                end
			end

			for i,cv in ipairs(data["secondContent"]) do
                if not self:existUnlockLabel(cv) then
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.buildPage2:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    end
                end
			end

            local clickButton
            local itemShowLabel
            local item
            for i,cv in ipairs(data["thirdContent"]) do
                if not self:existUnlockButton(cv) then
                    local contentData = sysDataTable.definitions[cv]
                    local isShow = true
                    if contentData["unlockTechId"] ~= 0 then 
                        if not GameData["data"]["unlockTeches"][contentData["unlockTechId"]] then
                            isShow = false
                        end
                    end

                    if isShow then 
                        clickButton = newClickButton(contentData)
                            :onButtonClicked(function (event)
                                local menuData = {}
                                menuData.title = contentData["buttonText"]
                                menuData.items = {}
                                for j,amount in ipairs(contentData["clickEffect"]) do
                                    table.insert(menuData.items,self:getBuildingMenuData(contentData["buildId"],amount))
                                end
                                self:updateMenu(menuData,self.batchProduce,false)
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
                        self:registUnlockButton(cv)
                    end
                end
            end
            self.buildPage3:reload()
		end

        if data["key"] == "people" then 
            for i,cv in ipairs(data["firstContent"]) do
                if not self:existUnlockLabel(cv) then
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then 
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.peoplePage1:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    end
                end
            end

            for i,cv in ipairs(data["secondContent"]) do
                if not self:existUnlockLabel(cv) then
                    local contentData = sysDataTable.definitions[cv]
                    if contentData["unlockKey"] ~= "" then 
                        if GameData["data"][contentData["unlockKey"]] then
                            showLabel = newRefreshLabel(contentData,false)
                            self.peoplePage2:addStringContent(showLabel)
                            self:registInterval(cv,showLabel)
                            self:registUnlockLabel(cv)
                        end
                    end
                end
                
            end

            for i,cv in ipairs(data["thirdContent"]) do
                if not self:existUnlockButton(cv) then
                    local contentData = sysDataTable.definitions[cv]
                    local isShow = true
                    if contentData["unlockTechId"] ~= 0 then 
                        if not GameData["data"]["unlockTeches"][contentData["unlockTechId"]] then
                            isShow = false
                        end
                    end

                    if isShow then 
                        item = self.peoplePage3:newItem()
                        item:setItemSize(240, 40)
                        local content = self:newPeopleOptItem(contentData)
                        item:addContent(content)
                        self.peoplePage3:addItem(item)
                        self:registUnlockButton(cv)
                    end
                end
                
            end
            self.peoplePage3:reload()

            if not self:existUnlockButton(27000) then
                local contentData = sysDataTable.definitions[27000]
                if contentData["unlockKey"] and GameData["data"][contentData["unlockKey"]] then 
                    local clickButton = newClickButton(contentData)
                        :onButtonClicked(function (event)
                            local menuData = {}
                            menuData.title = contentData["buttonText"]
                            menuData.items = {}
                            for j,amount in ipairs(contentData["clickEffect"]) do
                                table.insert(menuData.items,self:getBuildingMenuData(contentData["workerId"],amount))
                            end
                            self:updateMenu(menuData,self.batchProduce,true)
                        end)
                        :addTo(self.peopleLayer,2)
                        local itemShowLabel = newRefreshLabel(contentData,false)
                        :align(display.CENTER_LEFT, contentData["positionX"] + contentData["buttonW"]/2 + 10 , contentData["positionY"])
                        :addTo(self.peopleLayer,2)
                        self:registInterval(27000,itemShowLabel)
                        self:registUnlockButton(27000)
                end
            end
        end

        if data["key"] == "tech" then 
            for i,cv in ipairs(data["thirdContent"]) do
                if not self:existUnlockButton(cv) then 
                    local contentData = sysDataTable.definitions[cv]
                    local isShow = true
                    for i,v in ipairs(contentData["unlockNeedTeches"]) do
                        if not GameData["data"]["unlockTeches"][v] then
                            isShow = false
                            break
                        end
                    end

                    if isShow then 
                        item = self.techPage:newItem()
                        item:setItemSize(240, 40)
                        local content = cc.ui.UIPushButton.new(contentData["buttonImg"], {scale9 = true})
                            :setButtonSize(contentData["buttonW"], contentData["buttonH"])
                            :setButtonLabel("normal", cc.ui.UILabel.new({text=contentData["buttonText"],color=display.COLOR_BLACK,size=contentData["buttonTextSize"]}))
                            :onButtonClicked(function(event)
                                    -- TODO
                                    
                                end)
                        item:addContent(content)
                        self.techPage:addItem(item)
                        self:registUnlockButton(cv)
                    end
                end
            end
            self.techPage:reload()
        end
    end
end

function LeftScene:getBuildingMenuData(id,amount)
    local buildingMenuItemData = {}
    local buildingData = sysDataTable.definitions[id]
    buildingMenuItemData.text = "+" .. amount .. buildingData["name"] .. " ( "
    buildingMenuItemData.input = copyTab(buildingData["input"])
    local output = {}
    output.id = id
    output.quantity = 1
    if id == constant.unemployeeId then 
        buildingMenuItemData.output = {}
        local extentOutput = {}
        extentOutput.id = constant.peopleId
        extentOutput.quantity = 1
        table.insert(buildingMenuItemData.output,extentOutput)
    else
        buildingMenuItemData.output = copyTab(buildingData["output"])
    end
    table.insert(buildingMenuItemData.output,output)
    
    for i,v in pairs(buildingMenuItemData.input) do
        local consumeData = sysDataTable.definitions[v.id]
        buildingMenuItemData.text = buildingMenuItemData.text .. "-".. v.quantity * amount .. consumeData["name"] .. " "
        buildingMenuItemData.input[i].quantity = v.quantity * amount
    end

    for i,v in pairs(buildingMenuItemData.output) do
        buildingMenuItemData.output[i].quantity = v.quantity * amount
    end
    buildingMenuItemData.text = buildingMenuItemData.text .. ")"
    return buildingMenuItemData
end

function LeftScene:getPeopleMenuData(id,amount)
    local peopleMenuItemData = {}
    local peopleData = sysDataTable.definitions[id]
    local consumeData = sysDataTable.definitions[constant.unemployeeId]
    local input = {}
    local output = {}
    local signOne
    local signTwo
    if amount < 0 then
        signOne = "-"
        signTwo = "+"
        amount = -amount
        input.id = id
        output.id = constant.unemployeeId
    else
        signOne = "+"
        signTwo = "-"
        input.id = constant.unemployeeId
        output.id = id
    end
    
    input.quantity = amount
    output.quantity = amount
    peopleMenuItemData.text = signOne .. amount .. peopleData["name"] .. " ( "
    peopleMenuItemData.text = peopleMenuItemData.text .. signTwo..amount .. consumeData["name"] .. " "
    peopleMenuItemData.input = {}
    peopleMenuItemData.output = {}
    table.insert(peopleMenuItemData.input,input)
    table.insert(peopleMenuItemData.output,output)
    peopleMenuItemData.text = peopleMenuItemData.text .. ")"
    return peopleMenuItemData
end

function LeftScene:updateMenu(menuData, callback,needCalSpeed)
    if not self._menu then
        self._menu = cc.ui.UIListView.new {
            viewRect = cc.rect(display.cx - 150, 10, 300, 240),
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
            :onScroll(function(event)
                    if "moved" == event.name then
                        game.bListViewMove = true
                    elseif "ended" == event.name then
                        game.bListViewMove = false
                    end
                end)
        self._menu:addTo(self.menuLayer)
    end
        self._menu:removeAllItems()
        local item    
        local content
        item = self._menu:newItem()
        content = cc.ui.UIPushButton.new("barH.png")
                :setButtonSize(300, 36)
                :setButtonLabel(cc.ui.UILabel.new({text = menuData.title, size = 16, color = display.COLOR_BLUE}))
        content:setTouchSwallowEnabled(false)
        item:addContent(content)
        item:setItemSize(300, 40)
        self._menu:addItem(item)
        for i, v in ipairs(menuData.items) do
            item = self._menu:newItem()
            content = cc.ui.UIPushButton.new("barH.png")
                :setButtonSize(300, 36)
                :setButtonLabel(cc.ui.UILabel.new({text = v.text, size = 16, color = display.COLOR_BLUE}))
                :onButtonClicked(function(event)
                    if game.bListViewMove then
                        return
                    end
                    callback(self,v.input,v.output,needCalSpeed)
                    self.menuLayer:hide()
                    self:enableLayerTouch(true)
                    self._menu:removeAllItems()
                end)
            content:setTouchSwallowEnabled(false)
            item:addContent(content)
            item:setItemSize(300, 40)
            self._menu:addItem(item)
        end
        item = self._menu:newItem()
        content = cc.ui.UIPushButton.new("barH.png")
            :setButtonSize(300, 36)
            :setButtonLabel(cc.ui.UILabel.new({text = "取消", size = 16, color = display.COLOR_BLUE}))
            :onButtonClicked(function(event)
                self.menuLayer:hide()
                self:enableLayerTouch(true)
                self._menu:removeAllItems()
            end)
        content:setTouchSwallowEnabled(false)
        item:addContent(content)
        item:setItemSize(300, 40)
        self._menu:addItem(item)
        self._menu:reload()
        self.menuLayer:show()
        self:enableLayerTouch(false)
end

function LeftScene:batchProduce(inputs,outputs,needCalSpeed)
    local errorStr
    if inputs then
        for i,v in ipairs(inputs) do 
            errorStr = addResource(v.id,-v.quantity,true,false)
            if errorStr ~= "" then 
                self:errorFadeOut(errorStr)
                return
            end
        end 
    end
    
    if outputs then
        for i,v in ipairs(outputs) do 
            errorStr = addResource(v.id,v.quantity,true,false)
            if errorStr ~= "" then 
                self:errorFadeOut(errorStr)
                return
            end
            
        end
    end

    if inputs then
        for i,v in ipairs(inputs) do 
            addResource(v.id,-v.quantity,false,true)
        end 
    end
    
    if outputs then
        for i,v in ipairs(outputs) do 
            addResource(v.id,v.quantity,false,true)
        end
    end

    self:checkFunctionUnlock()
    if needCalSpeed then
        calculateSpeed()
    end
    refreshLabel(self._intervalTags)
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

-- function LeftScene:addResourceAndRefresh(id,add)
--     local errorStr = addResource(id, add,false)
--     if errorStr ~= "" then 
--         self:errorFadeOut(errorStr)
--         return
--     end
-- end

function LeftScene:registInterval(id,label)
    local labelData = {}
    labelData.id = id
    labelData.label = label
    self._intervalTags[#self._intervalTags + 1] = labelData
end

function LeftScene:registUnlockLabel(id)
    self._unlockLabel[id] = id
end

function LeftScene:existUnlockLabel(id)
    return self._unlockLabel[id] 
end

function LeftScene:registUnlockButton(id)
    self._unlockButton[id] = id
end

function LeftScene:existUnlockButton(id)
    return self._unlockButton[id] 
end

function LeftScene:onInterval(dt)
    refreshLabel(self._intervalTags)
end

function LeftScene:onEnter()


end

function LeftScene:onExit()
	scheduler.unscheduleGlobal(self._schedule)
end

function LeftScene:errorFadeOut(errorText)
    local errorFadeLabel = cc.ui.UILabel.new({text = errorText, size = 16, color = display.COLOR_RED}):align(display.CENTER, display.cx, display.cy):addTo(self,9)
    errorFadeLabel:runAction(cc.FadeOut:create(1))
    errorFadeLabel:moveTo(1, display.cx, display.cy - 20)
    errorFadeLabel:performWithDelay(function()
        self:removeSelf()
    end, 1)
end

function LeftScene:enableLayerTouch(isOpen)
    local tableName = app._showleftPageName
    local opLayer 
    if tableName == "build" then opLayer=self.buildLayer end
    if tableName == "people" then opLayer=self.peopleLayer end
    -- print("tableName="..tableName)
    -- print("isOpen="..tostring(isOpen))
    opLayer:enableTouch(isOpen)
    -- opLayer:setTouchEnabled(isOpen)
end


return LeftScene