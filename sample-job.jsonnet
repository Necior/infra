{
  job: {
    apiVersion: 'batch/v1',
    kind: 'Job',
    metadata: {
      name: 'sample-job',
    },
    spec: {
      ttlSecondsAfterFinished: 30,
      completions: 10,
      parallelism: 2,
      template: {
        metadata: {
          name: 'sample-job',
        },
        spec: {
          containers: [
            {
              name: 'sample-job',
              image: 'busybox',
              command: ['ls', '/'],
            },
          ],
          restartPolicy: 'OnFailure',
        },
      },
    },
  },
}
