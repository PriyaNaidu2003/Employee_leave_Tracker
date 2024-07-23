#!/bin/bash

generate_employee_id() {
    max_id=1000
    if [ ! -f "employees.txt" ]; then
        touch employees.txt
    fi
    if [ -s "employees.txt" ]; then
        max_id=$(cut -d '|' -f1 employees.txt | sort -n | tail -1)
    fi
    echo $((max_id + 1))
}

add_employee() {
    casual_leave=15
    employee_leave=10
    echo "Enter Employee Details:"
    read -p "Name: " name
    read -p "Department: " dept
    read -p "Designation: " designation
    read -p "Salary: " salary
    read -p "Date of Joining (dd-mm-yyyy): " doj
    emp_id=$(generate_employee_id)
    echo "$emp_id|$name|$dept|$designation|$salary|$doj|$casual_leave|$employee_leave|" >> employees.txt
    echo "Employee ID is $emp_id"
    echo "Employee added successfully!"
}

apply_leave() {
    read -p "Enter Employee ID: " emp_id
    employee=$(grep "^$emp_id|" employees.txt)
    if [ -z "$employee" ]; then
        echo "Employee not found"
        return
    fi

    salary=$(echo "$employee" | cut -d '|' -f 5)
    name=$(echo "$employee" | cut -d '|' -f 2)
    dept=$(echo "$employee" | cut -d '|' -f 3)
    designation=$(echo "$employee" | cut -d '|' -f 4)
    doj=$(echo "$employee" | cut -d '|' -f 6)
    casual_leave=$(echo "$employee" | cut -d '|' -f 7)
    employee_leave=$(echo "$employee" | cut -d '|' -f 8)

    if [ "$casual_leave" -eq 0 ] && [ "$employee_leave" -eq 0 ]; then
        echo "You do not have any leave balance. Your salary will be deducted for the leave applied."
        read -p "Apply for leave? (Y/N): " apply_leave
        if [ "$apply_leave" = "Y" ]; then
            salary_emp
        else
            echo "Thank you"
        fi
    else
        read -p "Enter Type of Leave (C for Casual Leave, E for Employee Leave): " type
        read -p "Enter Number of Days: " days
        if [ "$type" == "C" ]; then
            if [ "$days" -gt "$casual_leave" ]; then
                echo "You do not have sufficient casual leave balance"
            else
                casual=$((casual_leave - days))
                sed -i "s/^$emp_id|$name|$dept|$designation|$salary|$doj|$casual_leave|$employee_leave|/$emp_id|$name|$dept|$designation|$salary|$doj|$casual|$employee_leave|/" employees.txt
                echo "Leave applied successfully"
                echo "Casual Leave balance updated"
            fi
        elif [ "$type" == "E" ]; then
            if [ "$days" -gt "$employee_leave" ]; then
                echo "You do not have sufficient employee leave balance"
            else
                employeel=$((employee_leave - days))
                sed -i "s/^$emp_id|$name|$dept|$designation|$salary|$doj|$casual_leave|$employee_leave|/$emp_id|$name|$dept|$designation|$salary|$doj|$casual_leave|$employeel|/" employees.txt
                echo "Leave applied successfully"
                echo "Employee Leave balance updated"
            fi
        else
            echo "Invalid Leave Type"
        fi
    fi
}

salary_emp() {
    read -p "Enter Employee ID: " emp_id
    employee=$(grep "^$emp_id|" employees.txt)
    if [ -z "$employee" ]; then
        echo "Employee not found"
        return
    fi

    salary=$(echo "$employee" | cut -d '|' -f 5)
    name=$(echo "$employee" | cut -d '|' -f 2)
    dept=$(echo "$employee" | cut -d '|' -f 3)
    designation=$(echo "$employee" | cut -d '|' -f 4)
    doj=$(echo "$employee" | cut -d '|' -f 6)
    casual_leave=$(echo "$employee" | cut -d '|' -f 7)
    employee_leave=$(echo "$employee" | cut -d '|' -f 8)

    read -p "Leave Type (casual/employee): " leave_type
    read -p "Number of days: " days
    salary_per_day=$((salary / 30))
    salary_deduct=$((days * salary_per_day))
    total=$((salary - salary_deduct))
    sed -i "s/^$emp_id|$name|$dept|$designation|$salary|$doj|$casual_leave|$employee_leave|/$emp_id|$name|$dept|$designation|$total|$doj|$casual_leave|$employee_leave|/" employees.txt
}

display_leave_balance() {
    read -p "Enter Employee ID: " id
    employee=$(grep "^$id|" employees.txt)
    if [ -z "$employee" ]; then
        echo "Employee not found"
    else
        casual_leave=$(echo "$employee" | cut -d '|' -f 7)
        employee_leave=$(echo "$employee" | cut -d '|' -f 8)
        echo "Casual Leave: $casual_leave"
        echo "Employee Leave: $employee_leave"
    fi
}

show_details() {
    cat employees.txt
}

# Main program
while true; do
    echo "Enter option:"
    echo "1. Add employee"
    echo "2. Show employee list"
    echo "3. Apply for leave"
    echo "4. View leave balance"
    echo "5. Exit"
    read -p "Option: " option
    case $option in
        1) add_employee ;;
        2) show_details ;;
        3) apply_leave ;;
        4) display_leave_balance ;;
        5) exit ;;
        *) echo "Invalid choice" ;;
    esac
done
