module("server", package.seeall)

Technology = class("Technology")

function Technology:ctor()
	self.type = 0
	self.level = 0
	self.nextLevelTime = 0 --下一级升级完成时间
	self.lastBlanceTime = 0 --上次结算时间
	self.state = 0 --功能0未开启，1开启
end