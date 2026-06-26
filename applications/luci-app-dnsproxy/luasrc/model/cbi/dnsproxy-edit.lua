-- Copyright 2023 Bruce Chen <a805899926@gmail.com>
-- Licensed to the public under the Apache License 2.0.

local fs = require("nixio.fs")

local m = Map("dnsproxy")
m.redirect = luci.dispatcher.build_url("admin", "services", "dnsproxy")
m.apply_on_parse = true

s = m:section( NamedSection, arg[1], translate("DnsProxy instances"), "")
s:tab("general", translate("General Settings"));
s:tab("encrypt", translate('Encrypt Settings'));
s:tab('logview',translate('Log File Viewer'));

-- General Setting
enabled = s:taboption("general", Flag, "enabled", translate("Enabled"))
debug = s:taboption("general", Flag, "debug", translate("Enable debug logging"))

listen = s:taboption("general", DynamicList, "listen", translate("Listen"), translate("Listening addresses (default: 0.0.0.0)"))
listen.datatype = "ipaddr"

port = s:taboption("general", DynamicList, "port", translate("Port"), translate("Listening ports. Zero value disables TCP and UDP listeners (default: 0.0.0.0:53)"))
port.datatype = "port"

bootstrap = s:taboption("general", DynamicList ,"bootstrap", translate("Bootstrap"), translate("Bootstrap DNS for DoH and DoT (default: 8.8.8.8:53)"))
upstream = s:taboption("general", DynamicList ,"upstream", translate("Upstream"), translate("Upstream DNS. Here is a <a href=\"https://link.adtidy.org/forward.html?action=dns_kb_providers&from=ui&app=home\" target=\"_blank\">list of known DNS providers</a> to choose from"))
fallback = s:taboption("general", DynamicList ,"fallback", translate("Fallback"), translate("Fallback resolvers to use when regular ones are unavailable"))
private_rdns_upstream = s:taboption("general", DynamicList ,"private_rdns_upstream", translate("Private DNS upstream"), translate("Private DNS upstreams to use for reverse DNS lookups of private addresses"))
all_servers = s:taboption("general", Flag, "all_servers", translate("Parallel queries"),translate("Parallel queries to all configured upstream servers"))
fastest_addr = s:taboption("general", Flag, "fastest_addr", translate("Fastest IP address"),translate("Respond to A or AAAA requests only with the fastest IP address"))
timeout = s:taboption("general", Value, "timeout", translate("Timeout"),translate("Timeout for outbound DNS queries to remote upstream servers in a human-readable form (default: 10s)"))
timeout.datatype = "uinteger"
ratelimit = s:taboption("general", Value, "ratelimit", translate("Ratelimit"),translate("Ratelimit (requests per second)"))
ratelimit.datatype = "uinteger"
refuse_any = s:taboption("general", Flag, "refuse_any", translate("Refuse Any"),translate("If specified, refuse ANY requests"))
edns = s:taboption("general", Flag, "edns", translate("EDNS"),translate("Use EDNS Client Subnet extension"))
edns_addr = s:taboption("general", Value, "edns_addr", translate("EDNS client address"),translate("Send EDNS Client Address"))
edns_addr:depends("edns", 1)
dns64 = s:taboption("general", Flag, "dns64", translate("DNS64"),translate("If specified, dnsproxy will act as a DNS64 server"))
dns64_prefix = s:taboption("general", DynamicList, "dns64_prefix", translate("DNS64 prefix"),translate("Prefix used to handle DNS64. If not specified, dnsproxy uses the 'Well-Known Prefix' 64:ff9b::"))
dns64_prefix:depends("dns64", 1)
ipv6_disabled = s:taboption("general", Flag, "ipv6_disabled", translate("IPv6 disabled"),translate("If specified, all AAAA requests will be replied with NoError RCode and empty answer"))
bogus_nxdomain = s:taboption("general", DynamicList, "bogus_nxdomain", translate("Bogus nxdomain"),translate("Transform the responses containing at least a single IP that matches specified addresses and CIDRs into NXDOMAIN"))
udp_buf_size = s:taboption("general", Value, "udp_buf_size", translate("UDP buf size"),translate("Set the size of the UDP buffer in bytes. A value <= 0 will use the system default"))
udp_buf_size.datatype = "integer"
max_go_routines = s:taboption("general", Value, "max_go_routines", translate("Max go routines"),translate("Set the maximum number of go routines. A value <= 0 will not not set a maximum"))
udp_buf_size.datatype = "integer"
cache = s:taboption("general", Flag, "cache", translate("Cache"),translate("If specified, DNS cache is enabled"))
cache_size = s:taboption("general", Value, "cache_size", translate("Cache size"),translate("Cache size (in bytes). Default: 64k"))
cache_size.datatype = "uinteger"
cache_size.placeholder = "64"
cache_size:depends("cache", 1)
cache_min_ttl = s:taboption("general", Value, "cache_min_ttl", translate("Minimum TTL"),translate("Minimum TTL value for DNS entries, in seconds. Capped at 3600"))
cache_min_ttl.datatype = "uinteger"
cache_min_ttl:depends("cache", 1)
cache_max_ttl = s:taboption("general", Value, "cache_max_ttl", translate("Maximum TTL"),translate("Maximum TTL value for DNS entries, in seconds"))
cache_max_ttl.datatype = "uinteger"
cache_max_ttl:depends("cache", 1)
cache_optimistic = s:taboption("general", Flag, "cache_optimistic", translate("Cache optimistic"),translate("If specified, optimistic DNS cache is enabled"))
cache_optimistic:depends("cache", 1)

-- Encrypt Setting
https_port = s:taboption("encrypt", Value, "https_port", translate("HTTPS Port"),translate("Listening ports for DNS-over-HTTPS"))
https_port.datatype = "port"
tls_port = s:taboption("encrypt", Value, "tls_port", translate("TLS Port"),translate("Listening ports for DNS-over-TLS"))
tls_port.datatype = "port"
tls_crt = s:taboption("encrypt", FileUpload, "tls_crt", translate("TLS certificate"),translate("Path to a file with the certificate chain"))
tls_key = s:taboption("encrypt", FileUpload, "tls_key", translate("TLS private key"),translate("Path to a file with the private key"))
tls_min_version = s:taboption("encrypt", Value, "tls_min_version", translate("Minimum TLS version"),translate("Minimum TLS version, for example 1.0"))
tls_min_version.datatype = "ufloat"
tls_max_version = s:taboption("encrypt", Value, "tls_max_version", translate("Maximum TLS version"),translate("Maximum TLS version, for example 1.3"))
tls_max_version.datatype = "ufloat"
quic_port = s:taboption("encrypt", Value, "quic_port", translate("QUIC Port"),translate("Listening ports for DNS-over-QUIC"))
quic_port.datatype = "port"
insecure = s:taboption("encrypt", Flag, "insecure", translate("Insecure"),translate("Disable secure TLS certificate validation"))
http3 = s:taboption("encrypt", Flag, "http3", translate("HTTP/3"),translate("Enable HTTP/3 support"))

-- Log View
logview = s:taboption('logview', TextValue, '_logview')
logview.readonly = true
logview.rows = 30
function logview.cfgvalue(self, section)
	if nixio.fs.access("/var/log/dnsproxy.%s.log" % section) then
		local logs = luci.util.execi("cat /var/log/dnsproxy.%s.log" % section)
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