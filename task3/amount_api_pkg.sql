create or replace package amount_api_pkg is

    RC_DATE_IS_NULL         constant number := -20100;
    RC_AMOUNT_IS_NULL       constant number := -20101;
    RC_SUBS_IS_NULL         constant number := -20102;
    RC_VOUCHER_IS_NULL      constant number := -20103;
    RC_SUBS_NOT_EXISTS      constant number := -20104;
    RC_VOUCH_EXISTS         constant number := -20105;
    RC_SUBS_LOCKED          constant number := -20106;
    RC_ALL_IS_OKAY          constant number := 0;

    -- процедура вставки коллекции записей
    procedure insert_records(p_rec_table in out nocopy amount_tab);

    -- процедура процессинга определенного количества строк интерфейса
    -- если p_line_count = NULL, обрабатываем всю таблицу
    procedure process_interface(p_line_count in number default null);

end amount_api_pkg;