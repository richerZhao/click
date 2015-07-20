
require("config")
require("cocos.init")
require("framework.init")
scheduler = require("framework.scheduler")
GameState=require(cc.PACKAGE_NAME .. ".cc.utils.GameState")
datautils = require("app.component.datautils")
local MyApp = class("MyApp", cc.mvc.AppBase)
GameData={}
sysDataTable={}
initUserDataTable={}
userDataTable = {}
game={}
constant={}
unlockTeches={}
MyApp._showleftPageName = ""

constant.peopleId = 17000
constant.unemployeeId = 18000
constant.farmerId = 18010
constant.woodWorkerId = 18020
constant.stoneWorkerId = 18030
constant.leatherWorkerId = 18040
constant.blacksmithId = 18050
constant.ministerId = 18050
constant.foodId = 11000
constant.woodId = 11010
constant.stoneId = 11020


baseFoodAddSpeed = 0
baseFoodConsumeSpeed = 0
baseWoodAddSpeed = 0
baseStoneAddSpeed = 0
baseFurAddSpeed = 0
baseMetalAddSpeed = 0


foodSpeedScript = 'return GameData["data"]["farmer"] * (baseFoodAddSpeed + {plough}) - GameData["data"]["people"] * baseFoodConsumeSpeed'
woodSpeedScript = 'return GameData["data"]["woodWorker"] * (baseWoodAddSpeed + {saws})'
stoneSpeedScript = 'return GameData["data"]["stoneWorker"] * (baseStoneAddSpeed + {pick})'


function MyApp:ctor()
	local sysData = datautils.readData(cc.FileUtils:getInstance():fullPathForFilename("/config/sys_definition"))
	sysDataTable = vaildSysData(sysData)
    -- print(sysDataTable)
	userInitData = datautils.readData(cc.FileUtils:getInstance():fullPathForFilename("/config/init_user_data"))
    initUserDataTable = json.decode(userInitData)
	GameState.init(function(param)
        local returnValue=nil
        if param.errorCode then
            dump(param.errorCode,"GameState.init:")
        else
            -- crypto
            if param.name=="save" then
                local str=json.encode(param.values)
                str=crypto.encryptXXTEA(str, "abcd")
                returnValue={data=str}
            elseif param.name=="load" then
                local str=crypto.decryptXXTEA(param.values.data, "abcd")
                returnValue=json.decode(str)
            end
        end
        return returnValue
    end, "src/data/userdata","1234")
    GameData=GameState.load()
    dump(GameData, "GameData=", GameData)
    if not GameData then
        GameData={data=initUserDataTable}
        dump(initUserDataTable, "initUserDataTable=", initUserDataTable)
    end
    initCacheData()
    scheduler.scheduleGlobal(handler(nil, calculateSpeed),1)
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    self:enterScene("MainScene")
end

function vaildSysData(sysData)
    sysDataTable = json.decode(sysData)
    sysDataTable.definitions = {}
    for i,v in pairs(sysDataTable["components"]) do
        sysDataTable.definitions[v["id"]] = v
    end
    return sysDataTable
end

function addResource(id,add,needError,isActualAdd)
    local data = sysDataTable.definitions[id]
    --基础资源
    local resource = GameData["data"][data["key"]]
    if needError and (resource + add < 0) then
        return data["name"] .. " not enough!"
    end
    local resourceLimit
    local actualAdd
    if data["type"] == "RESOURCE" then
        local resourceLimitData = sysDataTable.definitions[data["limitID"]]
        resourceLimit = GameData["data"][resourceLimitData["key"]]
        if resource + add < 0 then
            actualAdd = -resource
            resource = 0
        elseif resource + add > resourceLimit then
            actualAdd = resourceLimit - resource
            resource = resourceLimit
        else
            actualAdd = add
            resource = resource + add
        end
        --计算衍生物产出
        if actualAdd > 0 then
            local extendData = sysDataTable.definitions[data["extendID"]]
            local extend = GameData["data"][extendData["key"]] + actualAdd
            local cycle = data["extendCycle"]
            local extendCycle = GameData["data"][extendData["extendCycleKey"]]
            extendCycle = extendCycle + actualAdd
            local extendAdd
            if extendCycle >= cycle then
                extendAdd,extendCycle = math.modf(extendCycle/cycle)
                addResource(extendData["id"],extendAdd,needError,isActualAdd)
            end
            GameData["data"][extendData["extendCycleKey"]] = extendCycle
        end
    elseif data["type"] == "RESOURCE_EXTEND" then
        if resource + add < 0 then
            resource = 0
        else
            resource = resource + add
        end
    elseif data["type"] == "RESOURCE_PRODUCE" then
        if resource + add < 0 then
            resource = 0
        else
            resource = resource + add
        end
    elseif data["type"] == "BUILDING" then
        if resource + add < 0 then
            resource = 0
        else
            resource = resource + add
        end
        -- if add > 0 then
        --     for i,v in ipairs(data["output"]) do
        --         addResource(v.id,v.quantity * add,needError,isActualAdd)
        --     end
        -- end
    elseif data["type"] == "WORK_PEOPLE" then
        if data["limitID"] > 0 and needError then
            local resourceLimitData = sysDataTable.definitions[data["limitID"]]
            resourceLimit = GameData["data"][resourceLimitData["key"]]
            if resource + add > resourceLimit then
                return "workstation  not enough!"
            end
        end
        
        if resource + add < 0 then
            resource = 0
        else
            resource = resource + add
        end
    elseif data["type"] == "PEOPLE" then
        if data["limitID"] > 0 and needError then
            local resourceLimitData = sysDataTable.definitions[data["limitID"]]
            resourceLimit = GameData["data"][resourceLimitData["key"]]
            if resource + add > resourceLimit then
                return "people max!"
            end
        end
        
        if resource + add < 0 then
            resource = 0
        else
            resource = resource + add
        end
    else
        if resource + add < 0 then
            resource = 0
        else
            resource = resource + add
        end
    end
    if isActualAdd then
        GameData["data"][data["key"]] = resource
    end
    return ""
