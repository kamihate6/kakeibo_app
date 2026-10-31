drop policy if exists profiles_select_own
on profiles;

create policy profiles_select_own
on profiles
for select
to authenticated
using (
  auth.uid() = id
);

drop policy if exists profiles_insert_own
on profiles;

create policy profiles_insert_own
on profiles
for insert
to authenticated
with check (
  auth.uid() = id
);

drop policy if exists profiles_update_own
on profiles;

create policy profiles_update_own
on profiles
for update
to authenticated
using (
  auth.uid() = id
)
with check (
  auth.uid() = id
);