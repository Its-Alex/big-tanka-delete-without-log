local data = import 'main.libsonnet';

{
  environment(cluster):: {
    apiVersion: 'tanka.dev/v1alpha1',
    kind: 'Environment',
    metadata: {
      name: 'environment/%s' % cluster.name,
    },
    spec: {
      injectLabels: true,
      contextNames: cluster.contextNames,
      namespace: 'default',
    },
    data: data,
  },

  clusters:: [
    { name: 'kind-local', contextNames: ['kind-local'] },
  ],

  envs: {
    [cluster.name]: $.environment(cluster)
    for cluster in $.clusters
  },
}
