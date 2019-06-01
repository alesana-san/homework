declare
    cursor get_payments(p_count in number) is
        select t_test_pay_rec(CLNT_ID
                            , SUBS_ID
                            , sum(case when rn <= p_count then pay_sum else 0 end)
            )
        from (
                 select e.CLNT_ID
                      , e.SUBS_ID
                      , e.PAY_SUM
                      , row_number() over (partition by e.SUBS_ID order by e.PAY_DATE asc) rn
                 from TEST_PAY e
                 where e.DEL_DATE is null)
        group by SUBS_ID, CLNT_ID;

    l_pay_count     constant number := 10;      -- число платежей с каждого абонента в выборке
    l_fetch_count   constant number := 10000;   -- размер пачки, которую фетчим за раз
    l_rec_position  constant number := 3;       -- какую строку по счету вставляем

    l_tab           t_test_pay_tab := t_test_pay_tab();
    l_tab_count     number;
    l_fetch_idx     number := 0;
begin
    open get_payments(l_pay_count);

    loop
        l_tab.delete;
        fetch get_payments
            bulk collect
            into l_tab
            limit l_fetch_count;

        l_tab_count := l_tab.count;
        exit when l_tab.count = 0;

        insert into TEST_DATA(N, CLNT_ID, SUBS_ID, ALL_PAY_SUM)
        select test_data_seq.nextval
             , clnt_id
             , subs_id
             , all_pay_sum
        from (
            select l_fetch_idx + rownum rn
                 , e.clnt_id
                 , e.subs_id
                 , e.all_pay_sum
                from table(l_tab) e
            )
        where mod(rn,3) = 0;

        -- запоминаем количество отфетченых записей,
        -- чтобы на следующих итерациях правильно брать остаток от деления на 3
        l_fetch_idx := l_fetch_idx + l_tab_count;

        commit;
    end loop;

    -- в блоке exception не закрываем курсор на случай ошибок,
    -- поскольку по завершении выполнения анонимного блока
    -- оракл сам закроет все курсоры
    close get_payments;

exception
    when others then
        rollback;
        dbms_output.put_line(DBMS_UTILITY.format_error_backtrace);
end;
/