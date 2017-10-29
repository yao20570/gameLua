

-----------基础动画类------
BaseAnimation = class("BaseAnimation")


function BaseAnimation:ctor(parent)
    self.parent = parent
end

-----释放
function BaseAnimation:finalize()

	for k,_ in pairs(self) do
		self[k] = nil
	end
end

function BaseAnimation:setGameState(gameState)
	self._gameState = gameState
end

function BaseAnimation:setData(data)
	self.data = data
end

function BaseAnimation:getModulePanel(moduleName, panelName)
	local module = self._gameState:getModule(moduleName)
	if module == nil then
		return nil
	end
    return module:getPanel(panelName)
end

function BaseAnimation:addChild(child)
	self.parent:addChild(child)
end

function BaseAnimation:getParent()
	return self.parent
end

---开始播放
function BaseAnimation:play()

end

function BaseAnimation:getProxy(name)
	return self._gameState:getProxy(name)
end

function BaseAnimation:getLayer(layerName)
	return self._gameState:getLayer(layerName)
end