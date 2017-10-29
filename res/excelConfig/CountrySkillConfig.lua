local CountrySkill = {} 
CountrySkill[1] = {ID = 1, skillName = '破防', Icon = 1, description = '目标身上保护罩效果全部消失，且6个小时内无法使用保护罩', buffID = '[30019]', useTime = 5, coolDown = 21600, durationTime = 21600}
CountrySkill[2] = {ID = 2, skillName = '流放', Icon = 2, description = '目标被迁移到低级区域，且6个小时内无法进行迁城', buffID = '[30020]', useTime = 5, coolDown = 21600, durationTime = 21600}
CountrySkill[3] = {ID = 3, skillName = '禁武', Icon = 3, description = '目标在6个小时内，无法派遣部队', buffID = '[30017]', useTime = 5, coolDown = 21600, durationTime = 21600}
CountrySkill[4] = {ID = 4, skillName = '禁言', Icon = 4, description = '目标在6个小时内，无法进行发言和使用喇叭', buffID = '[30018]', useTime = 5, coolDown = 21600, durationTime = 21600}
return CountrySkill