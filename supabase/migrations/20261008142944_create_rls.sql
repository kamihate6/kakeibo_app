alter table expenses
enable row level security;

alter table profiles
enable row level security;

create policy personal_expense_select
on expenses
for select
using (
    expense_type = 'PERSONAL'
    and user_id = auth.uid()
);

create policy household_expense_select
on expenses
for select
using (
    expense_type = 'HOUSEHOLD'
    and exists (
        select 1
        from household_members hm
        where hm.household_id = expenses.household_id
        and hm.user_id = auth.uid()
    )
);

create policy expense_insert
on expenses
for insert
with check (
    user_id = auth.uid()
);

create policy expense_update
on expenses
for update
using (
    user_id = auth.uid()
);

