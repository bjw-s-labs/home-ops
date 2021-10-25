---
hide:
  - toc
---
# Welcome

{% import 'links.jinja2' as links %}

Welcome to the documentation for my {{ links.repoUrl('home-ops') }} repo.

This repository _is_ my home Kubernetes cluster in a declarative state. {{ links.external('flux', 'Flux') }} watches my {{ links.repoUrl('cluster', 'tree/main/cluster') }} folder and makes the changes to my cluster based on the YAML manifests.

Feel free to open a {{ links.repoUrl('GitHub issue', 'issues/new/choose') }} or join the {{ links.external('kah_discord') }} if you have any questions.

## Thanks

A lot of inspiration for my cluster came from the people that have shared their clusters over at the {{ links.external('kah_repo_awesome') }} repository.
