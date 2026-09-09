{{- define "jitsu.profiles.selectorLabels" -}}
app.kubernetes.io/component: profiles
{{- end }}

{{- define "jitsu.profiles.env" -}}
{{- with .Values.profiles.config -}}
- name: ROTOR_MODE
  value: "profiles"

{{- if or .databaseUrlFrom $.Values.config.databaseUrlFrom }}
- name: DATABASE_URL
  valueFrom:
    {{- toYaml (.databaseUrlFrom | default $.Values.config.databaseUrlFrom) | nindent 4 }}
{{- else }}
- name: DATABASE_URL
  value: {{ .databaseUrl | default (include "jitsu.databaseUrl" $) | quote }}
{{- end }}

- name: INSTANCES_COUNT
  value: {{ .instancesCount | default $.Values.profiles.replicaCount | quote }}

{{- with .mongodbTimeoutMs }}
- name: MONGODB_TIMEOUT_MS
  value: {{ . | quote }}
{{- end }}

{{- with .warehouseTimeoutMs }}
- name: WAREHOUSE_TIMEOUT_MS
  value: {{ . | quote }}
{{- end }}

{{- with .udfTimeoutMs }}
- name: UDF_TIMEOUT_MS
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
