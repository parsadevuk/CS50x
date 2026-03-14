#include <cs50.h>
#include <ctype.h>
#include <math.h>
#include <stdio.h>
#include <string.h>

int count_let(string text);
int count_space(string text);
int count_fullstop(string text);
void printing(int grade);

int main(void)
{
    string text = get_string("Text: ");
    int let = count_let(text);
    int words = count_space(text);
    int sentences = count_fullstop(text);
    // L is the average number of letters per 100 words -- L = Letters ÷ Words × 100.  427.5
    float L = (float) let / (float) words;
    // S is the average number of sentences per 100 words in the text-- S = Sentences ÷ Words × 100.
    // 4.347
    float S = (float) sentences / (float) words;
    // index = 0.0588 * L - 0.296 * S - 15.8
    float ind = (0.0588 * L * 100) - (0.296 * S * 100) - 15.8;
    int index = round(ind);
    printing(index);
}

int count_let(string text)
{

    int total = 0;

    for (int i = 0, n = strlen(text); i < n + 1; i++)
    {
        if (isalpha(text[i]))
        {
            total++;
        }
    }
    return total;
}

int count_space(string text)
{
    int total = 0;
    for (int i = 0, n = strlen(text); i < n + 1; i++)
    {
        if (text[i] == ' ' || text[i] == '\0')
        {
            total++;
        }
    }
    return total;
}
int count_fullstop(string text)
{
    int total = 0;
    for (int i = 0, n = strlen(text); i < n + 1; i++)
    {
        if (text[i] == '!' || text[i] == '.' || text[i] == '?')
        {
            total++;
        }
    }
    return total;
}
void printing(int grade)
{
    if (grade <= 1)
    {
        printf("Before Grade 1\n");
    }
    else if (grade >= 16)
    {
        printf("Grade 16+\n");
    }
    else
    {
        printf("Grade %i\n", grade);
    }
}