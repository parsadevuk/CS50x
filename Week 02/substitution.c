#include <cs50.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char alph[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
char alphl[] = "abcdefghijklmnopqrstuvwxyz";

// Initiating Vars
string ciphering(char kee[], char text[]);
bool len_check(string key);
bool alph_check(string key);
bool rep_check(string key);

int main(int argc, string argv[])
{
    if (argc != 2)
    {
        printf("Usage: ./substitution key\n");
        return 1;
    }

    string key = argv[1];

    if (!len_check(key))
    {
        return 1;
    }

    if (!alph_check(key))
    {
        return 1;
    }

    if (!rep_check(key))
    {
        return 1;
    }

    // Upper Case the Alphabete
    for (int i = 0; i < 26; i++)
    {
        if (islower(key[i]))
        {
            key[i] = toupper(key[i]);
        }
    }

    string plaintext = get_string("plaintext:  ");
    printf("ciphertext: %s\n", ciphering(key, plaintext));

    return 0;
}

string ciphering(char kee[], char text[])
{
    int len = strlen(text);
    char *result = malloc(len + 1);

    for (int i = 0; i < len; i++)
    {
        if (isalpha(text[i]))
        {
            for (int j = 0; j < 26; j++)
            {
                if (text[i] == alph[j])
                {
                    result[i] = kee[j];
                    break;
                }
                else if (text[i] == alphl[j])
                {
                    result[i] = tolower(kee[j]);
                    break;
                }
            }
        }
        else
        {
            result[i] = text[i];
        }
    }
    result[len] = '\0';
    return result;
}

bool len_check(string key)
{
    if (strlen(key) == 26)
    {
        return true;
    }
    else
    {
        printf("Key must contain 26 characters.\n");
        return false;
    }
}

bool alph_check(string key)
{
    for (int i = 0; i < strlen(key); i++)
    {
        if (!isalpha(key[i]))
        {
            printf("Key must only contain alphabetic characters.\n");
            return false;
        }
    }
    return true;
}

bool rep_check(string key)
{
    for (int i = 0; i < strlen(key); i++)
    {
        for (int j = i + 1; j < strlen(key); j++)
        {
            if (toupper(key[i]) == toupper(key[j]))
            {
                printf("Key must not contain repeated characters.\n");
                return false;
            }
        }
    }
    return true;
}
