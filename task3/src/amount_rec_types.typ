create or replace type amount_rec force is object (
    subscriber_id       number,
    voucher_code        varchar2(100),
    change_amount       number(15,2),
    change_date         date                                            
);
/
create or replace type amount_tab is table of amount_rec;
/