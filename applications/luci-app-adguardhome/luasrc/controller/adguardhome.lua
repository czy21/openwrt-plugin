-- Copyright 2023 Bruce Chen <a805899926@gmail.com>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.adguardhome", package.seeall)

function index()
	entry( {"admin", "services", "adguardhome"}, cbi("adguardhome"), _("AdguardHome") ).acl_depends = { "luci-app-adguardhome" }
	entry( {"admin", "services", "adguardhome", "edit"},    cbi("adguardhome-edit"),    nil ).leaf = true
end
