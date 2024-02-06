{{/*
Rotor selector labels
*/}}
{{- define "jitsu.syncctl.selectorLabels" -}}
app.kubernetes.io/component: syncctl
{{- end }}

{{- define "jitsu.syncctl.env" -}}
{{- with .Values.syncctl.config -}}
- name: SYNCCTL_DATABASE_URL
  value: {{ .databaseUrl | default (include "jitsu.databaseUrl" $) | quote }}
{{- if and (not .authTokens) $.Values.config.autoGenerateTokens }}
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
{{- if and (not .tokenSecret) $.Values.config.autoGenerateTokens }}
- name: SYNCCTL_TOKEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: syncctlTokenSecret
{{- end }}
{{- with .tokenSecret }}
- name: SYNCCTL_TOKEN_SECRET
  value: {{ . | quote }}
{{- end }}
{{- with .rawAuthTokens }}
- name: SYNCCTL_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- with .sidecarDatabaseUrl }}
- name: SYNCCTL_SIDECAR_DATABASE_URL
  value: {{ . | quote }}
{{- end }}
{{- if and (not .bulkerUrl) (not $.Values.config.bulkerUrl) $.Values.bulker.enabled }}
- name: SYNCCTL_BULKER_URL
  value: {{ printf "http://%s-bulker:%d" (include "jitsu.fullname" $) (int $.Values.bulker.service.port) | quote }}
{{- end }}
{{- with (.bulkerUrl | default $.Values.config.bulkerUrl) }}
- name: SYNCCTL_BULKER_URL
  value: {{ . | quote }}
{{- end }}
{{- if and (not .bulkerAuthKey) $.Values.bulker.enabled $.Values.config.autoGenerateTokens }}
- name: SYNCCTL_BULKER_AUTH_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerAuthToken
{{- end }}
{{- with .bulkerAuthKey }}
- name: SYNCCTL_BULKER_AUTH_KEY
  value: {{ . | quote }}
{{- end }}
{{- with .kubernetesClientConfig }}
- name: SYNCCTL_KUBERNETES_CLIENT_CONFIG
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toYaml . | quote }}
  {{- end }}
{{- end }}
{{- with .kubernetesContext }}
- name: SYNCCTL_KUBERNETES_CONTEXT
  value: {{ . | quote }}
{{- end }}
{{- if not .kubernetesNamespace }}
- name: SYNCCTL_KUBERNETES_NAMESPACE
  value: "{{ $.Release.Namespace }}"
{{- end }}
{{- with .kubernetesNamespace }}
- name: SYNCCTL_KUBERNETES_NAMESPACE
  value: {{ . | quote }}
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
