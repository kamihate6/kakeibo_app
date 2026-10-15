create index idx_expenses_household_date
on expenses (
    household_id,
    expense_date
);

create index idx_expenses_user_date
on expenses (
    user_id,
    expense_date
);

create index idx_expenses_category_date
on expenses (
    category_id,
    expense_date
);

create index idx_household_members_user
on household_members (
    user_id
);

create index idx_budget_plans_household
on budget_plans (
    household_id
);

create index idx_budget_items_plan
on budget_items (
    budget_plan_id
);