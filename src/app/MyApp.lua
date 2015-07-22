
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
diseaseArr={}
MyApp._showleftPageName = ""

constant.peopleId = 17000
constant.unemployeeId = 18000
constant.farmerId = 18010
constant.woodWorkerId = 18020
constant.stoneWorkerId = 18030
constant.leatherWorkerId = 18040
constant.blacksmithId = 18050
constant.ministerId = 18060
constant.doctorId = 18070
constant.foodId = 11000
constant.woodId = 11010
constant.stoneId = 11020
constant.leatherId = 16000
constant.metalId = 16020
constant.faithId = 16010
constant.deadId = 25000
constant.sickId = 25010
constant.usedCemeteryId = 24010


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
    math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )
    math.random(1,10000)
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
    if id == 25000 then
        print("start resource="..GameData["data"][data["key"]] .. ",add="..add)
    end
    if needError and (resource + add < 0) then
        return data["name"] .. " not enough!",0
    end

    local resourceLimit
    local actualAdd
    local isFoodNotEnough
    local lackFood = 0 
    if data["type"] == "RESOURCE" then
        local resourceLimitData = sysDataTable.definitions[data["limitID"]]
        resourceLimit = GameData["data"][resourceLimitData["key"]]
        if resource + add < 0 then
            if id == constant.foodId then
                isFoodNotEnough = true
                lackFood = -(resource + add)
            end
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
                return "workstation  not enough!",0
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
                return "people max!",0
            end
        end
        
        if resource + add < 0 then
            resource = 0
        else
            resource = resource + add
        end
    elseif data["type"] == "LAND" then
        if data["limitID"] > 0 and needError then
            local resourceLimitData = sysDataTable.definitions[data["limitID"]]
            resourceLimit = GameData["data"][resourceLimitData["key"]]
            if resource + add > resourceLimit then
                return "land max!",0
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
        if id == 25000 then
            print("end resource="..GameData["data"][data["key"]] .. ",add="..add)
        end
    end
    if isFoodNotEnough then
        return data["name"] .. " not enough!",lackFood
    end
    return "",0
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
    --埋葬死人
    bury()

    --医治生病的人
    heal()

    --计算生病的人
    peopleSick(1)

    --计算资源生产速度
    calSpeed()

    --TODO 计算欢乐度

end

function calSpeed()
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

    local errStr,lackFood = addResource(constant.foodId, GameData["data"]["foodSpeed"], false,true)
    if errStr ~= "" then
        peopleDie(1, lackFood)
    else
        GameData["data"]["hungry"] = 0
        GameData["data"]["hungryVal"] = 0
    end
    addResource(constant.woodId, GameData["data"]["woodSpeed"], false,true)
    addResource(constant.stoneId, GameData["data"]["stoneSpeed"], false,true)

    --计算制皮匠生产
    for k,cv in pairs({constant.leatherWorkerId,constant.blacksmithId,constant.ministerId}) do
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
            local canProduce = math.modf(GameData["data"][needConfig["key"]]/v.quantity)
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
            if v.id == constant.leatherId then
                GameData["data"]["leatherSpeed"] = v.quantity * GameData["data"][config["key"]]
            end
            if v.id == constant.metalId then
                GameData["data"]["metalSpeed"] = v.quantity * GameData["data"][config["key"]]
            end
            if v.id == constant.faithId then
                GameData["data"]["faithSpeed"] = v.quantity * GameData["data"][config["key"]]
            end
        end
        batchAdd(inputs,outputs)
    end
end

function bury()
    if GameData["data"]["dead"] > 0 then
        if (GameData["data"]["minister"] > 0) and (GameData["data"]["usedCemetery"] < GameData["data"]["maxCemetery"]) then
            local deadAdd = GameData["data"]["dead"]
            if deadAdd > (GameData["data"]["maxCemetery"] - GameData["data"]["usedCemetery"]) then
                deadAdd = GameData["data"]["maxCemetery"] - GameData["data"]["usedCemetery"] 
            end
            if deadAdd > GameData["data"]["minister"] then
                deadAdd = GameData["data"]["minister"]
            end
            addResource(constant.deadId, -deadAdd, false, true)
            addResource(constant.usedCemeteryId, deadAdd, false, true)
        end
    end
end

