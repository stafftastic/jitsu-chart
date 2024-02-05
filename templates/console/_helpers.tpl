{{/*
Console selector labels
*/}}
{{- define "jitsu.console.selectorLabels" -}}
app.kubernetes.io/component: console
{{- end }}

{{- define "jitsu.console.env" -}}
{{- with .Values.console.config -}}
- name: JITSU_PUBLIC_URL
  value: {{ .jitsuPublicURL | quote }}
- name: DATABASE_URL
  value: {{ .databaseURL | default (include "jitsu.databaseURL" $) | quote }}
{{- if and (not .bulkerAuthKey) $.Values.bulker.enabled $.Values.config.autoGenerateTokens }}
- name: BULKER_AUTH_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleBulkerAuthKey
{{- else if .bulkerAuthKey }}
- name: BULKER_AUTH_KEY
  value: {{ .bulkerAuthKey | quote }}
{{- end }}
- name: ROTOR_URL
  value: {{ .rotorURL | default (printf "http://%s-bulker:%d" (include "jitsu.fullname" $) (int $.Values.bulker.service.port)) | quote }}
{{- if $.Values.syncctl.enabled }}
- name: SYNCS_ENABLED
  value: {{ .syncsEnabled | default true | quote }}
- name: SYNCCTL_URL
  value: {{ .syncctlURL | default (printf "http://%s-syncctl:%d" (include "jitsu.fullname" $) (int $.Values.syncctl.service.port)) | quote }}
{{- else }}
- name: SYNCS_ENABLED
  value: {{ .syncsEnabled | default false | quote }}
- name: SYNCCTL_URL
  value: {{ .syncctlURL | quote }}
{{- end }}
{{- if and (not .syncctlAuthKey) $.Values.syncctl.enabled $.Values.config.autoGenerateTokens }}
- name: SYNCCTL_AUTH_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleSyncctlAuthKey
{{- else if .syncctlAuthKey }}
- name: SYNCCTL_AUTH_KEY
  value: {{ .syncctlAuthKey | quote }}
{{- end }}
{{- if and (not .consoleAuthTokens) $.Values.config.autoGenerateTokens }}
- name: CONSOLE_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleAuthTokens
{{- else if .consoleAuthTokens }}
- name: CONSOLE_AUTH_TOKENS
  value: {{ .consoleAuthTokens | quote }}
{{- end }}
{{- if and (not .consoleGlobalHashSecret) $.Values.config.autoGenerateTokens }}
- name: GLOBAL_HASH_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleGlobalHashSecret
{{- else if .consoleGlobalHashSecret }}
- name: GLOBAL_HASH_SECRET
  value: {{ .consoleGlobalHashSecret | quote }}
{{- end }}
{{- with .consoleRawAuthTokens }}
- name: CONSOLE_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- with .githubClientID }}
- name: GITHUB_CLIENT_ID
  value: {{ . | quote }}
{{- end }}
{{- with .githubClientSecret }}
- name: GITHUB_CLIENT_SECRET
  value: {{ . | quote }}
{{- end }}
{{- with .adminCredentials }}
- name: ADMIN_CREDENTIALS
  value: {{ . | quote }}
{{- end }}
{{- with .googleSchedulerKey }}
- name: GOOGLE_SCHEDULER_KEY
  value: {{ . | quote }}
{{- end }}
{{- with .clickhouseMetricsSchema }}
- name: CLICKHOUSE_METRICS_SCHEMA
  value: {{ . | quote }}
{{- end }}
{{- with .clickhouseURL }}
- name: CLICKHOUSE_URL
  value: {{ . | quote }}
{{- end }}
{{- with .clickhouseUsername }}
- name: CLICKHOUSE_USERNAME
  value: {{ . | quote }}
{{- end }}
{{- with .clickhousePassword }}
- name: CLICKHOUSE_PASSWORD
  value: {{ . | quote }}
{{- end }}
{{- with .logFormat }}
- name: LOG_FORMAT
  value: {{ . | quote }}
{{- end }}
{{- with .disableSignup }}
- name: DISABLE_SIGNUP
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
