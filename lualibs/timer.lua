-------------------------------
--Timer library--------------
-------------------------------
CurTime = os.time

timer = {}
timer._timers = {}

function timer.Simple(t, func, ...)
		 tbl = {}
		 tbl.Repeats = 1
		 tbl.ExecTime = os.time() + t
		 tbl.Time = t
		 tbl.Func = func
		 tbl.Args = arg

		 table.insert(timer._timers,tbl)
end

function timer.Create(name,t,rep,func, ...)
		 tbl = {}
		 tbl.ExecTime = os.time() + t
		 tbl.Time = t
		 tbl.Repeats = rep
		 tbl.Func = func
		 tbl.Args = arg
		 
		 timer._timers[name] = tbl
end

function timer.Check(name)
	 return timer._timers[name]["Time"]
end

function timer.Delete(name)
         timer._timers[name] = nil
end

function timer._CheckTimers()
         for k,tbl in pairs(timer._timers) do
             if os.time() >= tbl.ExecTime then
                tbl.Func(unpack(tbl.Args))
                
                tbl.Repeats = tbl.Repeats - 1
                
                if tbl.Repeats == 0 then
                   timer._timers[k] = nil
                else
                   tbl.ExecTime = os.time() + tbl.Time
                end
             end
         end
end

hook.Add("Think","timer_CheckTimers",timer._CheckTimers)




