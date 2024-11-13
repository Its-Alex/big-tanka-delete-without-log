# Tanka bug with hivemq-operator

This repository is used to reproduce a `tanka` bug.

## Requirements

- [mise](https://mise.jdx.dev/)

To manage tooling install and versions I use [mise](https://mise.jdx.dev/)
if you want to install tools manually, you can see them with their versions in
[.mise.toml](./.mise.toml), or if you want to use mise:

```sh-session
$ mise install
```

Afterwards you need to pull and install tanka requirements using the following
commands:

```sh-session
$ jb install
$ tk tool charts vendor
```

You're ready to reproduce the bug.

## How to reproduce

First you need to deploy hivemq-operator into a kind cluster:

```sh-session
$ ./scripts/kind-up.sh
$ tk apply \
    -t 'CustomResourceDefinition/.+' \
    --auto-approve always \
    --name kind-local \
    environments/dev
...
customresourcedefinition.apiextensions.k8s.io/hivemq-clusters.hivemq.com created
$ tk apply \
    --auto-approve always \
    --name kind-local \
    environments/dev
...
deployment.apps/hivemq-operator-operator created
hivemqcluster.hivemq.com/hivemq-operator created
```

Now if you try to uninstall hivemq-operator you will get an error with no log:

```sh-session
$ tk delete --name kind-local environments/dev
...
Deleting from namespace 'default' of cluster 'kind-local' at 'https://127.0.0.1:6443' using context 'kind-local'.
Please type 'yes' to confirm: yes
Error: exit status 1
```

Even when using `--log-level trace`:

```sh-session
$ tk delete --log-level trace --name kind-local environments/dev
...
Deleting from namespace 'default' of cluster 'kind-local' at 'https://127.0.0.1:6443' using context 'kind-local'.
Please type 'yes' to confirm: yes
Error: exit status 1
```
