#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>

#define MAX_TESTS 10000
#define GREEN "\033[0;32m"
#define RED "\033[0;31m"
#define RESET "\033[0m"

extern unsigned short count_above(char separator, long limit);

void write_to_file(const char* content) {
    int fd = open("in.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        perror("Failed to open file");
        return;
    }
    write(fd, content, strlen(content));
    close(fd);
}

int run_test(int test_number) {
    char input_filename[50], expected_filename[50], result_filename[50];
    char separator;
    long limit;
    unsigned short expected_result, actual_result;
    char input_content[1000];  // Assuming max input length of 1000 chars

    // Read input file
    sprintf(input_filename, "tests/test_%d.txt", test_number);
    FILE* input_file = fopen(input_filename, "r");
    if (!input_file) {
        printf("Failed to open input file: %s\n", input_filename);
        return 0;
    }
    fgets(input_content, sizeof(input_content), input_file);
    fclose(input_file);

    // Read expected result
    sprintf(expected_filename, "tests_expected/test_%d_expected.txt", test_number);
    FILE* expected_file = fopen(expected_filename, "r");
    if (!expected_file) {
        printf("Failed to open expected file: %s\n", expected_filename);
        return 0;
    }
    fscanf(expected_file, "%c\n%ld\n%hi", &separator, &limit, &expected_result);
    fclose(expected_file);

    // Run the test
    write_to_file(input_content);
    actual_result = count_above(separator, limit);

    // Write actual result
    sprintf(result_filename, "tests_result/test_%d_result.txt", test_number);
    FILE* result_file = fopen(result_filename, "w");
    if (!result_file) {
        printf("Failed to open result file: %s\n", result_filename);
        return 0;
    }
    fprintf(result_file, "%hi", actual_result);
    fclose(result_file);

    // Compare results
    if (actual_result == expected_result) {
        printf(GREEN "Test %d: PASSED" RESET "\n", test_number);
        return 1;
    } else {
        printf(RED "Test %d: FAILED" RESET "\n", test_number);
        printf("Expected: %hi, Actual: %hi\n", expected_result, actual_result);
        return 0;
    }
}

int main() {
    int passed_tests = 0;
    
    // Ensure 'tests_result' directory exists
    system("mkdir -p tests_result");

    for (int i = 1; i <= MAX_TESTS; i++) {
        passed_tests += run_test(i);
    }

    printf("\nTotal tests passed: %d/%d\n", passed_tests, MAX_TESTS);

    return 0;
}