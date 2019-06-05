create or REPLACE package ut_insert_records is

    -- %rollback(auto)
    -- %suite(Тесты процедуры вставки записей)
    -- %suitepath(berkut.test.amount_api_pkg.insert_records)
    -- %beforeeach(clean)

    -- %test(Тест базового использования)
    -- %rollback(auto)
    PROCEDURE basic_usage;

    -- %test(Передана неинициализированная коллекция)
    -- %rollback(auto)
    PROCEDURE null_tab;

    PROCEDURE clean;
end;
/