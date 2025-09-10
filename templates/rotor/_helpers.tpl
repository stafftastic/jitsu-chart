{{/*
Rotor selector labels
*/}}
{{- define "jitsu.rotor.selectorLabels" -}}
app.kubernetes.io/component: rotor
{{- end }}

{{- define "jitsu.rotor.kubectlSelectorLabels" -}}
{{- $labels := merge (dict) (include "jitsu.selectorLabels" . | fromYaml) (include "jitsu.rotor.selectorLabels" . | fromYaml) }}
{{- $args := list -}}
{{- range $k, $v := $labels -}}
{{ $args = append $args (printf "%s=%s" $k $v) -}}
{{- end -}}
{{- join "," $args -}}
{{- end }}

{{- define "jitsu.rotor.env" -}}
{{- with .Values.rotor.config }}
{{- if or .redisUrlFrom $.Values.config.redisUrlFrom }}
- name: REDIS_URL
  valueFrom:
    {{- toYaml (.redisUrlFrom | default $.Values.config.redisUrlFrom) | nindent 4 }}
{{- else }}
- name: REDIS_URL
  value: {{ .redisUrl | default (include "jitsu.redisUrl" $) | quote }}
{{- end }}

{{- if or .mongodbUrlFrom $.Values.config.mongodbUrlFrom }}
- name: MONGODB_URL
  valueFrom:
    {{- toYaml (.mongodbUrlFrom | default $.Values.config.mongodbUrlFrom) | nindent 4 }}
{{- else }}
- name: MONGODB_URL
  value: {{ .mongodbUrl | default (include "jitsu.mongodbUrl" $) | quote }}
{{- end }}

{{- if or .clickhouseHostFrom $.Values.config.clickhouseHttpHostFrom }}
- name: CLICKHOUSE_HOST
  valueFrom:
    {{- toYaml (.clickhouseHostFrom | default $.Values.config.clickhouseHttpHostFrom) | nindent 4 }}
{{- else }}
- name: CLICKHOUSE_HOST
  value: {{ .clickhouseHost | default (include "jitsu.clickhouseHttpHost" $) | quote }}
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

{{- if and (not .repositoryBaseUrl) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: REPOSITORY_BASE_URL
  value: {{ printf "http://%s-console:%d/api/admin/export"
    (include "jitsu.fullname" $)
    (int $.Values.console.service.port)
  | quote }}
{{- end }}
{{- with .repositoryBaseUrl }}
- name: REPOSITORY_BASE_URL
  value: {{ . | quote }}
{{- end }}

{{- if .authTokensFrom }}
- name: ROTOR_AUTH_TOKENS
  valueFrom:
    {{- toYaml .authTokensFrom | nindent 4 }}
{{- else }}
{{- if and (not .authTokens) $.Values.tokenGenerator.enabled }}
- name: ROTOR_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: rotorAuthTokens
{{- end }}
{{- with .authTokens}}
- name: ROTOR_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .tokenSecretFrom }}
- name: ROTOR_TOKEN_SECRET
  valueFrom:
    {{- toYaml .tokenSecretFrom | nindent 4 }}
{{- else }}
{{- if and (not .tokenSecret) $.Values.tokenGenerator.enabled }}
- name: ROTOR_TOKEN_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: globalHashSecret
{{- end }}
{{- with .tokenSecret }}
- name: ROTOR_TOKEN_SECRET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .repositoryAuthTokenFrom }}
- name: REPOSITORY_AUTH_TOKEN
  valueFrom:
    {{- toYaml .repositoryAuthTokenFrom | nindent 4 }}
{{- else }}
{{- if and (not .repositoryAuthToken) $.Values.console.enabled $.Values.tokenGenerator.enabled }}
- name: REPOSITORY_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: consoleAuthToken
{{- end }}
{{- with .repositoryAuthToken }}
- name: REPOSITORY_AUTH_TOKEN
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- with .repositoryRefreshPeriodSec }}
- name: REPOSITORY_REFRESH_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}

{{- if and (not .bulkerUrl) (not $.Values.config.bulkerUrl) $.Values.bulker.enabled }}
- name: BULKER_URL
  value: {{ printf "http://%s-bulker:%d"
    (include "jitsu.fullname" $)
    (int $.Values.bulker.service.port)
  | quote }}
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

{{- if and (not .kafkaBootstrapServers) (not $.Values.config.kafkaBootstrapServers) $.Values.kafka.enabled }}
- name: KAFKA_BOOTSTRAP_SERVERS
  value: {{ printf "%s-kafka:9092" $.Release.Name | quote }}
{{- end }}
{{- with (.kafkaBootstrapServers | default $.Values.config.kafkaBootstrapServers) }}
- name: KAFKA_BOOTSTRAP_SERVERS
  value: {{ . | quote }}
{{- end }}

{{- with (.kafkaSsl | default $.Values.config.kafkaSsl) }}
- name: KAFKA_SSL
  value: {{ . | quote }}
{{- end }}

{{- if or .kafkaSaslFrom $.Values.config.kafkaSaslFrom }}
- name: KAFKA_SASL
  valueFrom:
    {{- toYaml (.kafkaSaslFrom | default $.Values.config.kafkaSaslFrom) | nindent 4 }}
{{- else }}
{{- with (.kafkaSasl | default $.Values.config.kafkaSasl) }}
- name: KAFKA_SASL
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}
{{- end }}

{{- with .metricsDestinationId }}
- name: METRICS_DESTINATION_ID
  value: {{ . | quote }}
{{- end }}

{{- with .eventsLogMaxSize }}
- name: EVENTS_LOG_MAX_SIZE
  value: {{ . | quote }}
{{- end }}

{{- with .concurrency }}
- name: CONCURRENCY
  value: {{ . | quote }}
{{- end }}

{{- with .messagesRetryCount }}
- name: MESSAGES_RETRY_COUNT
  value: {{ . | quote }}
{{- end }}

{{- with .messagesRetryBackoffBase }}
- name: MESSAGES_RETRY_BACKOFF_BASE
  value: {{ . | quote }}
{{- end }}

{{- with .messagesRetryBackoffMaxDelay }}
- name: MESSAGES_RETRY_BACKOFF_MAX_DELAY
  value: {{ . | quote }}
{{- end }}

{{- with .logFormat }}
- name: LOG_FORMAT
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
