{{/*
Profiles selector labels
*/}}
{{- define "jitsu.profiles.selectorLabels" -}}
app.kubernetes.io/component: profiles
{{- end }}

{{/*
Profile Builder runs the rotor image in "profiles" mode and shares the
backend configuration of the rotor (jitsu.rotor.env). Only the extra
environment variables specific to the profiles mode are defined here.
*/}}
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

{{- with .instancesCount }}
- name: INSTANCES_COUNT
  value: {{ . | quote }}
{{- end }}

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
