{{/*
Bulker selector labels
*/}}
{{- define "jitsu.bulker.selectorLabels" -}}
app.kubernetes.io/component: bulker
{{- end }}

{{- define "jitsu.bulker.env" -}}
{{- with .Values.bulker.config }}
- name: BULKER_INSTANCE_ID
  value: {{ .bulkerInstanceID | quote }}
{{- if and (not .bulkerConfigSource) $.Values.config.autoGenerateTokens }}
- name: BULKER_CONFIG_SOURCE
  value: {{ printf "http://%s-console:%d/api/admin/export/bulker-connections"
    (include "jitsu.fullname" $)
    $.Values.console.service.port
  | quote }}
{{- else if .bulkerConfigSource }}
- name: BULKER_CONFIG_SOURCE
  value: {{ .bulkerConfigSource | quote }}
{{- end }}
{{- if and (not .bulkerConfigSourceHTTPAuthToken) $.Values.config.autoGenerateTokens }}
- name: BULKER_CONFIG_SOURCE_HTTP_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerConfigSourceHTTPAuthToken
{{- else if .bulkerConfigSourceHTTPAuthToken }}
- name: BULKER_CONFIG_SOURCE_HTTP_AUTH_TOKEN
  value: {{ .bulkerConfigSourceHTTPAuthToken | quote }}
{{- end }}
{{- with .bulkerConfigRefreshPeriodSec }}
- name: BULKER_CONFIG_REFRESH_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}
{{- range $k, $v := .bulkerDestination }}
- name: {{ printf "BULKER_DESTINATION_%s" (upper $k) | quote }}
  {{- if kindIs "string" $v }}
  value: {{ $v | quote }}
  {{- else }}
  value: {{ toJson $v | quote }}
  {{- end }}
{{- end }}
{{- if and (not .bulkerAuthTokens) $.Values.config.autoGenerateTokens }}
- name: BULKER_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerAuthTokens
{{- else if .bulkerAuthTokens}}
- name: BULKER_AUTH_TOKENS
  value: {{ .bulkerAuthTokens | quote }}
{{- end }}
{{- with .bulkerRawAuthTokens }}
- name: BULKER_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- if and (not .bulkerRedisURL) $.Values.redis.enabled }}
- name: BULKER_REDIS_URL
  value: "redis://{{ $.Release.Name }}-redis-master:6379"
{{- else if .bulkerRedisURL }}
- name: BULKER_REDIS_URL
  value: {{ .bulkerRedisURL | quote }}
{{- end }}
{{- with .bulkerEventsLogMaxSize }}
- name: BULKER_EVENTS_LOG_MAX_SIZE
  value: {{ . | quote }}
{{- end }}
{{- if and (not .bulkerKafkaBootstrapServers) $.Values.kafka.enabled }}
- name: BULKER_KAFKA_BOOTSTRAP_SERVERS
  value: "{{ $.Release.Name }}-kafka:9092"
{{- else if .bulkerKafkaBootstrapServers }}
- name: BULKER_KAFKA_BOOTSTRAP_SERVERS
  value: {{ .bulkerKafkaBootstrapServers | quote }}
{{- end }}
{{- with .bulkerKafkaSSL }}
- name: BULKER_KAFKA_SSL
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerKafkaSSLSkipVerify }}
- name: BULKER_KAFKA_SSL_SKIP_VERIFY
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerKafkaSASL }}
- name: BULKER_KAFKA_SASL
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerBatchRunnerDefaultPeriodSec }}
- name: BULKER_BATCH_RUNNER_DEFAULT_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerBatchRunnerDefaultBatchSize }}
- name: BULKER_BATCH_RUNNER_DEFAULT_BATCH_SIZE
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerBatchRunnerDefaultRetryPeriodSec }}
- name: BULKER_BATCH_RUNNER_DEFAULT_RETRY_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerBatchRunnerDefaultRetryBatchSize }}
- name: BULKER_BATCH_RUNNER_DEFAULT_RETRY_BATCH_SIZE
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerMessagesRetryCount }}
- name: BULKER_MESSAGES_RETRY_COUNT
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerMessagesRetryBackoffBase }}
- name: BULKER_MESSAGES_RETRY_BACKOFF_BASE
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerMessagesRetryBackoffMaxDelay }}
- name: BULKER_MESSAGES_RETRY_BACKOFF_MAX_DELAY
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerKafkaTopicRetentionHours }}
- name: BULKER_KAFKA_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerKafkaRetryTopicRetentionHours }}
- name: BULKER_KAFKA_RETRY_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerKafkaDeadTopicRetentionHours }}
- name: BULKER_KAFKA_DEAD_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}
{{- with .bulkerKafkaTopicReplicationFactor }}
- name: BULKER_KAFKA_TOPIC_REPLICATION_FACTOR
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
