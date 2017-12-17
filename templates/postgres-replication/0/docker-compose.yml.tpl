version: '2'
services:
  postgres-lb:
    image: rancher/lb-service-haproxy
    ports:
      - ${lb_port}
    {{- if ne .Values.host_label ""}}
    labels:
      io.rancher.scheduler.affinity:host_label: ${host_label}
    {{- end}}

  postgres-data:
    image: busybox
    labels:
      io.rancher.container.start_once: true
    {{- if ne .Values.host_label ""}}
      io.rancher.scheduler.affinity:host_label: ${host_label}
    {{- end}}
    volumes:
      - pgdata:/var/lib/postgresql/data/pgdata
  pg-master:
    image: 'danieldent/postgres-replication'
    environment:
      POSTGRES_USER: ${pg_user}
      POSTGRES_PASSWORD: ${pg_password}
      PGDATA: '/var/lib/postgresql/data/pgdata'
    volumes:
     - '/var/lib/postgresql/data'
    expose:
     - '5432'
  pg-slave:
    image: 'danieldent/postgres-replication'
    environment:
      POSTGRES_USER: ${slave_user}
      POSTGRES_PASSWORD: ${slave_user}
      PGDATA: '/var/lib/postgresql/data/pgdata'
      REPLICATE_FROM: 'pg-master'
    volumes:
     - '/var/lib/postgresql/data'
    expose:
     - '5432'
    links:
     - 'pg-master'