end

function refreshLabel(intervalTags)
    local data
    local text
    local rplText
    for i,v in pairs(intervalTags) do
        data = sysDataTable.definitions[v.id]
        text = data["LabelText"]
        local resourceData
        for i,resourceID in pairs(data["LabelResourceID"]) do
            resourceData = sysDataTable.definitions[resourceID]
            rplText = GameData["data"][resourceData["key"]]
            if resourceData["type"] == "RESOURCE_SPEED" then
                if resourceData["type"]["showSign"] then
                    if rplText > 0 then
                        rplText = "+"..rplText
                    elseif rplText < 0 then
                        rplText = "-"..rplText
                    end
                end
            end
            text = (string.gsub(text, "{"..i.."}", rplText))
        end
        v.label:setString(text)
    end
end

function newClickButton(data)
    local button = cc.ui.UIPushButton.new(data["buttonImg"], {scale9 = true})
                :setButtonSize(data["buttonW"], data["buttonH"])
                :setButtonLabel("normal", cc.ui.UILabel.new({text=data["buttonText"],color=display.COLOR_BLACK,size=data["buttonTextSize"]}))
                :onButtonClicked(function(event)
                    --TODO
                    end)
                :align(display.CENTER, data["positionX"], data["positionY"])
    return button
end

function newRefreshLabel(data,needPosition)
    local label = cc.ui.UILabel.new({text = data["LabelText"], size = data["LabelTextSize"], color = display.COLOR_BLACK})
    if needPosition then 
        label:align(display.CENTER, data["positionX"] + data["buttonW"] + 10 , data["positionY"])
    end
    return label
end

