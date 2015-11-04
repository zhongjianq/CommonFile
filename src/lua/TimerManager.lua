--
-- Author: thisgf
-- Date: 2014-06-19 17:33:19
-- 定时器管理器

local DRIVE_TYPE = {
	TIME = 0,
	FRAME = 1
}

TimerManager = {}

TimerManager._funcHandle = nil

TimerManager._timerList = {}
TimerManager._frameList = {}
TimerManager._enterFrameCO = nil

TimerManager._needClean = false

TimerManager._dt = 0

TimerManager._running = false

function TimerManager.start()

	if TimerManager._funcHandle then
		return
	end

	TimerManager._running = true

	TimerManager._createTimerThread()

	TimerManager._funcHandle = cc.Director:
	                getInstance():
	                getScheduler():
	                scheduleScriptFunc(
	                	TimerManager.onEnterFrame, 
	                	0, 
	                	false
	                )

end

function TimerManager._createTimerThread()

	TimerManager._enterFrameCO = coroutine.create(function()

		while TimerManager._running do

			if TimerManager._needClean then

				TimerManager._clean()

				TimerManager._needClean = false
			
			end

			for i, v in ipairs(TimerManager._timerList) do

				if v and v._isDirty == false and v._isPause == false then

					local trigger = false
					if v._type == DRIVE_TYPE.FRAME then
						v._currentFrame = v._currentFrame + 1
						if v._currentFrame >= v._totalFrame then
							trigger = true
							if v._loop then
								v._currentFrame = 0
							else
								v._isDirty = true
								TimerManager._needClean = true
							end
						end
					else
						v._countTime = v._countTime + TimerManager._dt
						if v._countTime >= v._totalTime then
							trigger = true
							if v._loop then
								v._countTime = 0
							else
								v._isDirty = true
								TimerManager._needClean = true
							end
						end
					end

					--清理空函数
					if v._callFunc == nil then
						v._isDirty = true
						TimerManager._needClean = true
					else
						if trigger then
							if v._data then
								v._callFunc(v._data)
							else
								v._callFunc()
							end
						end
					end
				end	
			end

			coroutine.yield()
		end

	end)
end

function TimerManager.stop()

	if not TimerManager._funcHandle then
		return
	end

	cc.Director:getInstance():getScheduler():unscheduleScriptEntry(TimerManager._funcHandle)

	TimerManager._funcHandle = nil

	--make coroutine dead
	TimerManager._running = false
	coroutine.resume(TimerManager._enterFrameCO)

	TimerManager._enterFrameCO = nil

end

function TimerManager._clean()

	local tempList = {}

	local i = 1
	local timerData = nil
	while i <= #TimerManager._timerList do

		timerData = TimerManager._timerList[i]

		if timerData._isDirty == true then

			timerData._callFunc = nil
			table.remove(TimerManager._timerList, i)
		else
			i = i + 1
		end

	end

end

function TimerManager._initTimer(timer, time, loop, data, token)
	timer._type = DRIVE_TYPE.TIME --时间驱动
	timer._totalTime = time * 0.001  --触发间隔时间(这里改成s)
	timer._countTime = 0 --统计时间
	timer._loop = loop  --是否循环
	timer._data = data --附带数据
	timer._isDirty = false --
	timer._isPause = false --是否暂停
	timer._token = token
end

function TimerManager._initFrame(timer, frames, loop, data, token)
	timer._type = DRIVE_TYPE.FRAME --帧驱动
	if frames <= 0 then
		frames = 1
	end
	timer._totalFrame = frames
	timer._currentFrame = 0 --统计时间
	timer._loop = loop  --是否循环
	timer._data = data --附带数据
	timer._isDirty = false --
	timer._isPause = false --是否暂停
	timer._token = token
end

--[[
    添加时间驱动定时器
    @param time 时间(ms)
    @param callFunc 回调函数
    @param loop 是否循环
    @param data 附带数据
    @param token 定时器附带的标识(用作清除)
]]
function TimerManager.addTimer(time, callFunc, loop, data, token)

	if type(callFunc) ~= "function" then
		return
	end

	for i, v in ipairs(TimerManager._timerList) do

		if v._callFunc == callFunc then

			TimerManager._initTimer(v, time, loop, data, token)

			return

		end

	end

	local timer = {}
	timer._callFunc = callFunc  --回调函数

	TimerManager._initTimer(timer, time, loop, data, token)

	TimerManager._timerList[#TimerManager._timerList + 1] = timer

end

--[[
    添加帧驱动定时器
]]
function TimerManager.addFrame(frames, callFunc, loop, data, token)

	if type(callFunc) ~= "function" then
		return
	end

	for i, v in ipairs(TimerManager._timerList) do

		if v._callFunc == callFunc then

			TimerManager._initFrame(v, frames, loop, data, token)

			return

		end

	end

	local timer = {}
	timer._callFunc = callFunc  --回调函数

	TimerManager._initFrame(timer, frames, loop, data, token)

	TimerManager._timerList[#TimerManager._timerList + 1] = timer
end

--[[
    根据回调清除定时器
]]
function TimerManager.removeTimer(callFunc)

	if type(callFunc) ~= "function" then
		return
	end

	local co = coroutine.create(function()

		for i, v in ipairs(TimerManager._timerList) do

			if v and v._isDirty == false then

				if v._callFunc == callFunc then

					v._isDirty = true

					TimerManager._needClean = true

					break
				end
			end
		end

	end)

	coroutine.resume(co)

end

--[[
    根据设置标识清除定时器
]]
function TimerManager.removeTimerWithToken(token)

	if token == nil then
		return
	end

	local co = coroutine.create(function()

		for i, v in ipairs(TimerManager._timerList) do

			if v and v._isDirty == false then

				if v._token == token then

					v._isDirty = true

					TimerManager._needClean = true

					-- break
				end
			end
		end

	end)

	coroutine.resume(co)

end

--[[
	暂停定时器
]]
function TimerManager.pauseTimer(callFunc)

	local timer = TimerManager._getTimer(callFunc)
	if timer == nil then
		return
	end

	timer._isPause = true

end

--[[
    恢复定时器
]]
function TimerManager.resumeTimer(callFunc)

	local timer = TimerManager._getTimer(callFunc)
	if timer == nil then
		return
	end

	timer._isPause = false

end

function TimerManager._getTimer(callFunc)

	for i, v in ipairs(TimerManager._timerList) do

		if v and v._isDirty == false then

			if v._callFunc == callFunc then

				return v
			end
		end
	end

	return nil

end

function TimerManager.onEnterFrame(dt)

	TimerManager._dt = dt

	local status, msg = coroutine.resume(TimerManager._enterFrameCO)
	if status == false then
		print("定时器调试>> 执行函数报错:", msg)
		-- GmManager:getInstance():addErrorInfo(msg)
		TimerManager._createTimerThread()
	end

end
