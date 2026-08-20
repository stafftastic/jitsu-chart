{{/*
Operator selector labels
*/}}
{{- define "jitsu.operator.selectorLabels" -}}
app.kubernetes.io/component: operator
{{- end }}

{{- define "jitsu.operator.serviceAccountName" -}}
{{- if .Values.operator.serviceAccount.create }}
{{- default (printf "%s-operator" (include "jitsu.fullname" .)) .Values.operator.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.operator.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "jitsu.operator.env" -}}
{{- with .Values.operator.config -}}
{{- if or .databaseUrlFrom $.Values.config.databaseUrlFrom }}
- name: OPERATOR_DATABASE_URL
  valueFrom:
    {{- toYaml (.databaseUrlFrom | default $.Values.config.databaseUrlFrom) | nindent 4 }}
{{- else }}
- name: OPERATOR_DATABASE_URL
  value: {{ .databaseUrl | default (include "jitsu.databaseUrl" $) | quote }}
{{- end }}

{{- if and (not .repositoryBaseUrl) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: OPERATOR_REPOSITORY_BASE_URL
  value: {{ printf "http://%s-console:%d/api/admin/export"
    (include "jitsu.fullname" $)
    (int $.Values.console.service.port)
  | quote }}
{{- end }}
{{- with .repositoryBaseUrl }}
- name: OPERATOR_REPOSITORY_BASE_URL
  value: {{ . | quote }}
{{- end }}

{{- if .repositoryAuthTokenFrom }}
- name: OPERATOR_REPOSITORY_AUTH_TOKEN
  valueFrom:
    {{- toYaml .repositoryAuthTokenFrom | nindent 4 }}
{{- else }}
{{- if and (not .repositoryAuthToken) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: OPERATOR_REPOSITORY_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleAuthToken
{{- end }}
{{- with .repositoryAuthToken }}
- name: OPERATOR_REPOSITORY_AUTH_TOKEN
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .repositoryRefreshPeriodSec }}
- name: OPERATOR_REPOSITORY_REFRESH_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}

{{- if or .mongodbUrlFrom $.Values.config.mongodbUrlFrom }}
- name: OPERATOR_MONGODB_URL
  valueFrom:
    {{- toYaml (.mongodbUrlFrom | default $.Values.config.mongodbUrlFrom) | nindent 4 }}
{{- else }}
{{- with (.mongodbUrl | default (include "jitsu.mongodbUrl" $)) }}
- name: OPERATOR_MONGODB_URL
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .kubernetesClientConfigFrom }}
- name: OPERATOR_KUBERNETES_CLIENT_CONFIG
  valueFrom:
    {{- toYaml .kubernetesClientConfigFrom | nindent 4 }}
{{- else }}
{{- with .kubernetesClientConfig }}
- name: OPERATOR_KUBERNETES_CLIENT_CONFIG
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toYaml . | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- with .kubernetesContext }}
- name: OPERATOR_KUBERNETES_CONTEXT
  value: {{ . | quote }}
{{- end }}

{{- if .kubernetesNamespaceFrom }}
- name: OPERATOR_KUBERNETES_NAMESPACE
  valueFrom:
    {{- toYaml .kubernetesNamespaceFrom | nindent 4 }}
{{- else }}
{{- if not .kubernetesNamespace }}
- name: OPERATOR_KUBERNETES_NAMESPACE
  value: "{{ $.Release.Namespace }}"
{{- end }}
{{- with .kubernetesNamespace }}
- name: OPERATOR_KUBERNETES_NAMESPACE
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .kubernetesNodeSelector }}
- name: OPERATOR_KUBERNETES_NODE_SELECTOR
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}

{{- with .podsServiceAccount }}
- name: OPERATOR_PODS_SERVICE_ACCOUNT
  value: {{ . | quote }}
{{- end }}

{{- with .podsTolerations }}
- name: OPERATOR_PODS_TOLERATIONS
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}

{{- with .podsResources }}
- name: OPERATOR_PODS_RESOURCES
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}

{{- with .podsResourcesPremium }}
- name: OPERATOR_PODS_RESOURCES_PREMIUM
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}

{{- with .podsResourcesFree }}
- name: OPERATOR_PODS_RESOURCES_FREE
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}

{{- with .podsTopologySpreadConstraints }}
- name: OPERATOR_PODS_TOPOLOGY_SPREAD_CONSTRAINTS
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}

- name: OPERATOR_FUNCTIONS_SERVER_IMAGE
  value: {{ .functionsServerImage | default (printf "jitsucom/functions-server:%s" ($.Values.operator.image.tag | default $.Chart.AppVersion)) | quote }}

{{- with .functionsServerPort }}
- name: OPERATOR_FUNCTIONS_SERVER_PORT
  value: {{ . | quote }}
{{- end }}

{{- with .serviceType }}
- name: OPERATOR_SERVICE_TYPE
  value: {{ . | quote }}
{{- end }}

{{- with .defaultFunctionsClass }}
- name: OPERATOR_DEFAULT_FUNCTIONS_CLASS
  value: {{ . | quote }}
{{- end }}

{{- with .minReplicas }}
- name: OPERATOR_MIN_REPLICAS
  value: {{ . | quote }}
{{- end }}

{{- with .minReplicasPremium }}
- name: OPERATOR_MIN_REPLICAS_PREMIUM
  value: {{ . | quote }}
{{- end }}

{{- with .minReplicasFree }}
- name: OPERATOR_MIN_REPLICAS_FREE
  value: {{ . | quote }}
{{- end }}

{{- with .freeShards }}
- name: OPERATOR_FREE_SHARDS
  value: {{ . | quote }}
{{- end }}

{{- with .hpaEnabled }}
- name: OPERATOR_HPA_ENABLED
  value: {{ . | quote }}
{{- end }}

{{- with .hpaMaxReplicas }}
- name: OPERATOR_HPA_MAX_REPLICAS
  value: {{ . | quote }}
{{- end }}

{{- with .hpaTargetCpuUtilization }}
- name: OPERATOR_HPA_TARGET_CPU_UTILIZATION
  value: {{ . | quote }}
{{- end }}

{{- with .mongobetweenImage }}
- name: OPERATOR_MONGOBETWEEN_IMAGE
  value: {{ . | quote }}
{{- end }}

{{- with .logFormat }}
- name: OPERATOR_LOG_FORMAT
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
