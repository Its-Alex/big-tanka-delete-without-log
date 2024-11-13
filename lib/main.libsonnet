local tanka = import 'github.com/grafana/jsonnet-libs/tanka-util/main.libsonnet';
local helm = tanka.helm.new(std.thisFile);

local hivemq_operator_manifests = helm.template('hivemq-operator', '../charts/hivemq-operator', {
  values: {
    global: {
      rbac: {
        pspEnabled: false,
      },
    },
    operator: {
      admissionWebhooks: {
        enabled: false,
        patch: {
          image: {
            tag: 'v1.5.1',
          },
        },
      },
      resources: {
        limits: {
          cpu: '5',
          memory: '1024M',
        },
        requests: {
          cpu: '200m',
          memory: '512M',
        },
      },
    },
    monitoring: {
      enabled: false,
    },
    hivemq: {
      nodeCount: 1,
      cpu: '500m',
      memory: '2Gi',
      cpuLimitRatio: '6',
      memoryLimitRatio: '1',
      ephemeralStorage: '15Gi',
      ephemeralStorageLimitRatio: '1',
      env: [{
        name: 'MALLOC_ARENA_MAX',
        value: '2',
      }],
      // Open ports with nodeport
      ports: [
        {
          name: 'mqtt',
          port: 1883,
          expose: true,
          patch: [
            '[{"op":"add","path":"/spec/selector/hivemq.com~1node-offline","value":"false"},{"op":"add","path":"/metadata/annotations","value":{"service.spec.externalTrafficPolicy":"Local"}}]',
            '[{"op":"add","path":"/spec/type","value":"NodePort"}]',
            '[{"op":"add","path":"/spec/ports/0/nodePort","value":31883}]',
          ],
        },
        {
          name: 'cc',
          port: 8080,
          expose: true,
          patch: [
            '[{"op":"add","path":"/spec/sessionAffinity","value":"ClientIP"}]',
          ],
        },
      ],
      mqtt: {
        messageExpiryMaxInterval: 120,
        sessionExpiryInterval: 120,
      },
    },
  },
});

{
  // Used to remove helm hook test from output
  hivemq_operator_manifests_filtered: {
    [key]: hivemq_operator_manifests[key]
    for key in std.objectFields(hivemq_operator_manifests)
    if !(std.objectHas(hivemq_operator_manifests[key], 'metadata') &&
         std.objectHas(hivemq_operator_manifests[key].metadata, 'annotations') &&
         std.objectHas(hivemq_operator_manifests[key].metadata.annotations, 'helm.sh/hook') &&
         hivemq_operator_manifests[key].metadata.annotations['helm.sh/hook'] == 'test')
  }
}
