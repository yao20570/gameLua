StateMachine = class("StateMachine")

function StateMachine:ctor(owner)
	self._owner = owner
	self._curState = nil
	self._preState = nil
	self._globalState = nil
end

function StateMachine:finalize()
    if self._curState ~= nil then
        self._curState:finalize()
    end
end

---init
function StateMachine:setCurState(state)
	self._curState = state
end

function StateMachine:getCurState()
    return self._curState
end

function StateMachine:update(dt)
    self._curState:execute(self._owner)
end

function StateMachine:changeState(newState, telegram)
	assert(self._curState ~= nil)
	if newState == self._curState then
	    return
	end

--    local function callback()
--        
--    end
    self._curState:exit(self._owner, telegram)
    self._curState = newState
    self._curState:enter(self._owner, telegram)
	
end

function StateMachine:handleMessage(telegram)
	self._curState:onMessage(self._owner, telegram)
end
