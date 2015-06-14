
local ContentListView = class("ContentListView",cc.ui.UIListView)

function ContentListView:ctor(params,root)
    ContentListView.super.ctor(self,params)
    self.root = root
end

function ContentListView:addItemWithContent(content)
    local item = self:newItem()
        item:addContent(cc.ui.UILabel.new(
            {text = content,
            size = 12,
            align = display.LEFT_TO_RIGHT,
            color = display.COLOR_BLACK}))
        item:setItemSize(300, 20)
        self:addItem(item,1)

        if #self.items_ > 30 then 
            self:removeItem(self.items_[#self.items_])
        end
        self:reload()
end

function ContentListView:addDelayItemWithContent(content,delay)
    self:performWithDelay(function()
        self:addItemWithContent(content)
    end,delay) 
end

return ContentListView