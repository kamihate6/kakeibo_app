create table household_members (

    household_id uuid not null
        references households(id)
        on delete cascade,

    user_id uuid not null
        references auth.users(id)
        on delete cascade,

    role text not null
        check (
            role in (
                'ADMIN',
                'MEMBER'
            )
        ),

    joined_at timestamptz not null
        default now(),

    primary key (
        household_id,
        user_id
    )
);