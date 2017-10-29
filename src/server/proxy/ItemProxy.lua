module("server", package.seeall)

ItemProxy = class("ItemProxy", BasicProxy)

function ItemProxy:ctor(itemList)
    self._items = {}
    self:initItems(itemList)
end

function ItemProxy:initItems(itemList)
    for _, itemInfo in pairs(itemList) do
        self:addItem(itemInfo.typeid, itemInfo.num)
    end
end

function ItemProxy:updateItems(itemList)
    for _, itemInfo in pairs(itemList) do
        local typeId = itemInfo.typeid
        local item = self:getItemByTypeId(typeId)
        if item ~= nil then
            item.typeId = itemInfo.typeid --直接用服务器的数据刷新
            item.num = itemInfo.num
        else
            self:addItem(itemInfo.typeid, itemInfo.num)
        end
    end
end

function ItemProxy:isHasTypeId(typeId)
	if self._items[typeId] ~= nil then
		return true
	end
	return false
end

function ItemProxy:getItemByTypeId(typeId)
    return self._items[typeId]
end

function ItemProxy:addItem(typeId, num)
    if self:isHasTypeId(typeId) then
    	self:addItemNum(typeId, num)
    else
    	self:createItem(typeId, num)
    end
end

function ItemProxy:createItem(typeId, num)
    local jsonObject = ConfigDataManager:getConfigById(ConfigData.ItemConfig, typeId)
    if jsonObject == nil then
    	return -1
    end

    local item = Item.new()
    item.num = num
    item.typeId = typeId
    self._items[typeId] = item

end

function ItemProxy:getItemNum(typeId)
    local item = self:getItemByTypeId(typeId)
    if item == nil then
    	return 0
    end
    return item.num
end

function ItemProxy:addItemNum(typeId, add)
	local item = self:getItemByTypeId(typeId)
	if add < 0 then
		add = 0
	end
	local value = self:getItemNum(typeId)
	item.num = value + add
end

function ItemProxy:reduceItemNum(typeId, reduce)
	local item = self:getItemByTypeId(typeId)
	if reduce < 0 then
		reduce = 0
	end
	local value = self:getItemNum(typeId)
	local result = value - reduce
	item.num = result
	if result <= 0 then
		self._items[typeId] = nil
	end
end

---获取一个道具的Info
function ItemProxy:getItemInfo( typeId )
	local item = self:getItemByTypeId(typeId)
	local infoBuilder = {}
	if item ~= nil then
		infoBuilder.num = item.num
		infoBuilder.typeid = item.typeId
	else
		infoBuilder.num = 0
		infoBuilder.typeid = typeId
	end
	return infoBuilder
end

--List<Common.ItemInfo> 获取所有道具的信息
function ItemProxy:getAllItemInfo()
    return self:getAllItemInfos()
end

function ItemProxy:getAllItemInfos()
    local listBuilder = {}
    for _, item in pairs(self._items) do
    	local infoBuilder = {}
    	infoBuilder.num = item.num
    	infoBuilder.typeid = item.typeId
    	table.insert(listBuilder, infoBuilder)
    end

    return listBuilder
end


--TODO 道具使用
function ItemProxy:doUserItem()

end