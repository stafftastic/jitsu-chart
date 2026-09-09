{{- define "jitsu.seed.env" -}}
{{- with .Values.console.config -}}
{{- if or .databaseUrlFrom $.Values.config.databaseUrlFrom }}
- name: DATABASE_URL
  valueFrom:
    {{- toYaml (.databaseUrlFrom | default $.Values.config.databaseUrlFrom) | nindent 4 }}
{{- else }}
- name: DATABASE_URL
  value: {{ .databaseUrl | default (include "jitsu.databaseUrl" $) | quote }}
{{- end }}

{{- if .jwtSecretFrom }}
- name: JWT_SECRET
  valueFrom:
    {{- toYaml .jwtSecretFrom | nindent 4 }}
{{- else }}
{{- if and (not .jwtSecret) $.Values.tokenGenerator.enabled }}
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ include "jitsu.fullname" $ }}-tokens
      key: jwtSecret
{{- end }}
{{- with .jwtSecret }}
- name: JWT_SECRET
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if or .globalHashSecretFrom $.Values.config.globalHashSecretFrom }}
- name: GLOBAL_HASH_SECRET
  valueFrom:
    {{- toYaml (.globalHashSecretFrom | default $.Values.config.globalHashSecretFrom) | nindent 4 }}
{{- else }}
{{- if and (not .globalHashSecret) (not $.Values.config.globalHashSecret) $.Values.tokenGenerator.enabled }}
- name: GLOBAL_HASH_SECRET
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

{{- if .seedUserEmailFrom }}
- name: SEED_USER_EMAIL
  valueFrom:
    {{- toYaml .seedUserEmailFrom | nindent 4 }}
{{- else }}
{{- with .seedUserEmail }}
- name: SEED_USER_EMAIL
  value: {{ . | quote }}
{{- end }}
{{- end }}

{{- if .seedUserPasswordFrom }}
- name: SEED_USER_PASSWORD
  valueFrom:
    {{- toYaml .seedUserPasswordFrom | nindent 4 }}
{{- else }}
{{- with .seedUserPassword }}
- name: SEED_USER_PASSWORD
  value: {{ . | quote }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
