--login as sysdba
CREATE USER hotel IDENTIFIED BY oracle;
GRANT CONNECT, RESOURCE, DBA TO hotel;
GRANT ALL PRIVILEGES TO hotel;
GRANT UNLIMITED TABLESPACE TO hotel;