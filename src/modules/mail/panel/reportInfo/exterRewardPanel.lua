exterRewardPanel = {}
exterRewardPanel.NAME = "exterRewardPanel"
exterRewardPanel.ITEM_COUNT = 6
function exterRewardPanel:ctor(panel,parent)
    self._panel = panel
    self._parent = parent
end

-- function exterRewardPanel:updateData(data)
--     local selfData = data.reward
--     local clonePanel = {}
--     if selfData ~= nil then
--     	local count = math.ceil(table.size(selfData) / 2)
--     	for index = 1,count do
--     		local cloneCell = self._panel:clone()
--             if index == 1 then
--                 self:updateCell(cloneCell,selfData,index,true)
--             else
--                 self:updateCell(cloneCell,selfData,index,false)
--             end
--     		table.insert(clonePanel,cloneCell)
--     	end
--         return clonePanel
--     end
-- end

function exterRewardPanel:updateData(listView,data)

    -- local consize = panel:getContentSize()
    -- panel:setContentSize(consize.width,consize.height - 240)

    -- for _,v in pairs(panel:getChildren()) do
    --     local posY = v:getPositionY()
    --     v:setPositionY(posY - 240)
    -- end
    --print("数据  奖励"..#data.reward)
    local selfData = TableUtils:splitData(data.reward, 2)
    --print("奖励数据 "..#selfData)

    self._parent:renderListView(listView, selfData, self, self.renderItem)

    -- local index = 1
    -- for _,v in pairs(selfData) do
    --     if index <= exterRewardPanel.ITEM_COUNT then
    --         local item = panel:getChildByName("item"..index)
    --         item:setVisible(true)
    --         local name = item:getChildByName("name")
    --         local count = item:getChildByName("count")
    --         local config = ConfigDataManager:getConfigByPowerAndID(v.power,v.typeid)
    --         name:setString(config.name)
    --         count:setString(v.num)
    --         local person = item:getChildByName("people")
    --         local tmp = {}
    --         tmp.power = v.power
    --         tmp.typeid = v.typeid
    --         tmp.num = v.num
    --         local icon = person.icon
    --         if icon == nil then
    --             icon = UIIcon.new(person, tmp, true, self._parent)
    --             person.icon = icon
    --         else
    --             icon:updateData(tmp)
    --         end
    --     end
    --     index = index + 1
    -- end

    -- for i = index,exterRewardPanel.ITEM_COUNT do -- 卧槽，为什么写死了6？
    --     local item = panel:getChildByName("item"..i)
    --     item:setVisible(false)
    -- end
end

function exterRewardPanel:renderItem(item, data)
    for i=1,2 do
        local itemData = data[i]
        local panel = item:getChildByName("item"..i)
        panel:setVisible(itemData ~= nil)
        if itemData ~= nil then
            local person = panel:getChildByName("people")
            local count = panel:getChildByName("count")
            local name = panel:getChildByName("name")
            if person.icon == nil then
                person.icon = UIIcon.new(person, itemData, true, self._parent)
            else
                person.icon:updateData(itemData)
            end
            local config = ConfigDataManager:getConfigByPowerAndID(itemData.power,itemData.typeid)
            name:setString(config.name)
            count:setString(itemData.num)
        end
    end
end

-- function exterRewardPanel:updateCell(panel,data,index,isShowTitle)
--     local Image_18_0_0 = panel:getChildByName("Image_18_0_0")
--     Image_18_0_0:setVisible(isShowTitle)
--     local cellPanel1 = panel:getChildByName("cellPanel1")
--     local item,count 
--     for i = (index - 1)*2 + 1, (index - 1)*2 + 2 do
--         if i % 2 == 0 then
--             count = 2
--         else
--             count = 1
--         end
--         item = cellPanel1:getChildByName("item"..count)
--         if data[i] ~= nil then
--             item:setVisible(true)
--             local name = item:getChildByName("name")
--             local count = item:getChildByName("count")
--             local config = ConfigDataManager:getConfigByPowerAndID(data[i].power,data[i].typeid)
--             name:setString(config.name)
--             count:setString(data[i].num)
--             local person = item:getChildByName("people")
--             local tmp = {}
--             tmp.power = data[i].power
--             tmp.typeid = data[i].typeid
--             tmp.num = data[i].num
--             local icon = person.icon
--             if icon == nil then
--                 icon = UIIcon.new(person, tmp, true, self._panel)
--                 person.icon = icon
--             else
--                 icon:updateData(data)
--             end
--         else
--             item:setVisible(false)
--         end
--     end
-- 	-- local item 
-- 	-- if (k % 2) == 1 then
-- 	-- 	item = cell:getChildByName("item1")
-- 	-- else
-- 	-- 	item = cell:getChildByName("item2")
-- 	-- end
-- 	-- item:setVisible(true)
-- 	-- local name = item:getChildByName("name")
-- 	-- local count = item:getChildByName("count")
-- 	-- local config = ConfigDataManager:getConfigByPowerAndID(data.power,data.typeid)
-- 	-- name:setString(config.name)
-- 	-- count:setString(data.num)
-- end