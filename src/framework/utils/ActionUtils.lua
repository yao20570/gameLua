
ActionUtils = {}


--[[
    这里的透明度是+/-1的增减的
    time:时间
    opacity:要到达的透明度
]]
function ActionUtils:setOpacityTo(node,time,opacity)

    local cur_opct = node:getOpacity()
    local diff = opacity - cur_opct
    local absdiff = math.abs(opacity - cur_opct)
    local fuhao = diff / absdiff --符号:正负
    local dt = time / absdiff
    local count = time/dt
    local des_opct = opacity

    local function setOpacity(node)
        local cur_opct = node:getOpacity()
        local at_opct = cur_opct+fuhao
        if fuhao > 0 then
            if at_opct >= des_opct then
                TimerManager:remove(setOpacity, node)
                node:setOpacity(des_opct)
                logger:error("~~~~~~~~~~~~~ 删除ActionUtils:setOpacityTo 的TimerManager定时器")
            else
                node:setOpacity(at_opct)
            end
        else
            if at_opct <= des_opct then
                TimerManager:remove(setOpacity, node)
                node:setOpacity(des_opct)
                logger:error("~~~~~~~~~~~~~ 删除ActionUtils:setOpacityTo 的TimerManager定时器")
            else
                node:setOpacity(at_opct)
            end
        end
    end

    logger:error("~~~~~~~~~~~~~ 加入ActionUtils:setOpacityTo 的TimerManager定时器")
    TimerManager:add(dt, setOpacity, node, count)


end


--[[
    function:  递归对节点运行函数
    Param:
           node:节点
           func:操作函数
    Return : nil
]]
function ActionUtils:resursionRunFunc(node,func)

    if type(func) ~= "function" then
        logger:error("参数#2 不是一个函数")
        return
    end

    func(node)

    local children = node:getChildren()

    for _,child in pairs(children) do
        ActionUtils:resursionRunFunc(child,func)
    end

end


--[[
    function:  递归运行action
    Param:
           node:节点
           actionFunc:一个返回动作对象的函数
    Return : nil

    目前对ccb特效使用的
]]
function ActionUtils:resursionRunAction(node,actionFunc)

    if type(actionFunc) ~= "function" then
        logger:error("参数#2 不是一个函数")
        return
    end
    
    local children = node:getChildren()
    node:runAction(actionFunc())

    for _,child in pairs(children) do
        ActionUtils:resursionRunAction(child,actionFunc())
    end

end









