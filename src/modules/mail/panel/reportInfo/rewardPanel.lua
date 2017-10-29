rewardPanel = {}

--rewardPanel.NAME = "rewardPanel"



function rewardPanel:ctor(panel,parent)

	self._panel = panel

	self._parent = parent

end



function rewardPanel:updateData(panel,data)

	local selfData = data.infos.reward

    local isRebelsReport = data.infos.isPerson == 2

	if #selfData == 0 and isRebelsReport == false then

		panel:setVisible(false)

		return

	else

		panel:setVisible(true)

		self:onUpdateItemPanel(panel,selfData, data.infos.isPerson)

	end



end



function rewardPanel:onUpdateItemPanel(panel,data, isPerson)

	local index = 1

	for _,v in pairs(data) do

		local item = panel:getChildByName("item"..index)

		item:setVisible(true)

		local person = item:getChildByName("person")

		local config = ConfigDataManager:getConfigByPowerAndID(v.power,v.typeid)



		local tmp = {}

        tmp.power = v.power

        tmp.typeid = v.typeid

        tmp.num = v.num

		local icon = person.icon

        if icon == nil then

            icon = UIIcon.new(person, tmp, true, self._parent, nil, true)

            person.icon = icon

        else

        	icon:updateData(tmp)

        end

		index = index + 1

	end

    ------

    --

	for i = index,6 do

		local item = panel:getChildByName("item"..i)

		item:setVisible(false)

	end 



    -- 击杀的乱军数量已超过限制，无法再获得奖励

    local isRebelsReport = isPerson == 2

    local labRebelsTip = panel:getChildByName("labRebelsTip")

    labRebelsTip:setVisible(isRebelsReport and index == 1)

end

