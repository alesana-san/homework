drop table subscribers;
create table subscribers (
    subscriber_id               number primary key,
    current_amount              number(15,2) not null,
    subscriber_name             varchar2(100)
);

comment on table subscribers is 'Таблица абонентов';
comment on column subscribers.subscriber_id is 'Уникальный идентификатор абонента';
comment on column subscribers.current_amount is 'Текущий баланс абонента';
comment on column subscribers.subscriber_name is 'Имя абонента';

create sequence subs_seq;
