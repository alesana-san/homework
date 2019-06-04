drop table amount_interface_lines;
create table amount_interface_lines (
    subscriber_id       number,
    voucher_code        varchar2(100),
    change_amount       number(15,2),
    change_date         date,
    line_status         number,
    error_text          varchar2(4000)
);

comment on table amount_interface_lines is 'Интерфейсная таблица загрузки платежей/списаний';
comment on column amount_interface_lines.subscriber_id is 'Уникальный идентификатор группы платежей/списаний';
comment on column amount_interface_lines.voucher_code is 'Логический ключ изменения внутри группы';
comment on column amount_interface_lines.change_amount is 'Сумма изменения';
comment on column amount_interface_lines.change_date is 'Дата изменения';
comment on column amount_interface_lines.line_status is 'Статус текущей записи';
comment on column amount_interface_lines.error_text is 'Текст ошибки процессинга записи';