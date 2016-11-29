local kpm = import "kpm.libjsonnet";

function(
  params={}
)

kpm.package({
  package: {
    name: "stackanetes/horizon",
    expander: "jinja2",
    author: "Quentin Machu",
    version: "0.1.0",
    description: "horizon",
    license: "Apache 2.0",
  },

  variables: {
    deployment: {
      control_node_label: "openstack-control-plane",
      control_replicas: 1,

      image: {
        base: "quay.io/stackanetes/stackanetes-%s:barcelona",
        horizon: $.variables.deployment.image.base % "horizon",
      },
    },

    network: {
      external_ips: [],
      port: 8080,

      ingress: {
        enabled: true,
        host: "%s.openstack.cluster",
        port: 30080,

        named_host: $.variables.network.ingress.host % "horizon",
      },
    },

    keystone: {
      auth_uri: "http://keystone-api:5000",
    },

    memcached: {
      address: "memcached:11211",
    },

    misc: {
      debug: true,
    },
  },

  resources: [
    // Config maps.
    {
      file: "configmaps/start.sh.yaml.j2",
      template: (importstr "templates/configmaps/start.sh.yaml.j2"),
      name: "horizon-startsh",
      type: "configmap",
    },

    {
      file: "configmaps/horizon.conf.yaml.j2",
      template: (importstr "templates/configmaps/horizon.conf.yaml.j2"),
      name: "horizon-horizonconf",
      type: "configmap",
    },

    {
      file: "configmaps/local_settings.yaml.j2",
      template: (importstr "templates/configmaps/local_settings.yaml.j2"),
      name: "horizon-localsettings",
      type: "configmap",
    },

    // Deployments.
    {
      file: "deployment.yaml.j2",
      template: (importstr "templates/deployment.yaml.j2"),
      name: "horizon",
      type: "deployment",
    },

    // Services.
    {
      file: "service.yaml.j2",
      template: (importstr "templates/service.yaml.j2"),
      name: "horizon",
      type: "service",
    },

    // Ingresses.
    if $.variables.network.ingress.enabled == true then
      {
        file: "ingress.yaml.j2",
        template: (importstr "templates/ingress.yaml.j2"),
        name: "horizon",
        type: "ingress",
      },
  ],

  deploy: [
    {
      name: "$self",
    },
  ]
}, params)
