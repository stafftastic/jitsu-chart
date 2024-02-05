{{/*
Console selector labels
*/}}
{{- define "jitsu.ingest.selectorLabels" -}}
app.kubernetes.io/component: ingest
{{- end }}

{{- define "jitsu.ingest.env" -}}
{{- with .Values.ingest.config }}
- name: INGEST_DATA_DOMAIN
  value: {{ .dataDomain | quote }}
{{- if and (not .authTokens) $.Values.config.autoGenerateTokens }}
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
{{- if and (not .tokenSecret) $.Values.config.autoGenerateTokens }}
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
{{- with .rawAuthTokens }}
- name: INGEST_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
{{- if and (not .repositoryURL) $.Values.console.enabled $.Values.config.autoGenerateTokens }}
- name: INGEST_REPOSITORY_URL
  value: {{ printf "http://%s-console:%d/api/admin/export/streams-with-destinations"
    (include "jitsu.fullname" $)
    (int $.Values.console.service.port)
  | quote }}
{{- end }}
{{- with .repositoryURL }}
- name: INGEST_REPOSITORY_URL
  value: {{ . | quote }}
{{- end }}
{{- if and (not .repositoryAuthToken) $.Values.console.enabled $.Values.config.autoGenerateTokens }}
- name: INGEST_REPOSITORY_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: ingestRepositoryAuthToken
{{- end }}
{{- with .repositoryAuthToken }}
- name: INGEST_REPOSITORY_AUTH_TOKEN
  value: {{ . | quote }}
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
{{- with (.kafkaSSL | default $.Values.config.kafkaSSL) }}
- name: INGEST_KAFKA_SSL
  value: {{ . | quote }}
{{- end }}
{{- with (.kafkaSSLSkipVerify | default $.Values.config.kafkaSSLSkipVerify) }}
- name: INGEST_KAFKA_SSL_SKIP_VERIFY
  value: {{ . | quote }}
{{- end }}
{{- with (.kafkaSASL | default $.Values.config.kafkaSASL) }}
- name: INGEST_KAFKA_SASL
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
  {{- end }}
{{- end }}
{{- if and (not .rotorURL) (not $.Values.config.rotorURL) $.Values.rotor.enabled }}
- name: INGEST_ROTOR_URL
  value: {{ printf "http://%s-rotor:%d" (include "jitsu.fullname" $) (int $.Values.rotor.service.port) | quote }}
{{- end }}
{{- with (.rotorURL | default $.Values.config.rotorURL) }}
- name: INGEST_ROTOR_URL
  value: {{ . | quote }}
{{- end }}
{{- if and (not .redisURL) (not $.Values.config.redisURL) $.Values.redis.enabled }}
- name: INGEST_REDIS_URL
  value: {{ printf "redis://%s-redis-master:6379" $.Release.Name | quote }}
{{- end }}
{{- with (.redisURL | default $.Values.config.redisURL) }}
- name: INGEST_REDIS_URL
  value: {{ . | quote }}
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
