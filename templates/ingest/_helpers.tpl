{{/*
Console selector labels
*/}}
{{- define "jitsu.ingest.selectorLabels" -}}
app.kubernetes.io/component: ingest
{{- end }}

{{- define "jitsu.ingest.env" -}}
{{- with .Values.ingest.config }}
- name: INGEST_DATA_DOMAIN
  value: {{ .dataDomain | default ($.Values.ingress.enabled | ternary $.Values.ingress.host "") | quote }}

{{- if or .redisUrlFrom $.Values.config.redisUrlFrom }}
- name: INGEST_REDIS_URL
  valueFrom:
    {{- toYaml (.redisUrlFrom | default $.Values.config.redisUrlFrom) | nindent 4 }}
{{- else }}
- name: INGEST_REDIS_URL
  value: {{ .redisUrl | default (include "jitsu.redisUrl" $) | quote }}
{{- end }}

{{- if or .clickhouseHostFrom $.Values.config.clickhouseTcpHostFrom }}
- name: INGEST_CLICKHOUSE_HOST
  valueFrom:
    {{- toYaml (.clickhouseHostFrom | default $.Values.config.clickhouseTcpHostFrom) | nindent 4 }}
{{- else }}
- name: INGEST_CLICKHOUSE_HOST
  value: {{ .clickhouseHost | default (include "jitsu.clickhouseTcpHost" $) | quote }}
{{- end }}

{{- if or .clickhouseDatabaseFrom $.Values.config.clickhouseDatabaseFrom }}
- name: INGEST_CLICKHOUSE_DATABASE
  valueFrom:
    {{- toYaml (.clickhouseDatabaseFrom | default $.Values.config.clickhouseDatabaseFrom) | nindent 4 }}
{{- else }}
- name: INGEST_CLICKHOUSE_DATABASE
  value: {{ .clickhouseDatabase | default (include "jitsu.clickhouseDatabase" $) | quote }}
{{- end }}

{{- if or .clickhouseUsernameFrom $.Values.config.clickhouseUsernameFrom }}
- name: INGEST_CLICKHOUSE_USERNAME
  valueFrom:
    {{- toYaml (.clickhouseUsernameFrom | default $.Values.config.clickhouseUsernameFrom) | nindent 4 }}
{{- else }}
- name: INGEST_CLICKHOUSE_USERNAME
  value: {{ .clickhouseUsername | default (include "jitsu.clickhouseUsername" $) | quote }}
{{- end }}

{{- if or .clickhousePasswordFrom $.Values.config.clickhousePasswordFrom }}
- name: INGEST_CLICKHOUSE_PASSWORD
  valueFrom:
    {{- toYaml (.clickhousePasswordFrom | default $.Values.config.clickhousePasswordFrom) | nindent 4 }}
{{- else }}
- name: INGEST_CLICKHOUSE_PASSWORD
  value: {{ .clickhousePassword | default (include "jitsu.clickhousePassword" $) | quote }}
{{- end }}

{{- with (.clickhouseSsl | default $.Values.config.clickhouseSsl) }}
- name: INGEST_CLICKHOUSE_SSL
  value: {{ . | quote }}
{{- end }}

{{- if .authTokensFrom }}
- name: INGEST_AUTH_TOKENS
  valueFrom:
    {{- toYaml .authTokensFrom | nindent 4 }}
{{- else }}
{{- if and (not .authTokens) $.Values.tokenGenerator.enabled }}
- name: INGEST_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: ingestAuthTokens
{{- end }}
{{- with .authTokens }}
- name: INGEST_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .tokenSecretFrom }}
- name: INGEST_TOKEN_SECRET
  valueFrom:
    {{- toYaml .tokenSecretFrom | nindent 4 }}
{{- else }}
{{- if and (not .tokenSecret) $.Values.tokenGenerator.enabled }}
- name: INGEST_TOKEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: ingestTokenSecret
{{- end }}
{{- with .tokenSecret }}
- name: INGEST_TOKEN_SECRET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .rawAuthTokensFrom }}
- name: INGEST_RAW_AUTH_TOKENS
  valueFrom:
    {{- toYaml .rawAuthTokensFrom | nindent 4 }}
{{- else }}
{{- with .rawAuthTokens }}
- name: INGEST_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if or .globalHashSecretFrom $.Values.config.globalHashSecretFrom }}
- name: INGEST_GLOBAL_HASH_SECRET
  valueFrom:
    {{- toYaml (.globalHashSecretFrom | default $.Values.config.globalHashSecretFrom) | nindent 4 }}
{{- else }}
{{- if and (not .globalHashSecret) (not $.Values.config.globalHashSecret) $.Values.tokenGenerator.enabled }}
- name: INGEST_GLOBAL_HASH_SECRET
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

