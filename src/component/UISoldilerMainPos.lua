-- /**
--  * @Author:    fzw
--  * @DateTime:    2016-08-27 15:30:23
--  * @Description: 通用佣兵坑位UI
--  */

--[[
结构：UI默认的坑是imgPos，如果有不同的坑，可以UI里添加新的坑，然后getChildByName(name)

用法：先new一个UISoldilerMainPos，然后getChildByName(name),获取到坑位UI,然后clone到当前panel界面使用
示例：UITeamDetailPanel:initPosImg()
]]

--[[
imgPos = 佣兵坑位
consPos = 军师坑位
]]

UISoldilerMainPos = class("UISoldilerMainPos")

function UISoldilerMainPos:ctor(parent)
    local uiSkin = UISkin.new("UISoldilerMainPos")
    self._uiSkin = uiSkin
    self._parent = parent
end

function UISoldilerMainPos:finalize()
    -- print("自杀啦啦啦啦")
    local imgPos = self._uiSkin:getChildByName("imgPos")
    if imgPos then
        if imgPos._soldierEffect then
            imgPos._soldierEffect:finalize()
        end
    end

    self._uiSkin:finalize()
end

function UISoldilerMainPos:getChildByName(name)
    return self._uiSkin:getChildByName(name)
end



