{{- define "jitsu.dependency.selectorLabels" -}}
{{ include "jitsu.selectorLabels" .root }}
app.kubernetes.io/component: {{ .component }}
{{- end }}

{{- define "jitsu.dependency.secret" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ .name }}
  labels:
    {{- include "jitsu.labels" .root | nindent 4 }}
stringData:
  {{- toYaml .data | nindent 2 }}
{{- end }}

{{- define "jitsu.dependency.service" -}}
apiVersion: v1
kind: Service
metadata:
  name: {{ .name }}
  labels:
    {{- include "jitsu.labels" .root | nindent 4 }}
spec:
  type: ClusterIP
  ports:
    {{- range $name, $port := .ports }}
    - name: {{ $name }}
      port: {{ $port }}
      targetPort: {{ $name }}
      protocol: TCP
    {{- end }}
  selector:
    {{- include "jitsu.dependency.selectorLabels" . | nindent 4 }}
{{- end }}

{{/*
Single-replica StatefulSet shared by all dependencies. Expects a dict with:
root, name, component, values (the dependency's values), mountPath, container (rendered container
fields other than name, image, resources and volumeMounts) and optionally podSecurityContext.
*/}}
{{- define "jitsu.dependency.statefulset" -}}
{{- $root := .root }}
{{- $values := .values }}
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ .name }}
  labels:
    {{- include "jitsu.labels" $root | nindent 4 }}
spec:
  serviceName: {{ .name }}
  replicas: 1
  selector:
    matchLabels:
      {{- include "jitsu.dependency.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "jitsu.globalLabels" $root | nindent 8 }}
        {{- include "jitsu.dependency.selectorLabels" . | nindent 8 }}
      {{- with $root.Values.global.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
    spec:
      {{- with $root.Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      enableServiceLinks: false
      {{- with .podSecurityContext }}
      securityContext:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      containers:
        - name: {{ .component }}
          image: "{{ $values.image.repository }}:{{ $values.image.tag }}"
          imagePullPolicy: {{ $values.image.pullPolicy }}
          {{- .container | nindent 10 }}
          {{- with $values.resources }}
          resources:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          volumeMounts:
            - name: data
              mountPath: {{ .mountPath }}
      {{- with ($values.nodeSelector | default $root.Values.global.nodeSelector) }}
      nodeSelector:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with ($values.affinity | default $root.Values.global.affinity) }}
      affinity:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- with ($values.tolerations | default $root.Values.global.tolerations) }}
      tolerations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      {{- if not $values.persistence.enabled }}
      volumes:
        - name: data
          emptyDir: {}
      {{- end }}
  {{- if $values.persistence.enabled }}
  volumeClaimTemplates:
    - metadata:
        name: data
        labels:
          {{- include "jitsu.dependency.selectorLabels" . | nindent 10 }}
      spec:
        accessModes: ["ReadWriteOnce"]
        {{- with $values.persistence.storageClass }}
        storageClassName: {{ . | quote }}
        {{- end }}
        resources:
          requests:
            storage: {{ $values.persistence.size }}
  {{- end }}
{{- end }}
