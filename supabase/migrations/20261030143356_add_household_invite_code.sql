alter table households
add column if not exists invite_code text;

create unique index if not exists
idx_households_invite_code
on households(invite_code);