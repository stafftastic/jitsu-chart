{{/*
Rotor selector labels
*/}}
{{- define "jitsu.syncctl.selectorLabels" -}}
app.kubernetes.io/component: syncctl
{{- end }}

{{- define "jitsu.syncctl.serviceAccountName" -}}
{{- if .Values.syncctl.serviceAccount.create }}
{{- default (printf "%s-syncctl" (include "jitsu.fullname" .)) .Values.syncctl.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.syncctl.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "jitsu.syncctl.env" -}}
{{- with .Values.syncctl.config -}}
{{- if or .databaseUrlFrom $.Values.config.databaseUrlFrom }}
- name: SYNCCTL_DATABASE_URL
  valueFrom:
    {{- toYaml (.databaseUrlFrom | default $.Values.config.databaseUrlFrom) | nindent 4 }}
{{- else }}
- name: SYNCCTL_DATABASE_URL
  value: {{ .databaseUrl | default (include "jitsu.databaseUrl" $ | replace "schema=" "search_path=") | quote }}
{{- end }}

{{- if .authTokensFrom }}
- name: SYNCCTL_AUTH_TOKENS
  valueFrom:
    {{- toYaml .authTokensFrom | nindent 4 }}
{{- else }}
{{- if and (not .authTokens) $.Values.tokenGenerator.enabled }}
- name: SYNCCTL_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: syncctlAuthTokens
{{- end }}
{{- with .authTokens }}
- name: SYNCCTL_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .tokenSecretFrom }}
- name: SYNCCTL_TOKEN_SECRET
  valueFrom:
    {{- toYaml .tokenSecretFrom | nindent 4 }}
{{- else }}
{{- if and (not .tokenSecret) $.Values.tokenGenerator.enabled }}
- name: SYNCCTL_TOKEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: globalHashSecret
{{- end }}
{{- with .tokenSecret }}
- name: SYNCCTL_TOKEN_SECRET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .rawAuthTokensFrom }}
- name: SYNCCTL_RAW_AUTH_TOKENS
  valueFrom:
    {{- toYaml .rawAuthTokensFrom | nindent 4 }}
{{- else }}
{{- with .rawAuthTokens }}
- name: SYNCCTL_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .sidecarDatabaseUrlFrom }}
- name: SYNCCTL_SIDECAR_DATABASE_URL
  valueFrom:
    {{- toYaml .sidecarDatabaseUrlFrom | nindent 4 }}
{{- else }}
{{- with .sidecarDatabaseUrl }}
- name: SYNCCTL_SIDECAR_DATABASE_URL
  value: {{ . | quote }}
{{- end }}
{{- end }}

- name: SYNCCTL_SIDECAR_IMAGE
  value: {{ .sidecarImage | default (printf "jitsucom/sidecar:%s" $.Chart.AppVersion) | quote }}

{{- if and (not .bulkerUrl) (not $.Values.config.bulkerUrl) $.Values.bulker.enabled }}
- name: SYNCCTL_BULKER_URL
  value: {{ printf "http://%s-bulker:%d" (include "jitsu.fullname" $) (int $.Values.bulker.service.port) | quote }}
{{- end }}
{{- with (.bulkerUrl | default $.Values.config.bulkerUrl) }}
- name: SYNCCTL_BULKER_URL
  value: {{ . | quote }}
{{- end }}

{{- if .bulkerAuthTokenFrom }}
- name: SYNCCTL_BULKER_AUTH_TOKEN
  valueFrom:
    {{- toYaml .bulkerAuthTokenFrom | nindent 4 }}
{{- else }}
{{- if and (not .bulkerAuthToken ) $.Values.bulker.enabled $.Values.tokenGenerator.enabled }}
- name: SYNCCTL_BULKER_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerAuthToken
{{- end }}
{{- with .bulkerAuthToken }}
- name: SYNCCTL_BULKER_AUTH_TOKEN
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .kubernetesClientConfigFrom }}
- name: SYNCCTL_KUBERNETES_CLIENT_CONFIG
  valueFrom:
    {{- toYaml .kubernetesClientConfigFrom | nindent 4 }}
{{- else }}
{{- with .kubernetesClientConfig }}
- name: SYNCCTL_KUBERNETES_CLIENT_CONFIG
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toYaml . | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- if .kubernetesContextFrom }}
- name: SYNCCTL_KUBERNETES_CONTEXT
  valueFrom:
    {{- toYaml .kubernetesContextFrom | nindent 4 }}
{{- else }}
{{- with .kubernetesContext }}
- name: SYNCCTL_KUBERNETES_CONTEXT
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .kubernetesNamespaceFrom }}
- name: SYNCCTL_KUBERNETES_NAMESPACE
  valueFrom:
    {{- toYaml .kubernetesNamespaceFrom | nindent 4 }}
{{- else }}
{{- if not .kubernetesNamespace }}
- name: SYNCCTL_KUBERNETES_NAMESPACE
  value: "{{ $.Release.Namespace }}"
{{- end }}
{{- with .kubernetesNamespace }}
- name: SYNCCTL_KUBERNETES_NAMESPACE
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .taskTimeoutHours }}
- name: SYNCCTL_TASK_TIMEOUT_HOURS
  value: {{ . | quote }}
{{- end }}

{{- with .logFormat }}
- name: SYNCCTL_LOG_FORMAT
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
