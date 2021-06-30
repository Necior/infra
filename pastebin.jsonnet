{
    local app = self,
    local replicas = 1,

    deployment: {
        apiVersion: "apps/v1",
        kind: "Deployment",
        metadata: {
            name: "pastebin-deployment",
        },
        spec: {
            selector: {
                matchLabels: {
                    app: "pastebin"
                }
            },
            replicas: replicas,
            template: {
                metadata: {
                    labels: {
                        "app": "pastebin"
                    },
                },
                spec: {
                    containers: [
                        {
                            name: "pastebin",
                            image: "necior/pastebin:0.1.0",
                            ports: [
                                {
                                    containerPort: 2137,
                                },
                            ],
                        },
                    ],
                },
            },
        },
    },

    service: {
        apiVersion: "v1",
        kind: "Service",
        metadata: {
            name: "pastebin-service",
        },
        spec: {
            selector: {
                app: "pastebin",
            },
            ports: [
                {
                    protocol: "TCP",
                    port: 80,
                    targetPort: app.deployment.spec.template.spec.containers[0].ports[0].containerPort
                },
            ],
        },
    },
}
