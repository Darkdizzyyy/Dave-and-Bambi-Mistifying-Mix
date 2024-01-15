function onCreate()
	makeLuaSprite('DayBG','dave/sky',-680,-140)
	addLuaSprite('DayBG',false)
	setLuaSpriteScrollFactor('DayBG', 0.1, 0.1)
	
	makeLuaSprite('Hills','dave/hills', -652, -20)
	addLuaSprite('Hills',false)
	setLuaSpriteScrollFactor('Hills', 0.7, 0.7)

	makeLuaSprite('grassBG','dave/grass bg', -725, 400)
	addLuaSprite('grassBG',false)
	setLuaSpriteScrollFactor('grassBG', 0.3, 0.3)

	makeLuaSprite('Gate','dave/gate', -542, 440)
	addLuaSprite('Gate',false)
	setLuaSpriteScrollFactor('Gate', 0.9, 0.9)

	makeLuaSprite('grass','dave/grass', -725, 580)
	addLuaSprite('grass',false)
	setLuaSpriteScrollFactor('grass', 1, 1)
	setProperty('grass.scale.x', 0.8);
end