module.exports = {
  branchPrefix: "renovate/",
  gitAuthor: "Renovate Bot <bot@renovateapp.com>",
  onboarding: false,
  platform: "github",
  includeForks: false,
  repositories: ["bjw-s/k8s-gitops"],
  requireConfig: true,
  username: "bjw-s-renovate",
  hostRules: [
    {
      matchHost: "docker.io",
      username: process.env.DOCKER_HUB_USER,
      password: process.env.DOCKER_HUB_PASSWORD,
    },
  ],
  packageRules: [],
};
