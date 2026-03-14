#include <cs50.h>
#include <stdio.h>

int main(void)
{
    int n;
    do
    {
        n = get_int("Height: ");
    }
    while (n < 1 || n > 8);
    // printf("Stored: %i", n);
    printf("\n");
    for (int k = 1; k <= n; k++)
    {
        for (int j = n - k - 1; j >= 0; j--)
        {
            printf(" ");
        }
        for (int i = k; i >= 1; i--)
        {
            printf("#");
        }
        printf("  ");
        for (int i = k; i >= 1; i--)
        {
            printf("#");
        }
        printf("\n");
    }
}
