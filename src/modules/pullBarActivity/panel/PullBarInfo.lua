
PullBarInfo = class("PullBarInfo", BasicPanel)
PullBarInfo.NAME = "PullBarInfo"

function PullBarInfo:ctor(view, panelName)
    PullBarInfo.super.ctor(self, view, panelName, 600)

end

function PullBarInfo:finalize()
    PullBarInfo.super.finalize(self)
end

function PullBarInfo:initPanel()
	PullBarInfo.super.initPanel(self)

	self:setTitle(true, self:getTextWord(1325))
end

function PullBarInfo:registerEvents()
	PullBarInfo.super.registerEvents(self)
	self.listView = self:getChildByName("Panel_69/ListView")
end

function PullBarInfo:onShowHandler(typeId)
	self:updateInfo(typeId)
end

function PullBarInfo:updateInfo(typeId)
	local info = ConfigDataManager:getConfigData("LaBaShowRewardConfig")
	local data = {}
	for k,v in pairs(info) do
		if v.rewardgroup == typeId then
			table.insert(data,v)
		end
	end
	self:renderListView(self.listView, data, self, self.renderItemPanel)
end

function PullBarInfo:renderItemPanel(item, data, index)
	local icon = {}
	local iconAll = item:getChildByName("iconAll")
	for i = 1, 3 do
		icon[i] = item:getChildByName("icon"..i)
	end
	for i = 1,data.num do
		local tmp = {typeid = data.pictype,num = 0,color = data.color}
		local oneIcon = icon[i].oneIcon
   		if oneIcon == nil then
        	oneIcon = UIOtherIcon.new(icon[i], tmp)
        	icon[i].oneIcon = oneIcon
   		else
        	oneIcon:updateData(tmp)
    	end
        local size = icon[i]:getContentSize()
        oneIcon:setIconPosition(size.width * 0.5, size.height * 0.5)
	end

	local numData = StringUtils:jsonDecode(data.reward)
	local _power,_typeid,_num
	for k,v in pairs(numData) do
		_power = v[1]
		_typeid = v[2]
		_num = v[3]
	end
 	local tmp = {typeid = _typeid,num = _num,power = _power}
 	local allIcon = iconAll.allIcon
 	 if allIcon == nil then
        allIcon = UIIcon.new(iconAll, tmp, true, self)
        iconAll.allIcon = allIcon
    else
        allIcon:updateData(tmp)
    end
end