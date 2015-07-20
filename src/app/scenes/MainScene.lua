import(".myworld")
local datautils = require("app.component.datautils")
local ContentListView = require("app.component.ContentListView")
local ContentTableView = require("app.component.ContentTableView")
local MainScene = class("MainScene", function ()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    self.layer = cc.LayerColor:create(cc.c4b(0,0,0,255),display.width,display.height):pos(0, 0):addTo(self,1)
    self.titleLabel = cc.ui.UILabel.new({text = "史前一百五十万年", size = 12, color = display.COLOR_WHITE})
                :addTo(self.layer)
    self._intervalTags = {}
    self._unlockLabel = {}
    if not GameData["data"]["is_init"] then 
            self.titleLabel:align(display.CENTER, display.cx, display.cy + 80)
            cc.ui.UIPushButton.new("Button01.png", {scale9 = true})
                :setButtonSize(70, 35)
                :setButtonLabel("normal", cc.ui.UILabel.new({text="点燃火炬",color=display.COLOR_BLACK,size=12}))
                :onButtonClicked(function(event)
                    local button = event.target
                    button:hide()
                    self.titleLabel:moveTo(2, display.cx, display.top - 20)
                    self:performWithDelay(function()
                        self:initBaseLayer()
                    end, 2.2)

                    -- 初始化正式场景
                    self:performWithDelay(function()
                        self:initBaseLayer(true)
                        button:removeSelf()
                        end,2.3)
                    end)
                :align(display.CENTER, display.cx, display.cy)
                :addTo(self.layer,1,1)
    else
        self:initBaseLayer(false)
        self._schedule = scheduler.scheduleGlobal(handler(self, self.onInterval),1)
    end
end

function MainScene:initBaseLayer(isInit)
    self.layer:setColor(display.COLOR_WHITE)
    self.titleLabel:setColor(display.COLOR_BLACK)
    self.titleLabel:align(display.CENTER, display.cx, display.top - 20)
    self.topLine = display.newLine(
        {{display.left, display.top - 40}, {display.right, display.top - 40}},
        {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
        :addTo(self.layer)

    self.listView = ContentListView.new{
        bgScale9 = true,
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(10, 10, 300, 100)}   
        :addTo(self.layer)

    self.resourcesView = ContentTableView.new{
        width=220,
        height=90,
        row=3,
        column=2,
        arrange=ContentTableView.ARRANGE_VERTICAL_FIRST}
        :pos(40, 205)
        :addTo(self.layer)

    if isInit then 
        self.listView:setAlignment(cc.ui.UIListView.ALIGNMENT_LEFT)
        self:performWithDelay(function()
             GameData["data"]["is_init"] = true
             self:checkFunctionUnlock()
             GameState.save(GameData)
        end,3)
        self.listView:addDelayItemWithContent("光明...",1)
        self.listView:addDelayItemWithContent("但是饥饿...",2)
        self.listView:addDelayItemWithContent("你开始寻找可以充饥的东西...",3)
    else
        --添加点击按钮
        local clickButton
        local showLabel
        
        for i,v in ipairs(sysDataTable["scene_one"]["clickButtons"]) do
            local data = sysDataTable.definitions[v]
            if GameData["data"][data["unlockKey"]] then
                clickButton = newClickButton(data)
                :onButtonClicked(function (event)
                    self:addResourceAndRefresh(data["clickEffectKey"], data["clickAddDuration"])
                    refreshLabel(self._intervalTags)
                end)
                :addTo(self.layer,1,1)
                showLabel = newRefreshLabel(sysDataTable.definitions[v],true)
                :addTo(self.layer,1,1)
                self:registInterval(v,showLabel)
            end
        end

        --资源标签
        for i,v in ipairs(sysDataTable["scene_one"]["resourceLabels"]) do
            local contentData = sysDataTable.definitions[v]
            if contentData["unlockKey"] ~= "" then 
                if GameData["data"][contentData["unlockKey"]] then
                    showLabel = newRefreshLabel(contentData,false)
                    self.resourcesView:addStringContent(showLabel)
                    self:registUnlockLabel(v)
                    self:registInterval(v,showLabel)
                elseif contentData["unlockId"] ~= 0 then
                    local unlock = sysDataTable.definitions[contentData["unlockId"]]
                    local is_unlock = true
                    for i,val in pairs(unlock["input"]) do
                        local need = sysDataTable.definitions[val["id"]]
                        if GameData["data"][need["key"]] < val["quantity"] then
                            is_unlock = false
                            break
                        end
                    end
                    
                    if is_unlock then 
                        showLabel = newRefreshLabel(contentData,false)
                        self.resourcesView:addStringContent(showLabel)
                        self:registUnlockLabel(v)
                        self:registInterval(v,showLabel)
                        GameData["data"][contentData["unlockKey"]] = true
                    end
                end
            
            elseif contentData["unlockTechId"] ~= 0 then
                if existUnlockTech(contentData["unlockTechId"]) then
                    showLabel = newRefreshLabel(contentData,false)
                    self.resourcesView:addStringContent(showLabel)
                    self:registUnlockLabel(v)
                    self:registInterval(v,showLabel)
                    if contentData["unlockKey"] ~= "" then 
                        GameData["data"][contentData["unlockKey"]] = true
                    end
                end
            else
                showLabel = newRefreshLabel(contentData,false)
                self.resourcesView:addStringContent(showLabel)
                self:registUnlockLabel(v)
                self:registInterval(v,showLabel)
                
            end
        end

        --从其他场景返回的时候,检查是否有开启新的标签
        self:checkFunctionUnlock()

        if GameData["data"]["is_left_unlock"] then
            cc.ui.UIPushButton.new("Button01.png", {scale9 = true})
                    :setButtonSize(70, 35)
                    :setButtonLabel("normal", cc.ui.UILabel.new({text="<<<",color=display.COLOR_BLACK,size=12}))
                    :onButtonClicked(function(event)
                        app:enterScene("LeftScene")
                    end)
                    :align(display.LEFT_TOP, 0, display.top)
                    :addTo(self.layer,1,1)
        end
        refreshLabel(self._intervalTags)
    end
    if DEBUG > 1 then
            cc.ui.UIPushButton.new("Button01.png", {scale9 = true})
                :setButtonSize(70, 35)
                :setButtonLabel("normal", cc.ui.UILabel.new({text="保存",color=display.COLOR_BLACK,size=12}))
                :onButtonClicked(function(event)
                    GameState.save(GameData)
                    end)
                :align(display.RIGHT_TOP, display.right, display.top)
                :addTo(self.layer,1,1)
        end
    
end

function MainScene:onEnter()
    -- self._intervalTags = {}
    -- if GameData["data"]["is_init"] then
    --     self:initBaseLayer(false)
    -- end
    -- self._schedule = scheduler.scheduleGlobal(handler(self, self.onInterval),1)
end

function MainScene:onExit()
    scheduler.unscheduleGlobal(self._schedule)
end

function MainScene:registInterval(id,label)
    local labelData = {}
    labelData.id = id
    labelData.label = label
    self._intervalTags[#self._intervalTags + 1] = labelData
end

function MainScene:onInterval(dt)
    --先计算每个资源的产出效率
    -- world.foodSpeed = world.farmer * world.economy.farmer.produce.food - world.people * world.economy.people.consume.food
    -- self:addFood(world.foodSpeed)
    -- self:refreshResourceLabel("foodSpeed", world)
    -- world.woodSpeed = world.woodWorker * world.economy.woodWorker.produce.wood
    -- self:addWood(world.woodSpeed)
    -- self:refreshResourceLabel("woodSpeed", world)
    -- world.stoneSpeed = world.stoneWorker * world.economy.stoneWorker.produce.stone
    -- self:addStone(world.stoneSpeed)
    -- self:refreshResourceLabel("stoneSpeed", world)
    -- world.leatherSpeed = world.leatherWorker * world.economy.leatherWorker.produce.leather
    -- self:addLeather(world.leatherSpeed)
    -- self:refreshResourceLabel("leatherSpeed", world)
    -- world.furSpeed = -world.leatherWorker * world.economy.leatherWorker.consume.fur
    -- world.metalSpeed = world.blacksmith * world.economy.blacksmith.produce.metal
    -- self:addMetal(world.metalSpeed)
    -- self:refreshResourceLabel("metalSpeed", world)
    -- world.oreSpeed = -world.blacksmith * world.economy.blacksmith.consume.ore
    -- world.faithSpeed = world.people * world.economy.people.produce.faith * world.minister
    -- self:addFaith(world.faithSpeed)
    -- self:refreshResourceLabel("faithSpeed", world)
    refreshLabel(self._intervalTags)
end

function MainScene:addResourceAndRefresh(id,add)
    addResource(id, add,false,true)
    self:checkFunctionUnlock()
end

function MainScene:checkFunctionUnlock()
        for i,v in ipairs(sysDataTable["scene_one"]["clickButtons"]) do
            local data = sysDataTable.definitions[v]
            if not GameData["data"][data["unlockKey"]] then
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
                    clickButton = newClickButton(data)
                    :onButtonClicked(function (event)
                        self:addResourceAndRefresh(data["clickEffectKey"], data["clickAddDuration"],false,true)
                        refreshLabel(self._intervalTags)
                    end)
                    :addTo(self.layer,1,1)
                    showLabel = newRefreshLabel(sysDataTable.definitions[v],true)
                    :addTo(self.layer,1,1)
                    self:registInterval(v,showLabel)
                    self.listView:addItemWithContent(unlock["text"])
                    GameData["data"][data["unlockKey"]] = true
                end
            end
        end

        --资源标签
        for i,cv in ipairs(sysDataTable["scene_one"]["resourceLabels"]) do
            if not self:existUnlockLabel(cv) then
                local contentData = sysDataTable.definitions[cv]
                if contentData["unlockKey"] ~= "" then
                    if GameData["data"][contentData["unlockKey"]] then
                        showLabel = newRefreshLabel(contentData,false)
                        self.resourcesView:addStringContent(showLabel)
                        self:registUnlockLabel(cv)
                        self:registInterval(cv,showLabel)
                    elseif contentData["unlockId"] ~= 0 then
                        local unlock = sysDataTable.definitions[contentData["unlockId"]]
                        local is_unlock = true
                        for i,val in pairs(unlock["input"]) do
                            local need = sysDataTable.definitions[val["id"]]
                            if GameData["data"][need["key"]] < val["quantity"] then
                                is_unlock = false
                                break
                            end
                        end
                        
                        if is_unlock then 
                            showLabel = newRefreshLabel(contentData,false)
                            self.resourcesView:addStringContent(showLabel)
                            self:registUnlockLabel(cv)
                            self:registInterval(cv,showLabel)
                            GameData["data"][contentData["unlockKey"]] = true
                        end
                    end
                elseif contentData["unlockTechId"] ~= 0 then
                    if existUnlockTech(contentData["unlockTechId"]) then
                        showLabel = newRefreshLabel(contentData,false)
                        self.resourcesView:addStringContent(showLabel)
                        self:registUnlockLabel(cv)
                        self:registInterval(cv,showLabel)
                        if contentData["unlockKey"] ~= "" then 
                            GameData["data"][contentData["unlockKey"]] = true
                        end
                    end
                end
            end
        end

        
        if not GameData["data"]["is_left_unlock"] then
            local is_unlock = true
            local unlock = sysDataTable.definitions[19980]
                for i,val in pairs(unlock["input"]) do
                    local need = sysDataTable.definitions[val["id"]]
                    if GameData["data"][need["key"]] < val["quantity"] then
                        is_unlock = false
                        break
                    end
                end
            if is_unlock then 
                cc.ui.UIPushButton.new("Button01.png", {scale9 = true})
                    :setButtonSize(70, 35)
                    :setButtonLabel("normal", cc.ui.UILabel.new({text="<<<",color=display.COLOR_BLACK,size=12}))
                    :onButtonClicked(function(event)
                        app:enterScene("LeftScene")
                    end)
                    :align(display.LEFT_TOP, 0, display.top)
                    :addTo(self.layer,1,1)
                    self.listView:addItemWithContent(unlock["text"])
                    GameData["data"]["is_left_unlock"] = true
            end
        end
        refreshLabel(self._intervalTags)
end

function MainScene:registUnlockLabel(id)
    self._unlockLabel[id] = id
end

function MainScene:existUnlockLabel(id)
    return self._unlockLabel[id] 
end


return MainScene
