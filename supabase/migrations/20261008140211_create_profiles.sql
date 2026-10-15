create table profiles (
    id uuid primary key
        references auth.users(id)
        on delete cascade,

    display_name text not null,

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);