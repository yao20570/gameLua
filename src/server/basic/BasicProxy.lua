

module("server", package.seeall)

BasicProxy = class("BasicProxy")

function BasicProxy:init()

end

function BasicProxy:setGameProxy(gameProxy)
    self.gameProxy = gameProxy
end

function BasicProxy:getProxy(name)
    return self.gameProxy:getProxy(name)
end