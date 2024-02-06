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
- name: INGEST_REDIS_URL
  value: {{ .redisUrl | default (include "jitsu.redisUrl" $) | quote }}
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
{{- with .rawAuthTokens }}
- name: INGEST_RAW_AUTH_TOKENS
  value: {{ . | quote }}
{{- end }}
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
{{- with (.kafkaSasl | default $.Values.config.kafkaSasl) }}
- name: INGEST_KAFKA_SASL
  {{- if kindIs "string" . }}
  value: {{ . | quote }}
  {{- else }}
  value: {{ toJson . | quote }}
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
