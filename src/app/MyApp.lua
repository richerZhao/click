
require("config")
require("cocos.init")
require("framework.init")
GameState=require(cc.PACKAGE_NAME .. ".cc.utils.GameState")
GameData={}
sysDataTable={}
initUserDataTable={}
datautils = require("app.component.datautils")

local MyApp = class("MyApp", cc.mvc.AppBase)
userDataTable = {}
game={}

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
    if not GameData then
        GameData={data=initUserDataTable}
        GameData["data"]["unlockTeches"]={}
    end
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

function addResource(id,add)
    local data = sysDataTable.definitions[id]
    --基础资源
    local resource = GameData["data"][data["key"]]
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
            if extendCycle >= cycle then
                local extendAdd = extendCycle / cycle
                extendCycle = extendCycle % cycle
                addResource(extendData["id"],extendAdd)
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
    end
    GameData["data"][data["key"]] = resource
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

function game.createMenu(items, callback)
    local menu = cc.ui.UIListView.new {
        viewRect = cc.rect(display.cx - 200, display.bottom + 100, 400, display.height - 200),
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL}
        :onScroll(function(event)
                if "moved" == event.name then
                    game.bListViewMove = true
                elseif "ended" == event.name then
                    game.bListViewMove = false
                end
            end)

    for i, v in ipairs(items) do
        local item = menu:newItem()
        local content

        content = cc.ui.UIPushButton.new()
            :setButtonSize(200, 40)
            :setButtonLabel(cc.ui.UILabel.new({text = v, size = 24, color = display.COLOR_BLUE}))
            :onButtonClicked(function(event)
                if game.bListViewMove then
                    return
                end

                -- callback(v)
            end)
        content:setTouchSwallowEnabled(false)
        item:addContent(content)
        item:setItemSize(120, 40)
        menu:addItem(item)
    end
    menu:reload()

    return menu
end

return MyApp
