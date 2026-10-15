create table budget_monthly (

    budget_item_id uuid not null
        references budget_items(id)
        on delete cascade,

    year integer not null,

    month integer not null
        check (
            month between 1 and 12
        ),

    target_amount bigint not null
        check (
            target_amount >= 0
        ),

    primary key (
        budget_item_id,
        year,
        month
    )
);