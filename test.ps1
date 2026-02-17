Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Todo App - Complete Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$BaseUrl = "http://localhost:3001/api"
$Headers = @{"Content-Type" = "application/json"}
$TestsPassed = 0
$TestsFailed = 0

function Test-Result {
    param($TestName, $Success, $Message = "")
    if ($Success) {
        Write-Host "  [PASS] $TestName" -ForegroundColor Green
        $script:TestsPassed++
    } else {
        Write-Host "  [FAIL] $TestName - $Message" -ForegroundColor Red
        $script:TestsFailed++
    }
}

# Test 1: Server Health
Write-Host "[1] Checking Backend Server..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/health" -Method GET -ErrorAction Stop
    Test-Result "Backend Online" ($health.status -eq "OK")
    Write-Host "     Timestamp: $($health.timestamp)" -ForegroundColor Gray
} catch {
    Test-Result "Backend Online" $false $_.Exception.Message
    Write-Host ""
    Write-Host "ERROR: Backend server is not running!" -ForegroundColor Red
    Write-Host "Please start the servers with: .\start-dev.ps1" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}
Write-Host ""

# Test 2: GET All Todos
Write-Host "[2] Testing GET All Todos..." -ForegroundColor Yellow
try {
    $allTodos = Invoke-RestMethod -Uri "$BaseUrl/todos" -Method GET
    Test-Result "GET /api/todos" $true
    Write-Host "     Found: $($allTodos.Count) todo(s)" -ForegroundColor Gray
} catch {
    Test-Result "GET /api/todos" $false $_.Exception.Message
}
Write-Host ""

# Test 3: POST Create Todo
Write-Host "[3] Testing POST Create Todo..." -ForegroundColor Yellow
try {
    $newTodoData = @{
        title = "Automated Test Todo - $(Get-Date -Format 'HH:mm:ss')"
        description = "Created by test suite"
    } | ConvertTo-Json
    
    $newTodo = Invoke-RestMethod -Uri "$BaseUrl/todos" -Method POST -Body $newTodoData -Headers $Headers
    Test-Result "POST /api/todos" ($null -ne $newTodo._id)
    Write-Host "     Created ID: $($newTodo._id)" -ForegroundColor Gray
    $testTodoId = $newTodo._id
} catch {
    Test-Result "POST /api/todos" $false $_.Exception.Message
}
Write-Host ""

# Test 4: POST Without Title (Should Fail)
Write-Host "[4] Testing POST Validation..." -ForegroundColor Yellow
try {
    $invalidData = @{ description = "No title" } | ConvertTo-Json
    $result = Invoke-RestMethod -Uri "$BaseUrl/todos" -Method POST -Body $invalidData -Headers $Headers -ErrorAction Stop
    Test-Result "POST validation should fail" $false "Did not return error"
} catch {
    $isError400 = $_.Exception.Response.StatusCode -eq 400
    Test-Result "POST validation 400 error" $isError400
}
Write-Host ""

# Test 5: GET Single Todo
Write-Host "[5] Testing GET Single Todo..." -ForegroundColor Yellow
try {
    $singleTodo = Invoke-RestMethod -Uri "$BaseUrl/todos/$testTodoId" -Method GET
    Test-Result "GET /api/todos/:id" ($singleTodo._id -eq $testTodoId)
    Write-Host "     Title: $($singleTodo.title)" -ForegroundColor Gray
} catch {
    Test-Result "GET /api/todos/:id" $false $_.Exception.Message
}
Write-Host ""

# Test 6: PUT Update Todo (Mark Complete)
Write-Host "[6] Testing PUT Update Todo..." -ForegroundColor Yellow
try {
    $updateData = @{ completed = $true } | ConvertTo-Json
    $updated = Invoke-RestMethod -Uri "$BaseUrl/todos/$testTodoId" -Method PUT -Body $updateData -Headers $Headers
    Test-Result "PUT mark as complete" ($updated.completed -eq $true)
} catch {
    Test-Result "PUT mark as complete" $false $_.Exception.Message
}
Write-Host ""

# Test 7: PUT Full Update
Write-Host "[7] Testing PUT Full Update..." -ForegroundColor Yellow
try {
    $fullUpdate = @{
        title = "Updated Test Todo"
        description = "Updated description"
        completed = $true
    } | ConvertTo-Json
    
    $fullyUpdated = Invoke-RestMethod -Uri "$BaseUrl/todos/$testTodoId" -Method PUT -Body $fullUpdate -Headers $Headers
    Test-Result "PUT full update" ($fullyUpdated.title -eq "Updated Test Todo")
    Write-Host "     New Title: $($fullyUpdated.title)" -ForegroundColor Gray
} catch {
    Test-Result "PUT full update" $false $_.Exception.Message
}
Write-Host ""

