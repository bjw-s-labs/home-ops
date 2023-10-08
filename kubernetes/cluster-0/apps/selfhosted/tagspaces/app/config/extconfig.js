window.ExtCheckForUpdatesOnStartup = false
window.ExtDefaultPerspective = "list"
window.ExtIsFirstRun = false
window.ExtLocations = [
  {
    uuid: "10565f09-c7fd-2333-fc67-a75db27rt5ba", // a unique id of the location
    type: "1", // 1 defines the locations a cloud based
    name: "3D Assets",
    path: "3d_assets",
    accessKeyId: "tagspaces",
    secretAccessKey: "{{ .minio_tagspaces_secret_key }}",
    bucketName: "tagspaces",
    region: "eu-central-1",
    endpointURL: "https://s3.bjw-s.dev",
    isNotEditable: true, // disable the opening of the location properties and export
  },
]
window.ExtSaveLocationsInBrowser = false
window.ExtShowWelcomePanel = false
window.ExtUseSidecarsForFileTagging = true
