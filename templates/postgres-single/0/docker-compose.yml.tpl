version: '2'
services:
  postgres:
    image: postgres:${POSTGRES_TAG}
    environment:
      PGDATA: /var/lib/postgresql/data/pgdata
      POSTGRES_DB: ${postgres_db}
      POSTGRES_USER: ${postgres_user}
      POSTGRES_PASSWORD: ${postgres_password}
    tty: true
    stdin_open: true
{{- if ne .Values.host_label ""}}
    labels:
      io.rancher.scheduler.affinity:host_label: ${host_label}
{{- end}}
{{- if ne .Values.port ""}}
    ports:
      - "${port}:5432"
{{- end}}
    volumes:
      - /var/lib/postgresql/data/pgdata
