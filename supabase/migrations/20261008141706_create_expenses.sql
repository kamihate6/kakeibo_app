create table expenses (

    id uuid primary key
        default gen_random_uuid(),

    household_id uuid not null
        references households(id),

    user_id uuid not null
        references auth.users(id),

    category_id uuid not null
        references categories(id),

    payer_user_id uuid not null
        references auth.users(id),

    amount bigint not null
        check (amount > 0),

    expense_date date not null,

    merchant_name text,

    expense_type text not null
        check (
            expense_type in (
                'HOUSEHOLD',
                'PERSONAL'
            )
        ),

    is_one_time boolean not null
        default false,

    include_in_budget boolean not null
        default true,

    status text not null
        default 'ACTIVE'
        check (
            status in (
                'ACTIVE',
                'CANCELLED'
            )
        ),

    cancelled_by uuid
        references auth.users(id),

    cancelled_at timestamptz,

    memo text,

    created_at timestamptz not null
        default now(),

    updated_at timestamptz not null
        default now()
);