[[inputs.mysql]]
  ## specify servers via a url matching:
  ##  [username[:password]@][protocol[(address)]]/[?tls=[true|false|skip-verify]]
  ##  see https://github.com/go-sql-driver/mysql#dsn-data-source-name
  ##  e.g.
  ##    servers = ["user:passwd@tcp(127.0.0.1:3306)/?tls=false"]
  ##    servers = ["user@tcp(127.0.0.1:3306)/?tls=false"]
  #
  ## If no servers are specified, then localhost is used as the host.
  servers = [ <%= $servers %> ]
  ## the limits for metrics form perf_events_statements
  perf_events_statements_digest_text_limit  = 120
  perf_events_statements_limit              = 250
  perf_events_statements_time_limit         = 86400
  #
  ## if the list is empty, then metrics are gathered from all database tables
  table_schema_databases                    = [ 'cpanstats', 'metabase' ]
  #
  ## gather metrics from INFORMATION_SCHEMA.TABLES for databases provided above list
  gather_table_schema                       = false
  #
  ## gather thread state counts from INFORMATION_SCHEMA.PROCESSLIST
  gather_process_list                       = true
  #
  ## gather thread state counts from INFORMATION_SCHEMA.USER_STATISTICS
  gather_user_statistics                    = true
  #
  ## gather auto_increment columns and max values from information schema
  gather_info_schema_auto_inc               = true
  #
  ## gather metrics from INFORMATION_SCHEMA.INNODB_METRICS
  gather_innodb_metrics                     = true
  #
  ## gather metrics from SHOW SLAVE STATUS command output
  gather_slave_status                       = true
  #
  ## gather metrics from SHOW BINARY LOGS command output
  gather_binary_logs                        = false
  #
  ## gather metrics from PERFORMANCE_SCHEMA.TABLE_IO_WAITS_SUMMARY_BY_TABLE
  gather_table_io_waits                     = false
  #
  ## gather metrics from PERFORMANCE_SCHEMA.TABLE_LOCK_WAITS
  gather_table_lock_waits                   = false
  #
  ## gather metrics from PERFORMANCE_SCHEMA.TABLE_IO_WAITS_SUMMARY_BY_INDEX_USAGE
  gather_index_io_waits                     = false
  #
  ## gather metrics from PERFORMANCE_SCHEMA.EVENT_WAITS
  gather_event_waits                        = false
  #
  ## gather metrics from PERFORMANCE_SCHEMA.FILE_SUMMARY_BY_EVENT_NAME
  gather_file_events_stats                  = false
  #
  ## gather metrics from PERFORMANCE_SCHEMA.EVENTS_STATEMENTS_SUMMARY_BY_DIGEST
  gather_perf_events_statements             = false
  #
  ## Some queries we may want to run less often (such as SHOW GLOBAL VARIABLES)
  interval_slow                             = "30m"
