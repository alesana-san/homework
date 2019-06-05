create or REPLACE package body ut_process_interface is


    PROCEDURE basic_usage
    IS
        l_count number;
    BEGIN
        -- создаем абонента
        insert into SUBSCRIBERS(SUBSCRIBER_ID, CURRENT_AMOUNT, SUBSCRIBER_NAME)
            values(-1, 0, 'test');

        -- создаем строки в интерфейсе
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval, -1, 'some code', 10, date '2019-01-01', amount_api_pkg.STATUS_READY);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval, -2, 'some code', 10, date '2019-01-01', amount_api_pkg.STATUS_READY);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval, NULL, 'some code', 10, date '2019-01-01', amount_api_pkg.STATUS_READY);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval,-1, NULL, 10, date '2019-01-01', amount_api_pkg.STATUS_READY);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval,-1, 'some code', NULL, date '2019-01-01', amount_api_pkg.STATUS_READY);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval,-1, 'some code', 10, NULL, amount_api_pkg.STATUS_READY);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval,-10, 'some code', 10, NULL, amount_api_pkg.STATUS_ERROR);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval,-20, 'some code', 10, NULL, amount_api_pkg.STATUS_PROCESSED);

        amount_api_pkg.PROCESS_INTERFACE(NULL);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -1
        and e.LINE_STATUS = amount_api_pkg.STATUS_PROCESSED;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -2
        and e.LINE_STATUS = amount_api_pkg.STATUS_ERROR
        and e.ERROR_CODE = amount_api_pkg.RC_SUBS_NOT_EXISTS;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID is null
        and e.LINE_STATUS = amount_api_pkg.STATUS_ERROR
        and e.ERROR_CODE = amount_api_pkg.RC_SUBS_IS_NULL;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -1
        and e.LINE_STATUS = amount_api_pkg.STATUS_ERROR
        and e.ERROR_CODE = amount_api_pkg.RC_VOUCHER_IS_NULL;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -1
        and e.LINE_STATUS = amount_api_pkg.STATUS_ERROR
        and e.ERROR_CODE = amount_api_pkg.RC_AMOUNT_IS_NULL;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -1
        and e.LINE_STATUS = amount_api_pkg.STATUS_ERROR
        and e.ERROR_CODE = amount_api_pkg.RC_DATE_IS_NULL;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -10
        and e.LINE_STATUS = amount_api_pkg.STATUS_ERROR;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -20
        and e.LINE_STATUS = amount_api_pkg.STATUS_PROCESSED;

        ut.EXPECT(l_count).TO_EQUAL(1);


    END;

    PROCEDURE duplicate_in_a_single_collection
    IS
        l_count number;
    BEGIN
        -- создаем абонента
        insert into SUBSCRIBERS(SUBSCRIBER_ID, CURRENT_AMOUNT, SUBSCRIBER_NAME)
            values(-1, 0, 'test');

        -- создаем строки в интерфейсе
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval, -1, 'some code', 10, date '2019-01-01', amount_api_pkg.STATUS_READY);
        insert into AMOUNT_INTERFACE_LINES(SEQ_ID, SUBSCRIBER_ID, VOUCHER_CODE, CHANGE_AMOUNT, CHANGE_DATE, LINE_STATUS)
            values(int_seq.nextval, -1, 'some code', 10, date '2019-01-01', amount_api_pkg.STATUS_READY);

        amount_api_pkg.PROCESS_INTERFACE(NULL);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -1
        and e.LINE_STATUS = amount_api_pkg.STATUS_PROCESSED;

        ut.EXPECT(l_count).TO_EQUAL(1);

        select count(*)
        into l_count
        from AMOUNT_INTERFACE_LINES e
        where e.SUBSCRIBER_ID = -1
        and e.LINE_STATUS = amount_api_pkg.STATUS_ERROR;

        ut.EXPECT(l_count).TO_EQUAL(1);

    END;

    PROCEDURE clean
    IS
    BEGIN
        delete amount_interface_lines;
        delete AMOUNT_HISTORY;
        delete SUBSCRIBERS;
        --COMMIT;
    END;
end;
/