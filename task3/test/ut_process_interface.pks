create or REPLACE package ut_process_interface is

    -- %rollback(manual)
    -- %suite(Тесты процедуры вставки записей)
    -- %suitepath(berkut.test.amount_api_pkg.process_interface)
    -- %beforeall(clean)
    -- %aftereach(clean)

    -- %test(Тест базового использования)
    -- %rollback(manual)
    PROCEDURE basic_usage;

    -- %test(Наличие дубликатов в одном прогоне)
    -- %rollback(manual)
    PROCEDURE duplicate_in_a_single_collection;

    PROCEDURE clean;
end;
/