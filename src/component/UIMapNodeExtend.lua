UIMapNodeExtend = class("UIMapNodeExtend")
UIMapNodeExtend.__index = UIMapNodeExtend

function UIMapNodeExtend.extend(target)
    local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, UIMapNodeExtend)

    local function handler(event)
        if event == "enter" then
            target:onEnter()
        elseif event == "enterTransitionFinish" then
            target:onEnterTransitionFinish()
        elseif event == "exitTransitionStart" then
            target:onExitTransitionStart()
        elseif event == "cleanup" then
            target:onCleanup()
        elseif event == "exit" then
            target:onExit()
        end
    end
    target:registerScriptHandler(handler)

    return target
end

function UIMapNodeExtend:onEnter()
--    logger:info("UIMapNodeExtend:onEnter")
end

function UIMapNodeExtend:onExit()
end

function UIMapNodeExtend:onEnterTransitionFinish()
end

function UIMapNodeExtend:onExitTransitionStart()
end

function UIMapNodeExtend:onCleanup()
end