{{- if and (not .repositoryUrl) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: INGEST_REPOSITORY_URL
  value: {{ printf "http://%s-console:%d/api/admin/export/streams-with-destinations"
    (include "jitsu.fullname" $)
    (int $.Values.console.service.port)
  | quote }}
{{- end }}
{{- with .repositoryUrl }}
- name: INGEST_REPOSITORY_URL
  value: {{ . | quote }}
{{- end }}

{{- if .repositoryAuthTokenFrom }}
- name: INGEST_REPOSITORY_AUTH_TOKEN
  valueFrom:
    {{- toYaml .repositoryAuthTokenFrom | nindent 4 }}
{{- else }}
{{- if and (not .repositoryAuthToken) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: INGEST_REPOSITORY_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleAuthToken
{{- end }}
{{- with .repositoryAuthToken }}
- name: INGEST_REPOSITORY_AUTH_TOKEN
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .repositoryRefreshPeriodSec }}
- name: INGEST_REPOSITORY_REFRESH_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}

{{- if and (not .kafkaBootstrapServers) (not $.Values.config.kafkaBootstrapServers) $.Values.kafka.enabled }}
- name: INGEST_KAFKA_BOOTSTRAP_SERVERS
  value: "{{ $.Release.Name }}-kafka:9092"
{{- end }}
{{- with (.kafkaBootstrapServers | default $.Values.config.kafkaBootstrapServers) }}
- name: INGEST_KAFKA_BOOTSTRAP_SERVERS
  value: {{ . | quote }}
{{- end }}

{{- with (.kafkaSsl | default $.Values.config.kafkaSsl) }}
- name: INGEST_KAFKA_SSL
  value: {{ . | quote }}
{{- end }}

{{- with (.kafkaSslSkipVerify | default $.Values.config.kafkaSslSkipVerify) }}
- name: INGEST_KAFKA_SSL_SKIP_VERIFY
  value: {{ . | quote }}
{{- end }}

{{- if or .kafkaSaslFrom $.Values.config.kafkaSaslFrom }}
- name: INGEST_KAFKA_SASL
  valueFrom:
    {{- toYaml (.kafkaSaslFrom | default $.Values.config.kafkaSaslFrom) | nindent 4 }}
{{- else }}
{{- with (.kafkaSasl | default $.Values.config.kafkaSasl) }}
- name: INGEST_KAFKA_SASL
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- if and (not .rotorUrl) (not $.Values.config.rotorUrl) $.Values.rotor.enabled }}
- name: INGEST_ROTOR_URL
  value: {{ printf "http://%s-rotor:%d" (include "jitsu.fullname" $) (int $.Values.rotor.service.port) | quote }}
{{- end }}
{{- with (.rotorUrl | default $.Values.config.rotorUrl) }}
- name: INGEST_ROTOR_URL
  value: {{ . | quote }}
{{- end }}

{{- if .rotorAuthKeyFrom }}
- name: INGEST_ROTOR_AUTH_KEY
  valueFrom:
    {{- toYaml .rotorAuthKeyFrom | nindent 4 }}
{{- else }}
{{- if and (not .rotorAuthKey) $.Values.rotor.enabled $.Values.tokenGenerator.enabled }}
- name: INGEST_ROTOR_AUTH_KEY
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: rotorAuthToken
{{- end }}
{{- with .rotorAuthKey }}
- name: INGEST_ROTOR_AUTH_KEY
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .eventsLogMaxSize }}
- name: INGEST_EVENTS_LOG_MAX_SIZE
  value: {{ . | quote }}
{{- end }}

{{- with .logFormat }}
- name: INGEST_LOG_FORMAT
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