function heal()
    if GameData["data"]["sick"] > 0 then
        if GameData["data"]["doctor"] > 0 then
            local sickAdd = GameData["data"]["sick"]
            local doctorConfig = sysDataTable.definitions[constant.doctorId]
            if sickAdd > GameData["data"]["doctor"] then
                sickAdd = GameData["data"]["doctor"]
            end

            local inputs = {}
            local outputs = {}
            for i,v in ipairs(doctorConfig["input"]) do
                local input = {}
                input.id = v.id
                input.quantity = v.quantity
                table.insert(inputs, input)
                local needConfig = sysDataTable.definitions[v.id]
                local canProduce = math.modf(GameData["data"][needConfig["key"]]/v.quantity)
                if canProduce < sickAdd then
                    sickAdd = canProduce
                end
            end

            for i,v in pairs(inputs) do
                v.quantity = v.quantity * sickAdd
            end

            for i=1,sickAdd do
                local input = {}
                input.id = constant.sickId
                input.quantity = 1
                table.insert(inputs, input)

                local output = {}
                local cureId = getCureId(sysDataTable["eventWeights"]["disease"])
                output.id = cureId
                output.quantity = 1
                table.insert(outputs, output)
                addSickPeople(cureId, -1)
            end
            batchAdd(inputs,outputs)
        end
    end
end

function peopleDie(dieType,increment)
    -- die for food not enough
    if dieType == 1 then
        GameData["data"]["hungry"] = 1
        GameData["data"]["hungryVal"] = GameData["data"]["hungryVal"] + increment
        local dieAmount,val = math.modf(GameData["data"]["hungryVal"]/100)
        GameData["data"]["hungryVal"] = val * 100

        for i=1,dieAmount do
            local dieId = getRandomId(sysDataTable["eventWeights"]["hungryDie"])
            if dieId > 0 then
                addResource(constant.peopleId, -1, false,true)
                addResource(dieId, -1, false,true)
                addResource(constant.deadId, 1, false,true)
                -- 如果死掉的是生病的人,则将生病的人的列表也删除该人
                if dieId == constant.sickId then
                    addSickPeople(getCureId(sysDataTable["eventWeights"]["disease"]),-1)
                end
            end
        end
        
    -- die for war
    elseif dieType == 2 then

    end

end

function getCureId(weights)
    dump(diseaseArr, "diseaseArr", diseaseArr)
    local scopes = {}
    local seed = 0
    for i,v in ipairs(weights) do
        if diseaseArr[v.id] then
            local scope = {} 
            scope.id = v.id
            scope.min = seed + 1
            seed = seed + v.weight
            scope.max = seed
            table.insert(scopes, scope)
        end
    end

    local s = math.random(seed)
    for i,v in ipairs(scopes) do
        if v.min <= s and v.max >= s then
            return v.id
        end
    end
    return 0
end

function getRandomId(weights)
    dump(diseaseArr, "diseaseArr", diseaseArr)
    local scopes = {}
    local seed = 0
    for i,v in ipairs(weights) do
        local resource = sysDataTable.definitions[v.id]
        if GameData["data"][resource["key"]] > 0 then
            local scope = {} 
            scope.id = v.id
            scope.min = seed + 1
            seed = seed + v.weight
            scope.max = seed
            table.insert(scopes, scope)
        end
    end

    local s = math.random(seed)
    for i,v in ipairs(scopes) do
        if v.min <= s and v.max >= s then
            return v.id
        end
    end
    return 0
end

function peopleSick(sickType)
     if GameData["data"]["people"] > 0 then
        if GameData["data"]["dead"] > 0 then
            GameData["data"]["diseaseVal"] = GameData["data"]["diseaseVal"] + GameData["data"]["dead"]
            local diseaseAmount,val = math.modf(GameData["data"]["diseaseVal"]/100)
            GameData["data"]["diseaseVal"] = val * 100
            for i=1,diseaseAmount do
                local diseaseId = getRandomId(sysDataTable["eventWeights"]["disease"])
                if diseaseId > 0 then
                    addSickPeople(diseaseId,1)
                    addResource(diseaseId, -1, false,true)
                    addResource(constant.sickId, 1, false,true)
                end
            end
        end
    end
end

function buildDestory()
    
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

    --生病的人
    for i,v in pairs(GameData["data"]["diseaseArr"]) do
        diseaseArr[v.id] = v.quantity
    end
    
end

function addSickPeople(id,amount)
    if diseaseArr[id] == nil then
        local v = {}
        v.id = id
        v.quantity = 0
        table.insert(GameData["data"]["diseaseArr"], v)
        diseaseArr[id] = 0
    end
    diseaseArr[id] = diseaseArr[id] + amount
    if diseaseArr[id] < 0 then
        diseaseArr[id] = 0
    end

    for i,v in pairs(GameData["data"]["diseaseArr"]) do
        if id == v.id then
            v.quantity = diseaseArr[id]
        end
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
