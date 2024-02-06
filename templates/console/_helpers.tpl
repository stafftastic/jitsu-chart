{{/*
Console selector labels
*/}}
{{- define "jitsu.console.selectorLabels" -}}
app.kubernetes.io/component: console
{{- end }}

{{- define "jitsu.console.env" -}}
{{- with .Values.console.config -}}
- name: JITSU_PUBLIC_URL
  value: {{ .jitsuPublicUrl | quote }}
- name: NEXTAUTH_URL
  value: {{ .nextauthUrl | default .jitsuPublicUrl | quote }}
- name: NEXTAUTH_URL_INTERNAL
  value: {{ .nextauthUrlInternal | default (printf "http://%s-console:%d" (include "jitsu.fullname" $) (int $.Values.console.service.port)) | quote }}
- name: JITSU_INGEST_PUBLIC_URL
  value: {{ .jitsuIngestPublicUrl | quote }}
- name: DATABASE_URL
  value: {{ .databaseUrl | default (include "jitsu.databaseUrl" $) | quote }}
{{- if and (not .bulkerUrl) (not $.Values.config.bulkerUrl) $.Values.bulker.enabled }}
- name: BULKER_URL
  value: {{ printf "http://%s-bulker:%d" (include "jitsu.fullname" $) (int $.Values.bulker.service.port) | quote }}
{{- end }}
{{- with (.bulkerUrl | default $.Values.config.bulkerUrl) }}
- name: BULKER_URL
  value: {{ . | quote }}
{{- end }}
{{- if and (not .bulkerAuthKey) $.Values.bulker.enabled $.Values.tokenGenerator.enabled }}
- name: BULKER_AUTH_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerAuthToken
{{- end }}
{{- with .bulkerAuthKey }}
- name: BULKER_AUTH_KEY
  value: {{ . | quote }}
{{- end }}
{{- if and (not .rotorUrl) (not $.Values.config.rotorUrl) $.Values.rotor.enabled }}
- name: ROTOR_URL
  value: {{ printf "http://%s-rotor:%d" (include "jitsu.fullname" $) (int $.Values.rotor.service.port) | quote }}
{{- end }}
{{- with (.rotorUrl | default $.Values.config.rotorUrl) }}
- name: ROTOR_URL
  value: {{ . | quote }}
{{- end }}
{{- if and (not .ingestHost) (not $.Values.config.ingestHost) $.Values.ingest.enabled }}
- name: INGEST_HOST
  value: {{ $.Values.ingest.config.dataDomain | default (printf "%s-ingest" (include "jitsu.fullname" $)) | quote }}
{{- end }}
{{- with (.ingestHost | default $.Values.config.ingestHost) }}
- name: INGEST_HOST
  value: {{ . | quote }}
{{- end }}
{{- if and (not .ingestPort) (not $.Values.config.ingestPort) $.Values.ingest.enabled }}
- name: INGEST_PORT
  {{- if and $.Values.ingest.ingress.enabled $.Values.ingest.ingress.tls }}
  value: "443"
  {{- else if $.Values.ingest.ingress.enabled }}
  value: "80"
  {{- else }}
  value: {{ $.Values.ingest.service.port | quote }}
  {{- end }}
{{- end }}
{{- with (.ingestPort | default $.Values.config.ingestPort) }}
- name: INGEST_PORT
  value: {{ . | quote }}
{{- end }}
{{- if and (not .syncsEnabled) $.Values.syncctl.enabled }}
- name: SYNCS_ENABLED
  value: "true"
{{- end }}
{{- with .syncsEnabled }}
- name: SYNCS_ENABLED
  value: {{ . | quote }}
{{- end }}
{{- if and (not .syncctlUrl) $.Values.syncctl.enabled }}
- name: SYNCCTL_URL
  value: {{ .syncctlUrl | default (printf "http://%s-syncctl:%d" (include "jitsu.fullname" $) (int $.Values.syncctl.service.port)) | quote }}
{{- end }}
{{- with .syncctlUrl }}
- name: SYNCCTL_URL
  value: {{ .syncctlUrl | quote }}
{{- end }}
{{- if and (not .syncctlAuthKey) $.Values.syncctl.enabled $.Values.tokenGenerator.enabled }}
- name: SYNCCTL_AUTH_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: syncctlAuthToken
{{- end }}
{{- with .syncctlAuthKey }}
- name: SYNCCTL_AUTH_KEY
  value: {{ . | quote }}
{{- end }}
{{- if and (not .consoleAuthTokens) $.Values.tokenGenerator.enabled }}
- name: CONSOLE_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleAuthTokens
{{- end }}
{{- with .consoleAuthTokens }}
- name: CONSOLE_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- if and (not .globalHashSecret) (not $.Values.config.globalHashSecret) $.Values.tokenGenerator.enabled }}
- name: GLOBAL_HASH_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: globalHashSecret
{{- end }}
{{- with (.globalHashSecret | default $.Values.config.globalHashSecret) }}
- name: GLOBAL_HASH_SECRET
  value: {{ . | quote }}
{{- end }}
{{- with .consoleRawAuthTokens }}
- name: CONSOLE_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- with .seedUserEmail }}
- name: SEED_USER_EMAIL
  value: {{ . | quote }}
{{- end }}
{{- with .seedUserPassword }}
- name: SEED_USER_PASSWORD
  value: {{ . | quote }}
{{- end }}
{{- with .githubClientId }}
- name: GITHUB_CLIENT_ID
  value: {{ . | quote }}
{{- end }}
{{- with .githubClientSecret }}
- name: GITHUB_CLIENT_SECRET
  value: {{ . | quote }}
{{- end }}
{{- with .enableCredentialsLogin }}
- name: ENABLE_CREDENTIALS_LOGIN
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
{{- with .clickhouseUrl }}
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
