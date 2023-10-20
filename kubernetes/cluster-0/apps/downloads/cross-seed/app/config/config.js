module.exports = {
  delay: 20,
  qbittorrentUrl: "http://qbittorrent.downloads.svc.cluster.local:8080",
  torznab: [
    "http://prowlarr.downloads.svc.cluster.local:9696/5/api?apikey={{ .prowlarr_api_key }}", // btn
    "http://prowlarr.downloads.svc.cluster.local:9696/6/api?apikey={{ .prowlarr_api_key }}", // bhd
    "http://prowlarr.downloads.svc.cluster.local:9696/13/api?apikey={{ .prowlarr_api_key }}", // blu
    "http://prowlarr.downloads.svc.cluster.local:9696/15/api?apikey={{ .prowlarr_api_key }}", // ant
    "http://prowlarr.downloads.svc.cluster.local:9696/18/api?apikey={{ .prowlarr_api_key }}", // fl
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
}
