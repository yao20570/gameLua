--世界地图上的节点类
UIWorldNodeBase = class("UIWorldNodeBase", function ()
    local node = UIMapNodeExtend.extend(cc.Node:create())
    node.setOldPosition = node.setPosition
    node.setOldPositionX = node.setPositionX
    node.setOldPositionY = node.setPositionY
    return node
end)
UIWorldNodeBase.__index = UIWorldNodeBase

--worldTileInfo 世界格子信息 见M8
function UIWorldNodeBase:ctor(tileType)
    
    self._tileType = tileType
    
    self._mapPanel = nil
    self._worldTileInfo = nil

    local function onClickEvent(obj, value)
        if value == true then  --点击自己的建筑，不处理了
            return
        end
        self:onClickEvent()
    end
    self.touchCallback = onClickEvent

end

function UIWorldNodeBase:finalize()
    
end

function UIWorldNodeBase:getWorldPosition()
    local size = self:getContentSize()
    local scale = self:getScale()
    local pos = self:getParent():convertToWorldSpace(cc.p(self:getPosition()))
    return pos
end


function UIWorldNodeBase:settest(pos)
    logger:info("UIWorldNodeBase:settest(pos) self:%s, pos:%s", self, pos)
    logger:info("UIWorldNodeBase:settest(pos) self:%s, pos:%s", self, pos)
end

function UIWorldNodeBase:setPosition(pos)
    self:setOldPosition(pos)
end

function UIWorldNodeBase:setPositionX(x)
    self:setOldPositionX(y)
end

function UIWorldNodeBase:setPositionY(y)
    self:setOldPositionY(y)
end

--强制设置描点
function UIWorldNodeBase:getAnchorPoint()
    return cc.p(0.5, 0.5)
end

function UIWorldNodeBase:getContentSize()
    return cc.size(220,220)
end

function UIWorldNodeBase:getType()
    return self._tileType
end

function UIWorldNodeBase:getWorldTileInfo()
    return self._worldTileInfo
end

function UIWorldNodeBase:renderTile(worldTileInfo, mapPanel)
    self._mapPanel = mapPanel
    self._worldTileInfo = worldTileInfo
end

function UIWorldNodeBase:updateSeason()

end

-- 用来承载名称的层（如果自身装载名称，不能设置）
function UIWorldNodeBase:setNameParent(nameParent)    
    self._nameParent = nameParent
end

-- 资源点特效缩放
function UIWorldNodeBase:setEffectScale(scale)    
    if self._moveClip ~= nil then
    -- self._moveClip:setScale(scale)
    end
end

-- 资源点标题缩放
function UIWorldNodeBase:setResTxtScale(scale)       
end

-- 玩家基地标题缩放
function UIWorldNodeBase:setBuildTxtScale(scale)
end

function UIWorldNodeBase:onExit()
    
end

--TODO,改好了再处理这函数
function UIWorldNodeBase:getBanditDungeonInfo()
    return nil
end


function UIWorldNodeBase:onClickEvent()
    logger:info("-------onClickEvent----x:%d--y:%d-", self._worldTileInfo.x, self._worldTileInfo.y)

end

function UIWorldNodeBase:isCanClick(x, y)
    if x < 0 or x > 599 or y < 0 or y > 599 then  --世界尽头不给操作
        self._mapPanel:showSysMessage(TextWords:getTextWord(315))
        return false
    end

    return true
end






