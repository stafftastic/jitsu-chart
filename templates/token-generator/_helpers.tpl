{{- define "jitsu.tokenGenerator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (printf "%s-token-generator" (include "jitsu.fullname" .)) .Values.tokenGenerator.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.tokenGenerator.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "jitsu.tokenGenerator.image" -}}
{{- if .Values.tokenGenerator.image.tag -}}
"{{ .Values.tokenGenerator.image.repository }}:{{ .Values.tokenGenerator.image.tag }}"
{{- else -}}
{{- $v := semver .Capabilities.KubeVersion.Version -}}
 "{{ .Values.tokenGenerator.image.repository }}:{{ printf "%d.%d.%d" $v.Major $v.Minor $v.Patch }}"
{{- end }}
{{- end }}
