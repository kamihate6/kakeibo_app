create table budget_items (

    id uuid primary key
        default gen_random_uuid(),

    budget_plan_id uuid not null
        references budget_plans(id)
        on delete cascade,

    category_id uuid not null
        references categories(id),

    user_id uuid
        references auth.users(id),

    scope text not null
        check (
            scope in (
                'HOUSEHOLD',
                'PERSONAL'
            )
        ),

    yearly_amount bigint,

    created_at timestamptz not null
        default now(),

    updated_at timestamptz not null
        default now()
);