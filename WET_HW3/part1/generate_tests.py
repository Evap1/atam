import os
import random
import string

def generate_number(max_digits=19):
    digits = random.randint(1, max_digits)
    if random.choice([True, False]):  # 50% chance of negative number
        return '-' + ''.join(random.choices(string.digits, k=digits))
    else:
        return ''.join(random.choices(string.digits, k=digits))

def generate_test(test_number):
    separator = random.choice([',', '|', ';', ' '])
    limit = random.randint(-9999999999999999999, 9999999999999999999)
    
    numbers = []
    count_above = 0
    for _ in range(random.randint(1, 20)):  # Generate 1 to 20 numbers
        number = int(generate_number())
        numbers.append(str(number))
        if number > limit:
            count_above += 1
    
    content = separator.join(numbers)
    
    # Ensure 'tests' directory exists
    if not os.path.exists('tests'):
        os.makedirs('tests')
    
    # Write test input
    with open(f'tests/test_{test_number}.txt', 'w') as f:
        f.write(content)
    
    # Ensure 'tests_expected' directory exists
    if not os.path.exists('tests_expected'):
        os.makedirs('tests_expected')
    
    # Write test expected output
    with open(f'tests_expected/test_{test_number}_expected.txt', 'w') as f:
        f.write(f"{separator}\n{limit}\n{count_above}")

    return separator, limit, count_above

def main():
    num_tests = 10000  # Generate 20 random tests
    for i in range(num_tests):
        generate_test(i + 1)

if __name__ == "__main__":
    main()
