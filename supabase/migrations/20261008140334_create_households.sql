create table households (

    id uuid primary key
        default gen_random_uuid(),

    name text not null,

    owner_user_id uuid not null
        references auth.users(id),

    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);