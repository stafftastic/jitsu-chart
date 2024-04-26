{{/*
Console selector labels
*/}}
{{- define "jitsu.console.selectorLabels" -}}
app.kubernetes.io/component: console
{{- end }}

{{- define "jitsu.console.env" -}}
{{- with .Values.console.config -}}
- name: JITSU_PUBLIC_URL
  value: {{ .jitsuPublicUrl | default (include "jitsu.publicUrl" $) | quote }}
- name: NEXTAUTH_URL
  value: {{ .nextauthUrl | default .jitsuPublicUrl | default (include "jitsu.publicUrl" $) | quote }}
- name: NEXTAUTH_URL_INTERNAL
  value: {{ .nextauthUrlInternal | default (printf "http://%s-console:%d" (include "jitsu.fullname" $) (int $.Values.console.service.port)) | quote }}
- name: JITSU_INGEST_PUBLIC_URL
  value: {{ .jitsuIngestPublicUrl | default (include "jitsu.publicUrl" $) | quote }}

{{- if or .databaseUrlFrom $.Values.config.databaseUrlFrom }}
- name: DATABASE_URL
  valueFrom:
    {{- toYaml (.databaseUrlFrom | default $.Values.config.databaseUrlFrom) | nindent 4 }}
{{- else }}
- name: DATABASE_URL
  value: {{ .databaseUrl | default (include "jitsu.databaseUrl" $) | quote }}
{{- end }}

{{- if or .clickhouseHostFrom $.Values.config.clickhouseHostFrom }}
- name: CLICKHOUSE_HOST
  valueFrom:
    {{- toYaml (.clickhouseHostFrom | default $.Values.config.clickhouseHostFrom) | nindent 4 }}
{{- else }}
- name: CLICKHOUSE_HOST
  value: {{ .clickhouseHost | default ((include "jitsu.clickhouseHost" $) | replace "9000" "8123") | quote }}
{{- end }}

{{- if or .clickhouseDatabaseFrom $.Values.config.clickhouseDatabaseFrom }}
- name: CLICKHOUSE_DATABASE
  valueFrom:
    {{- toYaml (.clickhouseDatabaseFrom | default $.Values.config.clickhouseDatabaseFrom) | nindent 4 }}
{{- else }}
- name: CLICKHOUSE_DATABASE
  value: {{ .clickhouseDatabase | default (include "jitsu.clickhouseDatabase" $) | quote }}
{{- end }}

{{- if or .clickhouseUsernameFrom $.Values.config.clickhouseUsernameFrom }}
- name: CLICKHOUSE_USERNAME
  valueFrom:
    {{- toYaml (.clickhouseUsernameFrom | default $.Values.config.clickhouseUsernameFrom) | nindent 4 }}
{{- else }}
- name: CLICKHOUSE_USERNAME
  value: {{ .clickhouseUsername | default (include "jitsu.clickhouseUsername" $) | quote }}
{{- end }}

