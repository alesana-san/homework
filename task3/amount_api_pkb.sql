create or replace package body amount_api_pkg is

    type t_int_tab is table of amount_interface_lines%rowtype;

    dml_errors   EXCEPTION;
    PRAGMA EXCEPTION_INIT (dml_errors, -24381);

    resource_busy   EXCEPTION;
    PRAGMA EXCEPTION_INIT (resource_busy, -54);

    function get_error_text(p_err_code in number) return varchar2
    is
        l_text_msg  varchar2(4000);
    begin
        l_text_msg := case p_err_code
            when RC_DATE_IS_NULL
                then 'Payment date is null'
            when RC_AMOUNT_IS_NULL
                then 'Payment amount is null'
            when RC_SUBS_IS_NULL
                then 'Subscriber is not set'
            when RC_VOUCHER_IS_NULL
                then 'Payment voucher is not set'
            when RC_SUBS_NOT_EXISTS
                then 'Subscriber doesn''t exist'
            when RC_VOUCH_EXISTS
                then 'This payment was already processed'
            when RC_SUBS_LOCKED
                then 'Subscriber record is locked at the moment'
            when RC_ALL_IS_OKAY
                then null
            else
                null
        end;

        return l_text_msg;
    end;

    -- процедура вставки коллекции записей
    procedure insert_records(p_rec_table in out nocopy amount_tab)
    is
    begin
        insert into amount_interface_lines (
            subscriber_id,
            voucher_code,
            change_amount,
            change_date,
            line_status
        )
        select e.subscriber_id
             , e.voucher_code
             , e.change_amount
             , e.change_date
             , STATUS_READY
       from table(p_rec_table) e;
    end;

    -- процедура валидации одиночной записи
    procedure validate_record(
        p_rec           in  amount_interface_lines%rowtype,
        x_result_code   out number
    )
    is
        l_error_code    number;
        l_check         number;
    begin
        if p_rec.CHANGE_DATE is null then
            l_error_code := RC_DATE_IS_NULL;
        elsif p_rec.CHANGE_AMOUNT is null then
            l_error_code := RC_AMOUNT_IS_NULL;
        elsif p_rec.SUBSCRIBER_ID is null then
            l_error_code := RC_SUBS_IS_NULL;
        elsif p_rec.VOUCHER_CODE is null then
            l_error_code := RC_VOUCHER_IS_NULL;
        end if;

        if l_error_code is null then
            begin
                select 1
                into l_check
                from SUBSCRIBERS s
                where s.SUBSCRIBER_ID = p_rec.SUBSCRIBER_ID;
            exception
                when no_data_found then
                    l_error_code := RC_SUBS_NOT_EXISTS;
            end;
        end if;

        if l_error_code is null then
            begin
                select 1
                into l_check
                from AMOUNT_HISTORY s
                where s.SUBSCRIBER_ID = p_rec.SUBSCRIBER_ID
                  and s.VOUCHER_CODE = p_rec.VOUCHER_CODE;

                l_error_code := RC_VOUCH_EXISTS;
            exception
                when no_data_found then
                    null;
            end;
        end if;

        x_result_code := nvl(l_error_code, RC_ALL_IS_OKAY);
    end;

    -- функция вернет true в случае успешной блокировки строки абонента, иначе false
    function lock_subs_row(p_subs_id in number) return boolean
    is
        l_check number;
    begin
        select 1
        into l_check
        from SUBSCRIBERS s
        where s.SUBSCRIBER_ID = p_subs_id
        for update nowait;

        return true;
    exception
        when resource_busy then
            return false;
        when no_data_found then
            return false;
    end;

    -- процедура процессинга определенного количества строк интерфейса
    procedure process_interface(p_line_count in number)
    is

        l_int_rec_tab       t_int_tab;
        l_err_rec_tab       t_int_tab;
        l_rdy_rec_tab       t_int_tab;
        l_rec               amount_interface_lines%rowtype;
        l_result_code       number;
        l_idx               number;
    begin
        select e.*
        bulk collect
        into l_int_rec_tab
        from amount_interface_lines e
        where 1=1
        and e.line_status = STATUS_READY
        and (rownum <= p_line_count or p_line_count is null)
        for update skip locked;

        if l_int_rec_tab.count > 0 then

            for i in l_int_rec_tab.first .. l_int_rec_tab.last
            loop
                l_rec := l_int_rec_tab(i);
                validate_record(l_rec, l_result_code);

                if l_result_code != RC_ALL_IS_OKAY then
                    l_rec.error_code := l_result_code;
                    l_rec.ERROR_TEXT := get_error_text(l_result_code);
                    l_rec.LINE_STATUS := STATUS_ERROR;

                    l_err_rec_tab.extend;
                    l_err_rec_tab(l_err_rec_tab.count + 1) := l_rec;
                elsif lock_subs_row(l_rec.SUBSCRIBER_ID) = false then
                    l_rec.error_code := RC_SUBS_LOCKED;
                    l_rec.ERROR_TEXT := get_error_text(l_rec.error_code);
                    l_rec.LINE_STATUS := STATUS_ERROR;

                    l_err_rec_tab.extend;
                    l_err_rec_tab(l_err_rec_tab.count + 1) := l_rec;
                else
                    l_rec.LINE_STATUS := STATUS_PROCESSED;
                    l_rdy_rec_tab(l_rdy_rec_tab.count + 1) := l_rec;
                end if;

            end loop;

            l_int_rec_tab.delete;

            if l_rdy_rec_tab.count > 0 then
                begin
                    forall i in l_rdy_rec_tab.first .. l_rdy_rec_tab.last
                        save exceptions
                    insert into amount_history(
                        SUBSCRIBER_ID
                      , VOUCHER_CODE
                      , CHANGE_AMOUNT
                      , CHANGE_DATE)
                    values(
                        l_rdy_rec_tab(i).SUBSCRIBER_ID
                      , l_rdy_rec_tab(i).VOUCHER_CODE
                      , l_rdy_rec_tab(i).CHANGE_AMOUNT
                      , l_rdy_rec_tab(i).CHANGE_DATE
                    );
                exception
                    when dml_errors then
                      FOR idx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
                      LOOP
                        l_idx := SQL%BULK_EXCEPTIONS (idx).ERROR_INDEX;
                        l_rec := l_rdy_rec_tab(l_idx);
                        l_rec.error_code := SQL%BULK_EXCEPTIONS (idx).ERROR_CODE;
                        l_rec.ERROR_TEXT := sqlerrm(l_rec.error_code);
                        l_rec.LINE_STATUS := STATUS_ERROR;

                        l_err_rec_tab.extend;
                        l_err_rec_tab(l_err_rec_tab.count + 1) := l_rec;

                        l_rdy_rec_tab.delete(l_idx);
                      END LOOP;
                end;

                forall i in indices of l_rdy_rec_tab
                update SUBSCRIBERS s
                set s.CURRENT_AMOUNT = s.CURRENT_AMOUNT + l_rdy_rec_tab(i).CHANGE_AMOUNT
                where s.SUBSCRIBER_ID = l_rdy_rec_tab(i).SUBSCRIBER_ID;

                forall i in indices of l_rdy_rec_tab
                update amount_interface_lines s
                set s.LINE_STATUS = l_rdy_rec_tab(i).LINE_STATUS
                where s.SUBSCRIBER_ID = l_rdy_rec_tab(i).SUBSCRIBER_ID
                  and s.VOUCHER_CODE =  l_rdy_rec_tab(i).VOUCHER_CODE;

            end if;

            if l_err_rec_tab.count > 0 then
                begin
                    forall i in l_err_rec_tab.first .. l_err_rec_tab.last
                    update amount_interface_lines e
                    set e.ERROR_TEXT = l_err_rec_tab(i).ERROR_TEXT
                      , e.error_code = l_err_rec_tab(i).error_code
                      , e.LINE_STATUS = l_err_rec_tab(i).LINE_STATUS
                    where e.VOUCHER_CODE = l_err_rec_tab(i).VOUCHER_CODE
                    and e.SUBSCRIBER_ID = l_err_rec_tab(i).SUBSCRIBER_ID;
                exception
                    when others then
                        null;
                end;
            end if;

        end if;

        commit;

    exception
        when others then
            null;
    end;

end amount_api_pkg;