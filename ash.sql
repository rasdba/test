SELECT NVL(a.event, 'ON CPU') AS event,
       COUNT(*) AS total_wait_time
FROM   DBA_HIST_ACTIVE_SESS_HISTORY a
WHERE  sample_time between to_date('19/04/2025 06:50','dd/mm/yyyy hh24:mi') and to_date('19/04/2025 10:20','dd/mm/yyyy hh24:mi')
GROUP BY a.event
ORDER BY total_wait_time DESC;

--with percentage
SELECT event, 
       count(*) as waits,
       round(count(*) * 100 / sum(count(*)) over(), 2) as pct
FROM v$active_session_history
WHERE sample_time > sysdate - interval '15' minute
GROUP BY event
ORDER BY waits DESC;

--sql_id
SELECT sql_id, count(*) 
FROM v$active_session_history 
WHERE sample_time > sysdate - (1/24/60) 
GROUP BY sql_id 
ORDER BY 2 DESC;


--last 5 mins events
SELECT NVL(a.event, 'ON CPU') AS event,
       COUNT(*) AS total_wait_time
FROM   v$active_session_history a
WHERE  a.sample_time > SYSDATE - 5/(24*60) -- 5 mins
GROUP BY a.event
ORDER BY total_wait_time DESC;

--last day from dba_hist.
SELECT NVL(a.event, 'ON CPU') AS event,
       COUNT(*)*10 AS total_wait_time
FROM   dba_hist_active_sess_history a
WHERE  a.sample_time > SYSDATE - 1 
GROUP BY a.event
ORDER BY total_wait_time DESC;

--sessions last 30 days
select a.username, b.* from dba_users a,
(select user_id, MACHINE, count(*)
  from DBA_HIST_ACTIVE_SESS_HISTORY
 where SAMPLE_TIME > (sysdate - 30)
 group by user_id, MACHINE) b
 where a.user_id=b.user_id
 order by 1,3

--sessions pga
select sql_id, sum(round(pga_allocated/1024/1024,0)) as ssize,count(1) from dba_hist_active_sess_histiry
where sample_time between to_date('26.07.2016 22:20:00','dd.mm.yyyy hh24:mi') and to_date('26.07.2016 22:20:05','dd.mm.yyyy hh24:mi:ss')
and pga_allocated is not null and sql_id is not null
group by sql_id order by ssize desc;
                         
 select event,count(1)/60 from gv$active_session_history
 where wait_class = 'Other' and
 sample_time between sysdate - interval '1' minute and sysdate
 group by event
 order by count(1)/60 desc;
 
 select event,machine,program,sql_id,top_level_sql_id,count(1)/60 from dba_hist_active_sess_history
 where wait_class = 'Concurrency' 
 and sample_time between sysdate - interval '1' hour and sysdate
 group by event,machine,program,sql_id,top_level_sql_id
 order by count(1)/60 desc;
 
select current_obj#,count(1)/60 from gv$active_session_history
 where wait_class = 'Concurrency' 
 and sample_time between sysdate - interval '1' minute and sysdate
 group by current_obj#
 order by count(1)/60 desc;
