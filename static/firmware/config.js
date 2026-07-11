/* exported config */

var config = {
  // Show help text for images
  show_help: true,

  // Image download URL (e.g. "https://downloads.openwrt.org")
  image_url: "https://openwrt-download.czy21.com",

  // Insert snapshot versions (optional)
  show_snapshots: false,

  // Info link URL (optional)
  info_url: "https://openwrt.org/start?do=search&id=toh&q={title} @toh",

  // Attended Sysupgrade Server support (optional)
  asu_url: "https://openwrt-asu.czy21.com",
  asu_extra_packages: [],
  asu_repositories_mode: "append",
  asu_repositories: {
    "openwrt_plugin": "https://openwrt-download.czy21.com/{package_rel}/{arch_packages}/plugin",
  },
  asu_repository_keys: [
    "RWSYv7CuMTatNjIKHxlsAiKEvMYwGsJtdFv26IOGFGJZQWa9B5U0Sbc/",
    "-----BEGIN PUBLIC KEY-----\nMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEb+QuIKFsXXV5Dg595V90FnZ8A/h7\ns58gie9uH0DZWt8JtEhsHh7x/u8+ZFjs5gR0RdR36feHvfVi+f1AQ3fPHA==\n-----END PUBLIC KEY-----"
  ],
  repository_mirrors: [
    "https://downloads.openwrt.org",
    "https://mirrors.ustc.edu.cn/openwrt"
  ]
};