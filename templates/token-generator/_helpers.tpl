{{- define "jitsu.tokenGenerator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-token-generator" (include "jitsu.fullname" .)) .Values.tokenGenerator.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tokenGenerator.serviceAccount.name }}
{{- end }}
{{- end }}
