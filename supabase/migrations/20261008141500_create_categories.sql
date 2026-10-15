create table categories (

    id uuid primary key
        default gen_random_uuid(),

    household_id uuid not null
        references households(id)
        on delete cascade,

    parent_category_id uuid null
        references categories(id),

    name text not null,

    type text not null
        check (
            type in (
                'HOUSEHOLD',
                'PERSONAL',
                'BOTH'
            )
        ),

    sort_order integer not null
        default 0,

    is_active boolean not null
        default true,

    created_at timestamptz not null
        default now(),

    updated_at timestamptz not null
        default now()
);