import(".utils")
local MyLabel = class("MyLabel", cc.ui.UILabel)

--self.text 设置的可变文本内容,形式如{1},{2},代表对应可变参数
--self.refreshUseCustom 刷新时是否使用自定义 默认使用



function MyLabel:ctor(params,root)
    MyLabel.super.ctor(self,params)
    self.root = root
    self.refreshUseCustom=false
	self.args={}
	self.text=params.text
    if params.args then self.args = params.args end
    if params.refreshUseCustom then self.refreshUseCustom=true end
    if self.refreshUseCustom and params.data then self:refresh(params.data) end
end


function MyLabel:refresh(data)
	if self.refreshUseCustom then 
		local t = replace(self.text, data, self.args)
		self:setString(t)
	end
end

return MyLabel