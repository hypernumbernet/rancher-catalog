version: '2'
services:
  postgres-lb-master:
    image: rancher/lb-service-haproxy
    ports:
      - ${lb_port}
    {{- if ne .Values.label_master_lb ""}}
    labels:
      io.rancher.scheduler.affinity:host_label: ${label_master_lb}
    {{- end}}

  postgres-lb-slave:
    image: rancher/lb-service-haproxy
    ports:
      - ${lb_port}
    {{- if ne .Values.label_slave_lb ""}}
    labels:
      io.rancher.scheduler.affinity:host_label: ${label_slave_lb}
    {{- end}}

  postgres-data:
    image: busybox
    labels:
      io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name
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
    {{- if ne .Values.label_master_db ""}}
      io.rancher.scheduler.affinity:host_label: ${label_master_db}
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
      REPLICATE_FROM: 'postgres-master'
    tty: true
    stdin_open: true
    labels:
      io.rancher.sidekicks: postgres-data
    {{- if ne .Values.label_slave_db ""}}
      io.rancher.scheduler.affinity:host_label: ${label_slave_db}
    {{- end}}
      io.rancher.stack_service.name=$${stack_name}/$${service_name}
      io.rancher.container.hostname_override: container_name
    volumes_from:
      - postgres-data
    expose:
     - '5432'
    links:
     - 'postgres-master'
volumes:
  pgdata:
    driver: local
    per_container: true
