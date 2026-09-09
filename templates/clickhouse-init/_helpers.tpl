{{- define "jitsu.clickhouseInit.env" -}}
{{- with .Values.console.config -}}
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

{{- if or .clickhouseClusterFrom $.Values.config.clickhouseClusterFrom }}
- name: CLICKHOUSE_CLUSTER
  valueFrom:
    {{- toYaml (.clickhouseClusterFrom | default $.Values.config.clickhouseClusterFrom) | nindent 4 }}
{{- else if or .clickhouseCluster $.Values.config.clickhouseCluster }}
- name: CLICKHOUSE_CLUSTER
  value: {{ .clickhouseCluster | default $.Values.config.clickhouseCluster | quote }}
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
{{- end }}
{{- end }}
