create table budget_plans (

    id uuid primary key
        default gen_random_uuid(),

    household_id uuid not null
        references households(id),

    name text not null,

    version integer not null,

    effective_from date not null,

    effective_to date,

    status text not null
        check (
            status in (
                'DRAFT',
                'ACTIVE',
                'CLOSED'
            )
        ),

    change_reason text,

    created_by uuid not null
        references auth.users(id),

    created_at timestamptz not null
        default now(),

    updated_at timestamptz not null
        default now(),

    unique (
        household_id,
        version
    )
);