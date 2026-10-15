create table expense_splits (

    id uuid primary key
        default gen_random_uuid(),

    expense_id uuid not null
        references expenses(id)
        on delete cascade,

    category_id uuid not null
        references categories(id),

    amount bigint not null
        check (amount > 0),

    created_at timestamptz not null
        default now()
);