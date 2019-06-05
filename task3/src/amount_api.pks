create or replace package amount_api_pkg is

    RC_DATE_IS_NULL         constant number := -20100;
    RC_AMOUNT_IS_NULL       constant number := -20101;
    RC_SUBS_IS_NULL         constant number := -20102;
    RC_VOUCHER_IS_NULL      constant number := -20103;
    RC_SUBS_NOT_EXISTS      constant number := -20104;
    RC_VOUCH_EXISTS         constant number := -20105;
    RC_SUBS_LOCKED          constant number := -20106;
    RC_ALL_IS_OKAY          constant number := 0;

    STATUS_READY            constant number := 1;
    STATUS_ERROR            constant number := 2;
    STATUS_PROCESSED        constant number := 3;

    -- процедура вставки коллекции записей
    procedure insert_records(p_rec_table in out nocopy amount_tab);

    -- процедура процессинга определенного количества строк интерфейса
    -- если p_line_count = NULL, обрабатываем всю таблицу
    procedure process_interface(p_line_count in number default null);

    -- процедура очистки выполненных/ошибочных записей
    PROCEDURE purge_records(p_rec_type in number default STATUS_PROCESSED);

end amount_api_pkg;
/