{{/*
Expand the name of the chart.
*/}}
{{- define "generic-webservice.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "generic-webservice.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "generic-webservice.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "generic-webservice.labels" -}}
helm.sh/chart: {{ include "generic-webservice.chart" . }}
{{ include "generic-webservice.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "generic-webservice.selectorLabels" -}}
app.kubernetes.io/name: {{ include "generic-webservice.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "generic-webservice.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "generic-webservice.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{- /*
  Renders text content that can be mounted into a file in a pod.
  Based on https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/4.1.0/jupyterhub/templates/_helpers.tpl#L426-L450
*/}}
{{- define "extraFiles.text.withNewLineSuffix" -}}
    {{- range $file_key, $file_details := . }}
        {{- if or (not ($file_details.mountPath)) (not ($file_details.text)) }}
            {{- print "\n\nextraFiles entries (" $file_key ") must contain the fields mountPath and text." | fail }}
        {{- end }}
        {{- $file_name := $file_details.mountPath | base }}
        {{- if $file_details.text }}
            {{- $file_key | quote }}: |
              {{- $file_details.text | trimSuffix "\n" | nindent 2 }}{{ println }}
        {{- end }}
    {{- end }}
{{- end }}
{{- define "extraFiles.text" -}}
    {{- include "extraFiles.text.withNewLineSuffix" . | trimSuffix "\n" }}
{{- end }}
