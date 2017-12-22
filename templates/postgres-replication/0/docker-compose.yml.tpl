version: '2'
services:
  postgres-lb-master:
    image: rancher/lb-service-haproxy
    ports:
      - ${lb_port}
    {{- if ne .Values.label_master ""}}
    labels:
      io.rancher.scheduler.affinity:host_label: ${label_master}
    {{- end}}

  postgres-lb-slave:
    image: rancher/lb-service-haproxy
    ports:
      - ${lb_port}
    {{- if ne .Values.label_slave ""}}
    labels:
      io.rancher.scheduler.affinity:host_label: ${label_slave}
    {{- end}}

  postgres-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    volumes:
      - pgdata:/var/lib/postgresql/data/pgdata

  postgres-master:
    image: 'danieldent/postgres-replication'
    environment:
      POSTGRES_DB: ${postgres_db}
      POSTGRES_USER: ${postgres_user}
      POSTGRES_PASSWORD: ${postgres_password}
      PGDATA: '/var/lib/postgresql/data/pgdata'
    tty: true
    stdin_open: true
    labels:
      io.rancher.sidekicks: postgres-data
    {{- if ne .Values.host_label ""}}
      io.rancher.scheduler.affinity:host_label: ${host_label}
    {{- end}}
    volumes_from:
      - postgres-data
    expose:
     - '5432'

  postgres-slave:
    image: 'danieldent/postgres-replication'
    environment:
      POSTGRES_DB: ${postgres_db}
      POSTGRES_USER: ${postgres_user}
      POSTGRES_PASSWORD: ${postgres_password}
      PGDATA: '/var/lib/postgresql/data/pgdata'
      REPLICATE_FROM: 'pg-master'
    tty: true
    stdin_open: true
    labels:
      io.rancher.sidekicks: postgres-data
    {{- if ne .Values.host_label ""}}
      io.rancher.scheduler.affinity:host_label: ${host_label}
    {{- end}}
    volumes_from:
      - postgres-data
    expose:
     - '5432'
    links:
     - 'pg-master'
volumes:
  pgdata:
    driver: local
    per_container: true
