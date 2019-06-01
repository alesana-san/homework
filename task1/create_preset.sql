create table test_pay (
    clnt_id number,
    subs_id number,
    pay_sum number,
    pay_date date,
    del_date date
);

create sequence test_data_seq;

-- не создаю первичный/уникальный ключ на колонку N,
-- поскольку в задании не было требования об уникальности колонки
-- сэкнономим на обновлении индекса при вставке
create table test_data (
    n number,
    clnt_id number,
    subs_id number,
    all_pay_sum number
);

-- наполнение тестовыми данными
truncate table test_pay;
insert into test_pay values(1, -1, 12.50, date '2019-01-01', null);
insert into test_pay values(1, -1, 12.50, date '2019-01-01', date '2019-01-03');
insert into test_pay values(1, -2, 14.50, date '2019-01-05', null);
insert into test_pay values(1, -3, 1.50, date '2019-01-05', null);
insert into test_pay values(1, -3, 3.50, date '2019-02-06', null);

insert into test_pay values(2, -4, 11.50, date '2019-02-05', null);
insert into test_pay values(2, -5, 11.50, date '2019-02-05', null);
insert into test_pay values(2, -6, 11.50, date '2019-02-05', null);
insert into test_pay values(2, -6, 13.50, date '2019-02-06', null);
-- на данном наборе данных ожидается 2 строчки после отработки скрипта task1.sql
-- поскольку в таблице 6 уникальных абонентов, а вставиться должна каждая третья строчка (= каждый третий абонент)
-- из собранной коллекции
commit;

create or replace type t_test_pay_rec is object (
        CLNT_ID         number,
        SUBS_ID         number,
        ALL_PAY_SUM     number
);
/
create or replace type t_test_pay_tab is table of t_test_pay_rec;
/