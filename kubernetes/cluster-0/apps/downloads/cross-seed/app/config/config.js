module.exports = {
  delay: 20,
  qbittorrentUrl: "http://qbittorrent.downloads.svc.cluster.local:8080",
  // prowlarrUrl: "http://prowlarr.downloads.svc.cluster.local:9696",
  // prowlarrApiKey: "{{ .prowlarr_api_key }}",
  // prowlarrTag: "cross-seed",
  torznab: [
    "http://prowlarr.downloads.svc.cluster.local:9696/5/api?apikey={{ .prowlarr_api_key }}", // btn
    "http://prowlarr.downloads.svc.cluster.local:9696/6/api?apikey={{ .prowlarr_api_key }}", // bhd
    "http://prowlarr.downloads.svc.cluster.local:9696/13/api?apikey={{ .prowlarr_api_key }}", // blu
    "http://prowlarr.downloads.svc.cluster.local:9696/15/api?apikey={{ .prowlarr_api_key }}", // ant
    "http://prowlarr.downloads.svc.cluster.local:9696/12/api?apikey={{ .prowlarr_api_key }}", // fl
    "http://prowlarr.downloads.svc.cluster.local:9696/14/api?apikey={{ .prowlarr_api_key }}", // ipt
    "http://prowlarr.downloads.svc.cluster.local:9696/9/api?apikey={{ .prowlarr_api_key }}", // ex
    "http://prowlarr.downloads.svc.cluster.local:9696/16/api?apikey={{ .prowlarr_api_key }}", // phd
  ],
  action: "inject",
  includeEpisodes: true,
  includeNonVideos: true,
  duplicateCategories: true,
  matchMode: "safe",
  skipRecheck: true,
  linkType: "hardlink",
  linkDir: "/data/nas-media/Downloads/qbittorrent/complete/cross-seed",
  dataDirs: [
    "/data/nas-media/Downloads/qbittorrent/complete/radarr",
    "/data/nas-media/Downloads/qbittorrent/complete/sonarr",
  ],
  outputDir: "/config/xseeds",
  torrentDir: "/config/qBittorrent/BT_backup",
  searchCadence: "1 week",
  excludeRecentSearch: "26 weeks",
}
