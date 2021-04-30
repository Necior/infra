{
    local app = self,

    deployment: {
        apiVersion: "apps/v1",
        kind: "Deployment",
        metadata: {
            name: "httpbin-deployment",
        },
        spec: {
            selector: {
                matchLabels: {
                    app: "httpbin"
                }
            },
            replicas: 1,
            template: {
                metadata: {
                    labels: {
                        "app": "httpbin"
                    },
                },
                spec: {
                    containers: [
                        {
                            name: "httpbin",
                            image: "kennethreitz/httpbin",
                            ports: [
                                {
                                    containerPort: 80,
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
            name: "httpbin-service",
        },
        spec: {
            selector: {
                app: "httpbin",
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
