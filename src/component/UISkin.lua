UISkin = class("UISkin")

function UISkin:ctor(uiName, initHandler, doLayoutHanlder, moduleName)

    local time = os.clock()
    logger:error("UISkin=========》%s", uiName)
    local uiPath = string.format("ui/%s.ExportJson", uiName)
    self.root  = ccs.GUIReader:getInstance():widgetFromJsonFile(uiPath)

    self.root:setName(uiName)

    self._uiPath = uiPath
    self._uiName = uiName

    --获取到的是plist列表
    local textureList = ccs.GUIReader:getInstance():getTextureList(uiPath)

    local file_type = TextureManager.file_type
    for _,plistKey in pairs(textureList) do
        -- local file_type = TextureManager.file_type
        -- if plistKey == "dungeonIcon_ui_resouce_big_0.plist" then
        --     file_type = ".webp"
        -- end
        local key = string.gsub(plistKey, ".plist", file_type)

        TextureManager:addTextureKey2TopModule("ui/" .. key, moduleName) 
    end

    local function doLayout()
        -- print("~~~~~~~doLayout~~~~~~~doLayout~~~~~~~~~doLayout~~~~~~~~~")
        if doLayoutHanlder ~= nil then
            doLayoutHanlder(self)
        end
    end
    self.root:addDolayoutEventListener(doLayout)

    if initHandler ~= nil then
        initHandler(self)
    end

    logger:info("~~UI加载耗时:%s  %f", uiName, os.clock() - time)

    -- local mainPanel = self:getChildByName("mainPanel")
    -- if mainPanel ~= nil and mainPanel:getTag() == 91295 then
    --     print("!!!!!!!!!!!!!mainPanel ~= nil and mainPanel:getTag() == 91295!!!!!!!!!!!!!!!", uiName)
    -- end
    
--    self.root:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
--    self.root:setBackGroundColorOpacity(155)
    
end

function UISkin:finalize()

    ccs.ActionManagerEx:getInstance():releaseAction(self._uiName .. ".ExportJson")

    self.root:removeFromParent()
    self.root = nil
end

function UISkin:setParent(parent)
    parent:addChild(self.root)
end

----可以通过路径查找对应的child
function UISkin:getChildByName(name)
    local ary = StringUtils:splitString(name,"/")
    
    local curPanel = self.root
    for _, key in pairs(ary) do
    	curPanel = curPanel:getChildByName(key)
    end
    
    return curPanel
end

function UISkin:setEnabled(bool)
    self.root:setEnabled(bool)
end

function UISkin:setTouchEnabled(bool)
    self.root:setTouchEnabled(bool)
end

function UISkin:setVisible(visible)
    self.root:setVisible(visible)
end

function UISkin:addChild(child)
    self.root:addChild(child)
end

function UISkin:removeChild(child)
    self.root:removeChild(child)
end

function UISkin:runAction(action)
    self.root:runAction(action)
end

function UISkin:stopAllActions()
    self.root:stopAllActions()
end

function UISkin:getPosition()
    return self.root:getPosition()
end

function UISkin:setPosition(x , y)
    self.root:setPosition(x, y)
end

function UISkin:getPositionX()
    return self.root:getPositionX()
end

function UISkin:setPositionX(x)
    local posX = x or 0
    self.root:setPositionX(posX)
end

function UISkin:getPositionY()
    return self.root:getPositionY()
end

function UISkin:setPositionY(y)
    local posY = y or 0
    self.root:setPositionY(posY)
end

function UISkin:isVisible()
    return self.root:isVisible()
end

function UISkin:setLocalZOrder(order)
    self.root:setLocalZOrder(order)
end

function UISkin:getLocalZOrder()
    return self.root:getLocalZOrder()
end

function UISkin:getRootNode()
    return self.root
end

function UISkin:setAnchorPoint(point)
    self.root:setAnchorPoint(point)
end

function UISkin:getContentSize()
    return self.root:getContentSize()
end

function UISkin:setScale(scale)
    self.root:setScale(scale)
end

function UISkin:setOpacity(opacity)
    self.root:setOpacity(opacity)
end

function UISkin:setBackGroundColorOpacity(opacity)
    self.root:setBackGroundColorOpacity(opacity)
end

function UISkin:setBackGroundColorType(colorType)
    self.root:setBackGroundColorType(colorType)
end

function UISkin:setName(name)
    self.root:setName(name)
end