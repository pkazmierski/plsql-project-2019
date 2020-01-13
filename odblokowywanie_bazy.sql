SELECT object_name, s.sid, s.serial#, p.spid 
FROM v$locked_object l, dba_objects o, v$session s, v$process p
WHERE l.object_id = o.object_id AND l.session_id = s.sid AND s.paddr = p.addr;

ALTER SYSTEM KILL SESSION '446, 39219'; --`sid` and `serial#` get from step 1