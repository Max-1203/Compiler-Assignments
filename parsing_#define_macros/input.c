#include <stdio.h>

// Test case 1: Simple macro definition
#define CONST 5
#define ANOTHER_CONST CONST + 5

// Test case 2: Macro with arguments
#define SQUARE_AREA(s) (s * s)
#define MULT(a, b) (a * b)

// Test case 3: Macros with spaces
#define IF if (
#define THEN )

int main() {
    int num = CONST;
    printf("constant: %d\n", num); // Should print constant: 5

    int another_num = ANOTHER_CONST;
    printf("another_constant: %d\n", another_num); // Should print another_constant: 10

    int area = SQUARE_AREA(4);
    printf("Square area: %d\n", area); // Should print Square area: 16

    int product = MULT(3, 4);
    printf("Product: %d\n", product); // Should print Product: 12

    int p = MULT(2, MULT(3, 4));
    printf("p: %d\n", p); // Should print p: 24

    IF num > 3 THEN
        printf("Num is greater than 3\n");
    else
        printf("Num is not greater than 3\n");
    // Should print Num is greater than 3

    return 0;
}
