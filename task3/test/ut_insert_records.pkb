create or REPLACE package body ut_insert_records is

    PROCEDURE basic_usage
    is
        l_tab   amount_tab;
        l_count number;
    begin
        l_tab := amount_tab(
                amount_rec(
                    -1,
                    'test_code',
                    10,
                    sysdate
                ),
                amount_rec(
                    -1,
                    'test_code',
                    10,
                    sysdate
                )
            );

        amount_api_pkg.INSERT_RECORDS(l_tab);

        select count(*)
        into l_count
        from amount_interface_lines;

        ut.EXPECT(l_count).TO_EQUAL(2);
    end;

    PROCEDURE null_tab
    IS
        l_tab   amount_tab := null;
        l_count number;
    BEGIN

        amount_api_pkg.INSERT_RECORDS(l_tab);

        select count(*)
        into l_count
        from amount_interface_lines;

        ut.EXPECT(l_count).TO_EQUAL(0);
    END;

    PROCEDURE clean
    IS
    BEGIN
        delete amount_interface_lines;
        delete AMOUNT_HISTORY;
        delete SUBSCRIBERS;
    END;
end;
/