#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

// Points assigned to each letter of the alphabet
int POINTS[] = {1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 1, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10};

int compute_score(string word);
int printing(int scr1, int scr2);

int main(void)
{
    // Get input words from both players
    string word1 = get_string("Player 1: ");
    string word2 = get_string("Player 2: ");

    // Score both words
    int score1 = compute_score(word1);
    int score2 = compute_score(word2);
    printing(score1, score2);
    // TODO: Print the winner
}

int compute_score(string word)
{
    int score = 0;
    for (int i = 0, n = strlen(word); i < n; i++)
    {
        if (word[i] <= 'z' && word[i] >= 'a')
        {
            int alph_position = word[i] - 'a';
            score = score + POINTS[alph_position];
        }
        else if (word[i] <= 'Z' && word[i] >= 'A')
        {
            int alph_position = word[i] - 'A';
            score = score + POINTS[alph_position];
        }
        else
        {
        }
    }
    // TODO: Compute and return score for string
    return score;
}

int printing(int scr1, int scr2)
{
    if (scr1 > scr2)
    {
        printf("Player 1 wins!\n");
    }
    else if (scr1 < scr2)
    {
        printf("Player 2 wins!\n");
    }
    else
    {
        printf("Tie!\n");
    }
    return 1;
}
