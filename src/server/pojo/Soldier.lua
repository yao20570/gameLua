module("server", package.seeall)

Soldier = class("Soldier")

function Soldier:ctor()
	self.typeId = 0
	self.num = 0

    self.powerList = {}
	self.hp = 0
	self.attack = 0


	self.lostNum = 0
    self.baseNum = 0
    self.hpMax = 0
    self.hp = 0
    self.atk = 0
    self.hitRate = 0
    self.dodgeRate = 0
    self.critRate = 0
    self.defRate = 0
    self.wreck = 0
    self.defend = 0
    self.initiative = 0
    self.hpMaxRate = 0
    self.atkRate = 0
    self.infantryHpMax = 0
    self.infantryAtk = 0
    self.cavalryHpMax = 0
    self.cavalryAtk = 0
    self.pikemanHpMax = 0
    self.pikemanAtk = 0
    self.archerHpMax = 0
    self.archerHpatk = 0
    self.load = 0
    self.loadRate = 0
    self.speedRate = 0
    self.pveDamAdd = 0
    self.pveDamDer = 0
    self.pvpDamAdd = 0
    self.pvpDamDer = 0
    self.damadd = 0
    self.damder = 0
end