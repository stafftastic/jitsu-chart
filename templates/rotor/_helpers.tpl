{{/*
Rotor selector labels
*/}}
{{- define "jitsu.rotor.selectorLabels" -}}
app.kubernetes.io/component: rotor
{{- end }}

{{- define "jitsu.rotor.env" -}}
{{- with .Values.rotor.config }}
{{- if and (not .repositoryBaseUrl) $.Values.console.enabled $.Values.config.autoGenerateTokens }}
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
{{- if and (not .repositoryAuthToken) $.Values.console.enabled $.Values.config.autoGenerateTokens }}
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
{{- with .repositoryRefreshPeriodSec }}
- name: REPOSITORY_REFRESH_PERIOD_SEC
  value: {{ . | quote }}
{{- end }}
{{- if and (not .redisUrl) (not $.Values.config.redisUrl) $.Values.redis.enabled }}
- name: REDIS_URL
  value: {{ printf "redis://%s-redis-master:6379" $.Release.Name | quote }}
{{- end }}
{{- with (.redisUrl | default $.Values.config.redisUrl) }}
- name: REDIS_URL
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
{{- if and (not .bulkerAuthKey) $.Values.bulker.enabled $.Values.config.autoGenerateTokens }}
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
{{- with (.kafkaSasl | default $.Values.config.kafkaSasl) }}
- name: KAFKA_SASL
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}
{{- if and (not .mongodbUrl) (not $.Values.config.mongodbUrl) $.Values.mongodb.enabled }}
- name: MONGODB_URL
  value: {{ printf "mongodb://%s-mongodb:27017" $.Release.Name | quote }}
{{- end }}
{{- with (.mongodbUrl | default $.Values.config.mongodbUrl) }}
- name: MONGODB_URL
  value: {{ . | quote }}
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
