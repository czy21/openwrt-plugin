-- Copyright 2023 Bruce Chen <a805899926@gmail.com>
-- Licensed to the public under the Apache License 2.0.

local fs  = require "nixio.fs"
local sys = require "luci.sys"
local json = require "luci.jsonc"
local uci = require "luci.model.uci".cursor()
local testfullps = sys.exec("ps --help 2>&1 | grep BusyBox") --check which ps do we have
local psstring = (string.len(testfullps)>0) and  "ps w" or  "ps axfw" --set command we use to get pid

local m = Map("adguardhome", translate("AdguardHome"))
local s = m:section( TypedSection, "service", translate("Service"))
s.template = "cbi/tblsection"
s.addremove = true
s.add_select_options = {}
s.extedit = luci.dispatcher.build_url("admin", "services", "adguardhome", "edit", "%s")

function s.getPID(section) -- Universal function which returns valid pid # or nil
	local pid = sys.exec("%s | grep -w '[a]dguardhome.%s.pid'" % { psstring, section })
	if pid and #pid > 0 then
		return tonumber(pid:match("^%s*(%d+)"))
	else
		return nil
	end
end

local port = s:option( DummyValue, "port", translate("Port") )
port.template="adguardhome/avalue"
function port.cfgvalue(self, section)
	return AbstractValue.cfgvalue(self, section) or "-"
end

local enabled = s:option( Flag, "enabled", translate("Enabled") )

local active = s:option( DummyValue, "_active", translate("Started") )
function active.cfgvalue(self, section)
	local pid = s.getPID(section)
	if pid ~= nil then
		return (sys.process.signal(pid, 0))
			and translatef("yes (%i)", pid)
			or  translate("no")
	end
	return translate("no")
end

local updown = s:option( Button, "_updown", translate("Start/Stop") )
updown._state = false
updown.redirect = luci.dispatcher.build_url("admin", "services", "adguardhome")

function updown.cbid(self, section)
	local pid = s.getPID(section)
	self._state = pid ~= nil and sys.process.signal(pid, 0)
	self.option = self._state and "stop" or "start"
	return AbstractValue.cbid(self, section)
end
function updown.cfgvalue(self, section)
	self.title = self._state and "stop" or "start"
	self.inputstyle = self._state and "reset" or "reload"
end
function updown.write(self, section, value)
	if self.option == "stop" then
		sys.call("/etc/init.d/adguardhome stop %s" % section)
	else
		sys.call("/etc/init.d/adguardhome start %s" % section)
	end
	luci.http.redirect( self.redirect )
end

function s.remove(self, name)
	local cfg_file  = "/etc/adguardhome/" ..name.. ".yaml"
	if fs.access(cfg_file) then
		fs.unlink(cfg_file)
	end
	uci:delete("adguardhome", name)
	uci:save("adguardhome")
	uci:commit("adguardhome")
end

function m.on_after_apply(self,map)
	sys.call('/etc/init.d/adguardhome reload')
end

return m
