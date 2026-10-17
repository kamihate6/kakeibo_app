# =============================
# Regression Test Runner
# =============================

$tests = @(

    "integration_test/auto_login_test.dart",

    "integration_test/expense_create_test.dart",

    "integration_test/expense_edit_test.dart",

    "integration_test/expense_delete_test.dart",

    "integration_test/budget_create_test.dart",

    "integration_test/dashboard_view_test.dart"

)

$success = @()
$failed = @()

Write-Host ""
Write-Host "============================="
Write-Host " Regression Test Start"
Write-Host "============================="
Write-Host ""

foreach ($test in $tests) {

    Write-Host ""
    Write-Host "Running: $test"
    Write-Host "-----------------------------"

    flutter test $test -d windows

    if ($LASTEXITCODE -eq 0) {

        Write-Host "PASS : $test" -ForegroundColor Green
        $success += $test

    } else {

        Write-Host "FAIL : $test" -ForegroundColor Red
        $failed += $test

    }
}

Write-Host ""
Write-Host "============================="
Write-Host " Regression Test Result"
Write-Host "============================="
Write-Host ""

Write-Host "PASS : $($success.Count)" -ForegroundColor Green

foreach ($item in $success) {
    Write-Host "  $item" -ForegroundColor Green
}

Write-Host ""

Write-Host "FAIL : $($failed.Count)" -ForegroundColor Red

foreach ($item in $failed) {
    Write-Host "  $item" -ForegroundColor Red
}

Write-Host ""

if ($failed.Count -gt 0) {

    Write-Host "Regression test failed." -ForegroundColor Red

} else {

    Write-Host "All regression tests passed." -ForegroundColor Green

}