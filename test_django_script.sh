#!/bin/bash
# Test script for django_start_uv.sh functions

# Source the main script to access functions
source django_start_uv.sh

echo "=== Testing Django Setup Script Functions ==="
echo

# Test 1: Validation functions
echo "Test 1: Project name validation"
if validate_project_name "my_project"; then
    echo "✅ Valid project name 'my_project' - PASS"
else
    echo "❌ Valid project name 'my_project' - FAIL"
fi

if validate_project_name "123invalid"; then
    echo "❌ Invalid project name '123invalid' should fail - FAIL"
else
    echo "✅ Invalid project name '123invalid' correctly rejected - PASS"
fi

echo

# Test 2: Python version validation
echo "Test 2: Python version validation"
if validate_python_version "3.11"; then
    echo "✅ Valid Python version '3.11' - PASS"
else
    echo "❌ Valid Python version '3.11' - FAIL"
fi

if validate_python_version "2.7"; then
    echo "❌ Invalid Python version '2.7' should fail - FAIL"
else
    echo "✅ Invalid Python version '2.7' correctly rejected - PASS"
fi

echo

# Test 3: File creation functions (dry run)
echo "Test 3: Testing file creation functions"

# Create temporary directory for testing
test_dir="test_project_$(date +%s)"
mkdir -p "$test_dir"
cd "$test_dir" || exit

echo "Creating test files in: $(pwd)"

# Test README creation
create_readme "TestProject" "This is a test description"
if [[ -f "README.md" ]]; then
    echo "✅ README.md created successfully"
    echo "   Content preview:"
    head -3 README.md | sed 's/^/   /'
else
    echo "❌ README.md creation failed"
fi

echo

# Test .gitignore creation
create_gitignore
if [[ -f ".gitignore" ]]; then
    echo "✅ .gitignore created successfully"
    echo "   Lines count: $(wc -l < .gitignore)"
else
    echo "❌ .gitignore creation failed"
fi

echo

# Test Makefile creation
create_makefile "TestProject"
if [[ -f "Makefile" ]]; then
    echo "✅ Makefile created successfully"
    echo "   Targets found:"
    grep "^[a-z].*:" Makefile | sed 's/^/   /'
else
    echo "❌ Makefile creation failed"
fi

# Cleanup
cd ..
rm -rf "$test_dir"
echo
echo "✅ Test cleanup completed"
echo
echo "=== All function tests completed ==="