# Test 8: DELETE Todo
Write-Host "[8] Testing DELETE Todo..." -ForegroundColor Yellow
try {
    $deleteResult = Invoke-RestMethod -Uri "$BaseUrl/todos/$testTodoId" -Method DELETE
    Test-Result "DELETE /api/todos/:id" ($deleteResult.message -like "*deleted*")
} catch {
    Test-Result "DELETE /api/todos/:id" $false $_.Exception.Message
}
Write-Host ""

# Test 9: Verify Deletion (Should 404)
Write-Host "[9] Testing DELETE Verification..." -ForegroundColor Yellow
try {
    $shouldNotExist = Invoke-RestMethod -Uri "$BaseUrl/todos/$testTodoId" -Method GET -ErrorAction Stop
    Test-Result "Verify deletion (404)" $false "Todo still exists"
} catch {
    Test-Result "Verify deletion (404)" ($_.Exception.Response.StatusCode -eq 404)
}
Write-Host ""

# Test 10: DELETE Non-Existent (Should 404)
Write-Host "[10] Testing DELETE Non-Existent..." -ForegroundColor Yellow
try {
    $fakeId = "000000000000000000000000"
    $shouldFail = Invoke-RestMethod -Uri "$BaseUrl/todos/$fakeId" -Method DELETE -ErrorAction Stop
    Test-Result "DELETE non-existent (404)" $false "Did not return 404"
} catch {
    Test-Result "DELETE non-existent (404)" ($_.Exception.Response.StatusCode -eq 404)
}
Write-Host ""

# Test 11: Frontend Server Check
Write-Host "[11] Checking Frontend Server..." -ForegroundColor Yellow
try {
    $frontendCheck = Test-NetConnection -ComputerName localhost -Port 3000 -InformationLevel Quiet -WarningAction SilentlyContinue
    Test-Result "Frontend accessible (port 3000)" $frontendCheck
} catch {
    Test-Result "Frontend accessible (port 3000)" $false
}
Write-Host ""

# Test 12: Create Multiple Todos
Write-Host "[12] Testing Multiple Todo Creation..." -ForegroundColor Yellow
$createdIds = @()
for ($i = 1; $i -le 3; $i++) {
    try {
        $todoData = @{
            title = "Bulk Test Todo $i"
            description = "Test $i of 3"
        } | ConvertTo-Json
        
        $bulkTodo = Invoke-RestMethod -Uri "$BaseUrl/todos" -Method POST -Body $todoData -Headers $Headers
        $createdIds += $bulkTodo._id
    } catch {
        # Skip
    }
}
Test-Result "Create 3 todos" ($createdIds.Count -eq 3)
Write-Host "     Created: $($createdIds.Count) todos" -ForegroundColor Gray
Write-Host ""

# Test 13: Bulk Cleanup
Write-Host "[13] Testing Bulk Cleanup..." -ForegroundColor Yellow
$cleanupCount = 0
foreach ($id in $createdIds) {
    try {
        Invoke-RestMethod -Uri "$BaseUrl/todos/$id" -Method DELETE -ErrorAction Stop | Out-Null
        $cleanupCount++
    } catch {
        # Skip
    }
}
Test-Result "Cleanup test todos" ($cleanupCount -eq $createdIds.Count)
Write-Host ""

# Final Status
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Test Results Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Passed: " -NoNewline; Write-Host $TestsPassed -ForegroundColor Green
Write-Host "  Failed: " -NoNewline; Write-Host $TestsFailed -ForegroundColor $(if($TestsFailed -gt 0){"Red"}else{"Green"})
Write-Host "  Total:  " -NoNewline; Write-Host ($TestsPassed + $TestsFailed) -ForegroundColor Cyan
Write-Host ""

if ($TestsFailed -eq 0) {
    Write-Host "  All Tests Passed!" -ForegroundColor Green
} else {
    Write-Host "  Some Tests Failed" -ForegroundColor Red
}
Write-Host ""

# Additional Info
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Application URLs" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Backend:  http://localhost:3001/api/todos" -ForegroundColor Yellow
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor Yellow
Write-Host ""

# Get current todos
try {
    $finalTodos = Invoke-RestMethod -Uri "$BaseUrl/todos" -Method GET
    Write-Host "Current Database State:" -ForegroundColor Cyan
    Write-Host "  Total Todos: $($finalTodos.Count)" -ForegroundColor Gray
    
    if ($finalTodos.Count -gt 0) {
        Write-Host ""
        Write-Host "  Recent Todos:" -ForegroundColor Gray
        $finalTodos | Select-Object -First 5 | ForEach-Object {
            $status = if ($_.completed) { "[X]" } else { "[ ]" }
            $title = $_.title.Substring(0, [Math]::Min(60, $_.title.Length))
            Write-Host "    $status $title" -ForegroundColor DarkGray
        }
    }
} catch {
    # Skip
}
Write-Host ""
