drop table amount_history;
create table amount_history (
    subscriber_id       number not null references subscribers,
    voucher_code        varchar2(100) not null,
    change_amount       number(15,2) not null,
    change_date         date not null
);

comment on table amount_history is 'Таблица истории изменения баланса';
comment on column amount_history.subscriber_id is 'Ссылка на абонента';
comment on column amount_history.voucher_code is 'Логически уникальный код платежа/списания в разрезе абонента (например, номер чека)';
comment on column amount_history.change_amount is 'Величина изменения баланса';
comment on column amount_history.change_date is 'Дата изменения';

create unique index amount_history_u1 on amount_history(subscriber_id, voucher_code);