{{- if or .clickhousePasswordFrom $.Values.config.clickhousePasswordFrom }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    {{- toYaml (.clickhousePasswordFrom | default $.Values.config.clickhousePasswordFrom) | nindent 4 }}
{{- else }}
- name: CLICKHOUSE_PASSWORD
  value: {{ .clickhousePassword | default (include "jitsu.clickhousePassword" $) | quote }}
{{- end }}

{{- with (.clickhouseSsl | default $.Values.config.clickhouseSsl) }}
- name: CLICKHOUSE_SSL
  value: {{ . | quote }}
{{- end }}

{{- if and (not .bulkerUrl) (not $.Values.config.bulkerUrl) $.Values.bulker.enabled }}
- name: BULKER_URL
  value: {{ printf "http://%s-bulker:%d" (include "jitsu.fullname" $) (int $.Values.bulker.service.port) | quote }}
{{- end }}
{{- with (.bulkerUrl | default $.Values.config.bulkerUrl) }}
- name: BULKER_URL
  value: {{ . | quote }}
{{- end }}

{{- if .bulkerAuthKeyFrom }}
- name: BULKER_AUTH_KEY
  valueFrom:
    {{- toYaml .bulkerAuthKeyFrom | nindent 4 }}
{{- else }}
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
{{- end }}

{{- if and (not .rotorUrl) (not $.Values.config.rotorUrl) $.Values.rotor.enabled }}
- name: ROTOR_URL
  value: {{ printf "http://%s-rotor:%d" (include "jitsu.fullname" $) (int $.Values.rotor.service.port) | quote }}
{{- end }}
{{- with (.rotorUrl | default $.Values.config.rotorUrl) }}
- name: ROTOR_URL
  value: {{ . | quote }}
{{- end }}

{{- if .rotorAuthKeyFrom }}
- name: ROTOR_AUTH_KEY
  valueFrom:
    {{- toYaml .rotorAuthKeyFrom | nindent 4 }}
{{- else }}
{{- if and (not .rotorAuthKey) $.Values.rotor.enabled $.Values.tokenGenerator.enabled }}
- name: ROTOR_AUTH_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: rotorAuthToken
{{- end }}
{{- with .rotorAuthKey }}
- name: ROTOR_AUTH_KEY
  value: {{ . | quote }}
{{- end }}
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

{{- if and (not .syncctlUrl) (not $.Values.config.syncctlUrl) $.Values.syncctl.enabled }}
- name: SYNCCTL_URL
  value: {{ printf "http://%s-syncctl:%d" (include "jitsu.fullname" $) (int $.Values.syncctl.service.port) | quote }}
{{- end }}
{{- with (.syncctlUrl | default $.Values.config.syncctlUrl) }}
- name: SYNCCTL_URL
  value: {{ . | quote }}
{{- end }}

{{- if .syncctlAuthKeyFrom }}
- name: SYNCCTL_AUTH_KEY
  valueFrom:
    {{- toYaml .syncctlAuthKeyFrom | nindent 4 }}
{{- else }}
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
{{- end }}

{{- if .consoleAuthTokensFrom }}
- name: CONSOLE_AUTH_TOKENS
  valueFrom:
    {{- toYaml .consoleAuthTokensFrom | nindent 4 }}
{{- else }}
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
{{- end }}

{{- if or .globalHashSecretFrom $.Values.config.globalHashSecretFrom }}
- name: GLOBAL_HASH_SECRET
  valueFrom:
    {{- toYaml (.globalHashSecretFrom | default $.Values.config.globalHashSecretFrom) | nindent 4 }}
{{- else }}
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
{{- end }}

{{- if .consoleRawAuthTokensFrom }}
- name: CONSOLE_RAW_AUTH_TOKENS
  valueFrom:
    {{- toYaml .consoleRawAuthTokensFrom | nindent 4 }}
{{- else }}
{{- with .consoleRawAuthTokens }}
- name: CONSOLE_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .seedUserEmailFrom }}
- name: SEED_USER_EMAIL
  valueFrom:
    {{- toYaml .seedUserEmailFrom | nindent 4 }}
{{- else }}
{{- with .seedUserEmail }}
- name: SEED_USER_EMAIL
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .seedUserPasswordFrom }}
- name: SEED_USER_PASSWORD
  valueFrom:
    {{- toYaml .seedUserPasswordFrom | nindent 4 }}
{{- else }}
{{- with .seedUserPassword }}
- name: SEED_USER_PASSWORD
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .githubClientIdFrom }}
- name: GITHUB_CLIENT_ID
  valueFrom:
    {{- toYaml .githubClientIdFrom | nindent 4 }}
{{- else }}
{{- with .githubClientId }}
- name: GITHUB_CLIENT_ID
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .githubClientSecretFrom }}
- name: GITHUB_CLIENT_SECRET
  valueFrom:
    {{- toYaml .githubClientSecretFrom | nindent 4 }}
{{- else }}
{{- with .githubClientSecret }}
- name: GITHUB_CLIENT_SECRET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .enableCredentialsLogin }}
- name: ENABLE_CREDENTIALS_LOGIN
  value: {{ . | quote }}
{{- end }}

{{- with .adminCredentials }}
- name: ADMIN_CREDENTIALS
  value: {{ . | quote }}
{{- end }}

{{- if .googleSchedulerKeyFrom }}
- name: GOOGLE_SCHEDULER_KEY
  valueFrom:
    {{- toYaml .googleSchedulerKeyFrom | nindent 4 }}
{{- else }}
{{- with .googleSchedulerKey }}
- name: GOOGLE_SCHEDULER_KEY
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .clickhouseMetricsSchemaFrom }}
- name: CLICKHOUSE_METRICS_SCHEMA
  valueFrom:
    {{- toYaml .clickhouseMetricsSchemaFrom | nindent 4 }}
{{- else }}
{{- with .clickhouseMetricsSchema }}
- name: CLICKHOUSE_METRICS_SCHEMA
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .clickhouseUrlFrom }}
- name: CLICKHOUSE_URL
  valueFrom:
    {{- toYaml .clickhouseUrlFrom | nindent 4 }}
{{- else }}
{{- with .clickhouseUrl }}
- name: CLICKHOUSE_URL
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .clickhouseUsernameFrom }}
- name: CLICKHOUSE_USERNAME
  valueFrom:
    {{- toYaml .clickhouseUsernameFrom | nindent 4 }}
{{- else }}
{{- with .clickhouseUsername }}
- name: CLICKHOUSE_USERNAME
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .clickhousePasswordFrom }}
- name: CLICKHOUSE_PASSWORD
  valueFrom:
    {{- toYaml .clickhousePasswordFrom | nindent 4 }}
{{- else }}
{{- with .clickhousePassword }}
- name: CLICKHOUSE_PASSWORD
  value: {{ . | quote }}
{{- end }}
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
