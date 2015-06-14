local MyLabel = require("app.component.MyLabel")
local ContentTableView = class("ContentTableView",function()
    local layer = cc.Layer:create()
    return layer
end)

ContentTableView.ARRANGE_VERTICAL_FIRST     = 1  --优先竖放
ContentTableView.ARRANGE_HORIZONTAL_FIRST   = 2  --优先横放

ContentTableView.DEFAULT_ROW   = 5  --默认行数
ContentTableView.DEFAULT_COLUMN   = 1  --默认列数

ContentTableView.DEFAULT_HEIGHT   = 100  --默认高度
ContentTableView.DEFAULT_WIDTH   = 100  --默认宽度

--self.width  容器宽度
--self.height  容器高度
--self.row  容器行数
--self.column  容器列数
--self.arrange  容器元素排列
--self._items   容器的元素
--self.columnH   一列的高
--self.columnW   一列的宽
--self.showline 是否显示边框

function ContentTableView:ctor(params)
    if  params then
        if params.width and params.height then
            self.width = params.width
            self.height = params.height
            self:size(params.width, params.height)
        end

        if params.row and params.column then
            self.row = params.row
            self.column = params.column
        end

        if params.columnH and params.columnW then
            self.columnH = params.columnH
            self.columnW = params.columnW
        end

        if params.arrange then self.arrange = params.arrange end
        if params.showline then self.showline = params.showline end
    end
    self:initParams()
    if self.showline then self:showLines() end
end

function ContentTableView:changeSize(width,height)
    if width and height then
        self.width = width
        self.height = height
        self:size(width, height)
    end
    return self
end

function ContentTableView:hideLines()
    if self.topLine then self.topLine:removeSelf() end
    if self.bottomLine then self.bottomLine:removeSelf() end
    if self.leftLine then self.leftLine:removeSelf() end
    if self.rightLine then self.rightLine:removeSelf() end
end

function ContentTableView:showLines()
    self:hideLines()
    self.bottomLine = display.newLine(
        {{0, 0}, {self.width, 0}},
        {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
        :addTo(self)

    self.topLine = display.newLine(
        {{0, self.height}, {self.width, self.height}},
        {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
        :addTo(self)

    self.leftLine = display.newLine(
        {{0, 0}, {0, self.height}},
        {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
        :addTo(self)

    self.rightLine = display.newLine(
        {{self.width, 0}, {self.width, self.height}},
        {borderColor = cc.c4f(0.0, 0.0, 0.0, 1.0)})
        :addTo(self)
end

function ContentTableView:initParams()
    if not self._items then self._items = {} end
    if not self.row or self.row < 0 then  self.row = ContentTableView.DEFAULT_ROW end
    if not self.column or self.column < 0 then self.column = ContentTableView.DEFAULT_COLUMN end
    if not self.arrange then self.arrange = ContentTableView.ARRANGE_VERTICAL_FIRST end
    if not self.height then self.height = ContentTableView.DEFAULT_HEIGHT end
    if not self.width then self.width = ContentTableView.DEFAULT_WIDTH end
    if not self.showline then self.showlines = false end
    if not self.columnH then self.columnH = self.height / self.row end
    if not self.columnW then self.columnW = self.width / self.column end
end

function ContentTableView:addStringContent(label)
    if #self._items < self.row * self.column then
        -- local params = {text = content,color=display.COLOR_BLACK,size=12,align=display.LEFT_TO_RIGHT}
        -- if data and args then 
        --     params.data = data
        --     params.args = args
        --     params.refreshUseCustom = refresh
        -- end
        -- local label = MyLabel.new(params)
        local x
        local y
        if not self.arrange or self.arrange == ContentTableView.ARRANGE_VERTICAL_FIRST then
            x = math.floor(#self._items / self.row ) * self.columnW + 10 
            y = self.height - (#self._items % self.row ) * self.columnH - self.columnH/2
        else
            y = self.height - math.floor(#self._items / self.column ) * self.columnH - self.columnH/2
            x = (#self._items % self.column ) * self.columnW + 10
        end
        self._items[#self._items + 1] = label
        label:pos(x, y)
        label:size(self.columnW - 2, self.columnH - 2)
        label:addTo(self)
    end
end

function ContentTableView:addButtonContent(buttonImage,content)
    if #self._items < self.row * self.column then
        local button = cc.ui.UIPushButton.new(buttonImage)
        :setButtonSize(self.columnW - 2, self.columnH - 2)
        local buttonLabel = cc.ui.UILabel.new({text = "",color=display.COLOR_BLACK,size=12,align=display.CENTER})
        if content then 
            buttonLabel:setString(content)
        end
        button:setButtonLabel("normal", buttonLabel)
        local x
        local y
        if not self.arrange or self.arrange == ContentTableView.ARRANGE_VERTICAL_FIRST then 
            x = math.floor(#self._items / self.row ) * self.columnW + self.columnW/2
            y = self.height - (#self._items % self.row ) * self.columnH - self.columnH/2
        else
            y = self.height - math.floor(#self._items / self.column ) * self.columnH - self.columnH/2
            x = (#self._items % self.column ) * self.columnW + self.columnW/2
        end
        self._items[#self._items + 1] = button
        button:setAnchorPoint(cc.p(0.5,0.5))
        button:pos(x, y)
        button:addTo(self)
        return button
    end

end
return ContentTableView

