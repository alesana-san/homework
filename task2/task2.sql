declare
    l_commit_step   constant number := 5;
begin
    for i in 1 .. 23 loop
        savepoint step_start;

        begin
            update test
            set n = i-1 -- эквивалентно n-1
            where n = i;

            insert into test_log values (i);
        exception
            when others then
                rollback to step_start;
        end;

        if mod(i, l_commit_step) = 0 then
            commit;
        end if;
    end loop;

    commit;
end;