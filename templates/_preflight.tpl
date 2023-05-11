{{- define "preflight.spec" }}
apiVersion: troubleshoot.sh/v1beta2
kind: Preflight
metadata:
  name: preflight-sample
spec:
  {{ if eq .Values.global.mariadb.enabled false }}
  collectors:
      - mysql:
        collectorName: mysql
        uri: '{{ .Values.global.externalDatabase.user }}:{{ .Values.global.externalDatabase.password }}@tcp({{ .Values.global.externalDatabase.host }}:{{ .Values.global.externalDatabase.port }})/{{ .Values.global.externalDatabase.database }}?tls=false'
  {{ end }}
  analyzers:
    - nodeResources:
        checkName: Node Count Check
        outcomes:
          - fail:
              when: 'count() > {{ .Values.global.maxNodeCount }}'
              message: "The cluster has more than {{ .Values.global.maxNodeCount }} nodes."
          - pass:
              message: You have the correct number of nodes.
    - clusterVersion:
        outcomes:
          - fail:
              when: "< 1.16.0"
              message: The application requires at least Kubernetes 1.16.0, and recommends 1.18.0.
              uri: https://kubernetes.io
          - warn:
              when: "< 1.18.0"
              message: Your cluster meets the minimum version of Kubernetes, but we recommend you update to 1.18.0 or later.
              uri: https://kubernetes.io
          - pass:
              message: Your cluster meets the recommended and required versions of Kubernetes.
    {{ if eq .Values.global.mariadb.enabled false }}
    - mysql:
        checkName: Must be MySQL 8.x or later
        collectorName: mysql
        outcomes:
          - fail:
              when: connected == false
              message: Cannot connect to MySQL server
          - fail:
              when: version < 8.x
              message: The MySQL server must be at least version 8
          - pass:
              message: The MySQL server is ready
    {{ end }}
{{- end }}