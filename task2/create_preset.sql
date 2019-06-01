create table test (
    n number primary key
);

create table test_log (
    n number primary key
);

truncate table test;

insert into test
select level
from dual
connect by level <= 23;

truncate table test_log;

insert into test_log values(8);

commit;

-- на текущих тестовых данных предполагается,
-- что строки с N = {1..7} в таблице TEST примут значения {0..6} соответственно
-- значения от 8 до 23 останутся неизменными
-- в таблицу test_log добавятся записи с N={1..7}