-- Copyright 2023 Bruce Chen <a805899926@gmail.com>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.dnsproxy", package.seeall)

function index()
	entry( {"admin", "services", "dnsproxy"}, cbi("dnsproxy"), _("DnsProxy") ).acl_depends = { "luci-app-dnsproxy" }
	entry( {"admin", "services", "dnsproxy", "edit"},    cbi("dnsproxy-edit"),    nil ).leaf = true
end