function game.createBuildingMenu(menuData, callback)
    local menu = cc.ui.UIListView.new {
        viewRect = cc.rect(display.cx - 150, 10, 300, 240),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :onScroll(function(event)
                if "moved" == event.name then
                    game.bListViewMove = true
                elseif "ended" == event.name then
                    game.bListViewMove = false
                end
            end)

    local item    
    local content
    item = menu:newItem()
    content = cc.ui.UIPushButton.new("barH.png")
            :setButtonSize(300, 36)
            :setButtonLabel(cc.ui.UILabel.new({text = menuData.title, size = 16, color = display.COLOR_BLUE}))
    content:setTouchSwallowEnabled(false)
    item:addContent(content)
    item:setItemSize(300, 40)
    menu:addItem(item)
    for i, v in ipairs(menuData.items) do
        item = menu:newItem()
        content = cc.ui.UIPushButton.new("barH.png")
            :setButtonSize(300, 36)
            :setButtonLabel(cc.ui.UILabel.new({text = v.text, size = 16, color = display.COLOR_BLUE}))
            :onButtonClicked(function(event)
                if game.bListViewMove then
                    return
                end
                callback(v.input,v.output)
            end)
        content:setTouchSwallowEnabled(false)
        item:addContent(content)
        item:setItemSize(300, 40)
        menu:addItem(item)
    end
    menu:reload()

    return menu
end

function copyTab(st)  
    local tab = {}  
    for k, v in pairs(st or {}) do  
        if type(v) ~= "table" then  
            tab[k] = v  
        else  
            tab[k] = copyTab(v)  
        end  
    end  
    return tab  
end

function calculateSpeed()
    local beginIndex
    local endIndex
    local rpl
    local fSpeedScript = foodSpeedScript
    local wSpeedScript = woodSpeedScript
    local sSpeedScript = stoneSpeedScript
    for i,v in pairs(GameData["data"]["unlockTechArr"]) do
        local techConfig = sysDataTable.definitions[v]
        if techConfig["effectType"] == 1 then
            if techConfig["scriptName"] == "foodSpeedScript" then
                fSpeedScript = string.gsub(fSpeedScript, "{".. techConfig["varName"] .."}", techConfig["varValue"])
            elseif techConfig["scriptName"] == "woodSpeedScript" then
                wSpeedScript = string.gsub(wSpeedScript, "{".. techConfig["varName"] .."}", techConfig["varValue"])
            elseif techConfig["scriptName"] == "stoneSpeedScript" then
                sSpeedScript = string.gsub(sSpeedScript, "{".. techConfig["varName"] .."}", techConfig["varValue"])
            end
        end
    end

    while true do
        beginIndex = string.find(fSpeedScript, "{")
        endIndex = string.find(fSpeedScript, "}")
        if beginIndex == nil and endIndex == nil then
            break
        end
        rpl = string.sub(fSpeedScript,beginIndex,endIndex)
        fSpeedScript = string.gsub(fSpeedScript, rpl, 0)
    end

    while true do
        beginIndex = string.find(wSpeedScript, "{")
        endIndex = string.find(wSpeedScript, "}")
        if beginIndex == nil and endIndex == nil then
            break
        end
        rpl = string.sub(wSpeedScript,beginIndex,endIndex)
        wSpeedScript = string.gsub(wSpeedScript, rpl, 0)
    end

    while true do
        beginIndex = string.find(sSpeedScript, "{")
        endIndex = string.find(sSpeedScript, "}")
        if beginIndex == nil and endIndex == nil then
            break
        end
        rpl = string.sub(sSpeedScript,beginIndex,endIndex)
        sSpeedScript = string.gsub(sSpeedScript, rpl, 0)
    end

    GameData["data"]["foodSpeed"] =dostring(fSpeedScript)
    GameData["data"]["woodSpeed"] =dostring(wSpeedScript)
    GameData["data"]["stoneSpeed"] =dostring(sSpeedScript)

    local errStr = addResource(constant.foodId, GameData["data"]["foodSpeed"], false,true)
    if errStr ~= "" then
        print("errStr="..errStr)
        -- TODO people die
    end
    addResource(constant.woodId, GameData["data"]["woodSpeed"], false,true)
    addResource(constant.stoneId, GameData["data"]["stoneSpeed"], false,true)

    --TODO 
    --计算制皮匠生产
    for k,cv in pairs({constant.leatherWorkerId,constant.blacksmithId}) do
        local config = sysDataTable.definitions[cv]
        local inputs = {}
        local outputs = {}
        local maxCanProduce = GameData["data"][config["key"]] 
        for i,v in ipairs(config["input"]) do
            local input = {}
            input.id = v.id
            input.quantity = v.quantity
            table.insert(inputs, input)
            local needConfig = sysDataTable.definitions[v.id]
            local canProduce = math.modf(GameData["data"][needConfig["key"]]/v["quantity"])
            if canProduce < maxCanProduce then
                maxCanProduce = canProduce
            end
        end

        for i,v in pairs(inputs) do
            v.quantity = v.quantity * maxCanProduce
        end

        for i,v in pairs(config["output"]) do
            local output = {}
            output.id = v.id
            output.quantity = v.quantity * maxCanProduce
            table.insert(outputs, output)
        end
        batchAdd(inputs,outputs)
    end
    

    --计算铁匠生产

    --计算牧师生产

    --计算欢乐度生产

end

function batchAdd(inputs,outputs)
    for i,v in ipairs(inputs) do 
        addResource(v.id,-v.quantity,false,true)
    end 
    
    for i,v in ipairs(outputs) do 
        addResource(v.id,v.quantity,false,true)
    end
end

function initCacheData()
    -- foodSpeed  
    local peopleConfig = sysDataTable.definitions[constant.peopleId]
    local farmerConfig = sysDataTable.definitions[constant.farmerId]
     for i,v in pairs(farmerConfig["output"]) do
        if v.id == constant.foodId then
            baseFoodAddSpeed = v.quantity
            break
        end
    end

    for i,v in pairs(peopleConfig["input"]) do
        if v.id == constant.foodId then
            baseFoodConsumeSpeed = v.quantity
            break
        end
    end

    -- woodSpeed  
    local woodWorkerConfig = sysDataTable.definitions[constant.woodWorkerId]
    for i,v in pairs(woodWorkerConfig["output"]) do
        if v.id == constant.woodId then
            baseWoodAddSpeed = v.quantity
            break
        end
    end

    -- stoneSpeed  
    local stoneWorkerConfig = sysDataTable.definitions[constant.stoneWorkerId]
     for i,v in pairs(stoneWorkerConfig["output"]) do
        if v.id == constant.stoneId then
            baseStoneAddSpeed = v.quantity
            break
        end
    end

    --解锁科技
    for i,v in pairs(GameData["data"]["unlockTechArr"]) do
        unlockTeches[v] = v
    end
    
end

function registUnlockTech(techId)
    table.insert(GameData["data"]["unlockTechArr"], techId)
    for i,v in pairs(GameData["data"]["unlockTechArr"]) do
        unlockTeches[v] = v
    end
end

function existUnlockTech(techId)
    return unlockTeches[techId]
end

function dostring(code)
    local x = assert(loadstring(code))
    return x()
end

return MyApp
