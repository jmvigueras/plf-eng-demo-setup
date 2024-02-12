name: Main CI 
on:
  push:
   branches: [ master ]
  pull_request:
   branches: [ master ]
 
jobs:  
  kubescape:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: kubescape/github-action@main
        continue-on-error: true
        with:
          format: sarif
          outputFile: results.sarif
          files: "manifest/*.yaml"

${deploy_k8s}