-- Copyright 2023 Bruce Chen <a805899926@gmail.com>
-- Licensed to the public under the Apache License 2.0.

local fs = require("nixio.fs")

local m = Map("adguardhome")
m.redirect = luci.dispatcher.build_url("admin", "services", "adguardhome")
m.apply_on_parse = true

s = m:section( NamedSection, arg[1], translate("DnsProxy instances"), "")
s:tab("general", translate("General Settings"));
s:tab('logview',translate('Log File Viewer'));

-- General Setting
enabled = s:taboption("general", Flag, "enabled", translate("Enabled"))
debug = s:taboption("general", Flag, "debug", translate("Enable debug logging"))

port = s:taboption("general", Value, "port", translate("Port"), translate("Port to serve HTTP pages on"))
port.datatype = "port"
port.rmempty = false

-- Log View
logview = s:taboption('logview', TextValue, '_logview')
logview.readonly = true
logview.rows = 30
function logview.cfgvalue(self, section)
	if nixio.fs.access("/var/log/adguardhome.%s.log" % section) then
		local logs = luci.util.execi("cat /var/log/adguardhome.%s.log" % section)
		local s = ""
		for line in logs do
			s = s .. "\n" .. line
		end
		return s
	end
end
function logview.write(self, section, value)

end

return m