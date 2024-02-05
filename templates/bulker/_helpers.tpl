{{/*
Bulker selector labels
*/}}
{{- define "jitsu.bulker.selectorLabels" -}}
app.kubernetes.io/component: bulker
{{- end }}

{{- define "jitsu.bulker.env" -}}
{{- with .Values.bulker.config }}
- name: BULKER_INSTANCE_ID
  value: {{ .instanceID | quote }}
{{- if and (not .configSource) $.Values.console.enabled $.Values.config.autoGenerateTokens }}
- name: BULKER_CONFIG_SOURCE
  value: {{ printf "http://%s-console:%d/api/admin/export/bulker-connections"
    (include "jitsu.fullname" $)
    (int $.Values.console.service.port)
  | quote }}
{{- end }}
{{- with .configSource }}
- name: BULKER_CONFIG_SOURCE
  value: {{ . | quote }}
{{- end }}
{{- if and (not .configSourceHTTPAuthToken) $.Values.console.enabled $.Values.config.autoGenerateTokens }}
- name: BULKER_CONFIG_SOURCE_HTTP_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerConfigSourceHTTPAuthToken
{{- end }}
{{- with .configSourceHTTPAuthToken }}
- name: BULKER_CONFIG_SOURCE_HTTP_AUTH_TOKEN
  value: {{ . | quote }}
{{- end }}
{{- with .configRefreshPeriodSec }}
- name: BULKER_CONFIG_REFRESH_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}
{{- range $k, $v := .destination }}
- name: {{ printf "BULKER_DESTINATION_%s" (upper $k) | quote }}
  {{- if kindIs "string" $v }}
  value: {{ $v | quote }}
  {{- else }}
  value: {{ toJson $v | quote }}
  {{- end }}
{{- end }}
{{- if and (not .authTokens) $.Values.config.autoGenerateTokens }}
- name: BULKER_AUTH_TOKENS
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: bulkerAuthTokens
{{- end }}
{{- with .authTokens}}
- name: BULKER_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- with .rawAuthTokens }}
- name: BULKER_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- if and (not .redisURL) (not $.Values.config.redisURL) $.Values.redis.enabled }}
- name: BULKER_REDIS_URL
  value: "redis://{{ $.Release.Name }}-redis-master:6379"
{{- end }}
{{- with (.redisURL | default $.Values.config.redisURL) }}
- name: BULKER_REDIS_URL
  value: {{ . | quote }}
{{- end }}
{{- with .eventsLogMaxSize }}
- name: BULKER_EVENTS_LOG_MAX_SIZE
  value: {{ . | quote }}
{{- end }}
{{- if and (not .kafkaBootstrapServers) (not $.Values.config.kafkaBootstrapServers) $.Values.kafka.enabled }}
- name: BULKER_KAFKA_BOOTSTRAP_SERVERS
  value: "{{ $.Release.Name }}-kafka:9092"
{{- end }}
{{- with (.kafkaBootstrapServers | default $.Values.config.kafkaBootstrapServers) }}
- name: BULKER_KAFKA_BOOTSTRAP_SERVERS
  value: {{ . | quote }}
{{- end }}
{{- with (.kafkaSSL | default $.Values.config.kafkaSSL) }}
- name: BULKER_KAFKA_SSL
  value: {{ . | quote }}
{{- end }}
{{- with .kafkaSSLSkipVerify }}
- name: BULKER_KAFKA_SSL_SKIP_VERIFY
  value: {{ . | quote }}
{{- end }}
{{- with (.kafkaSASL | default $.Values.config.kafkaSASL) }}
- name: BULKER_KAFKA_SASL
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}
{{- with .batchRunnerDefaultPeriodSec }}
- name: BULKER_BATCH_RUNNER_DEFAULT_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}
{{- with .batchRunnerDefaultBatchSize }}
- name: BULKER_BATCH_RUNNER_DEFAULT_BATCH_SIZE
  value: {{ . | quote }}
{{- end }}
{{- with .batchRunnerDefaultRetryPeriodSec }}
- name: BULKER_BATCH_RUNNER_DEFAULT_RETRY_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}
{{- with .batchRunnerDefaultRetryBatchSize }}
- name: BULKER_BATCH_RUNNER_DEFAULT_RETRY_BATCH_SIZE
  value: {{ . | quote }}
{{- end }}
{{- with .messagesRetryCount }}
- name: BULKER_MESSAGES_RETRY_COUNT
  value: {{ . | quote }}
{{- end }}
{{- with .messagesRetryBackoffBase }}
- name: BULKER_MESSAGES_RETRY_BACKOFF_BASE
  value: {{ . | quote }}
{{- end }}
{{- with .messagesRetryBackoffMaxDelay }}
- name: BULKER_MESSAGES_RETRY_BACKOFF_MAX_DELAY
  value: {{ . | quote }}
{{- end }}
{{- with .kafkaTopicRetentionHours }}
- name: BULKER_KAFKA_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}
{{- with .kafkaRetryTopicRetentionHours }}
- name: BULKER_KAFKA_RETRY_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}
{{- with .kafkaDeadTopicRetentionHours }}
- name: BULKER_KAFKA_DEAD_TOPIC_RETENTION_HOURS
  value: {{ . | quote }}
{{- end }}
{{- with .kafkaTopicReplicationFactor }}
- name: BULKER_KAFKA_TOPIC_REPLICATION_FACTOR
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
