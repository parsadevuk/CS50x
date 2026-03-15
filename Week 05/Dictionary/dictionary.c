// Implements a dictionary's functionality

#include <ctype.h>
#include <stdbool.h>
#include "dictionary.h"
#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <string.h>

// Represents a node in a hash table
typedef struct node
{
    char word[LENGTH + 1];
    struct node *next;
}
node;

// TODO: Choose number of buckets in hash table
const unsigned int N = 26;
unsigned int wordCount = 0;
// Hash table
node *table[N];

// Returns true if word is in dictionary, else false
bool check(const char *word)
{
    // TODO
    int key = hash(word);
    node *nodePtr = table[key];

    while (nodePtr != NULL)
    {
        if (strcasecmp(nodePtr->word, word) == 0)
        {
            return true;
        }
        nodePtr = nodePtr->next;
    }

    return false;
}

// Hashes word to a number
unsigned int hash(const char *word)
{
    // TODO: Improve this hash function
    unsigned int h;
    if (isalpha(word[1]))
    {
        if (isupper(word[1]))
        {
            h = word[1] - 'A' + 1;
        }
        else
        {
            h = word[1] - 'a' + 1;
        }
    }
    else
    {
        //printf("Error in hashing function");
        return false;
    }
    h = h % N;
    //printf("the h value is: %i for word %c\n", h, *word);
    return h;
}

// Loads dictionary into memory, returning true if successful, else false
bool load(const char *dictionary)
{
    // TODO
    FILE *filePtr = fopen(dictionary, "r");
    if (filePtr == NULL)
    {
        return false;
    }
    for (int i = 0; i < N; i++)
    {
        table[i] = NULL;
    }
    char buffWord[LENGTH + 1];

    while (fscanf(filePtr, "%s\n", buffWord) != EOF)
    {
        wordCount++;
        node *buffNode = malloc(sizeof(node));
        strcpy(buffNode-> word, buffWord);
        int key = hash(buffWord);

        if (table[key] == NULL)
        {
            buffNode->next = NULL;
            table[key] = buffNode;
        }
        else
        {
            buffNode->next = table[key];
            table[key] = buffNode;
        }
    }
    fclose(filePtr);
    return true;
}

// Returns number of words in dictionary if loaded, else 0 if not yet loaded
unsigned int size(void)
{
    // TODO
    return wordCount;
}

// Unloads dictionary from memory, returning true if successful, else false
bool unload(void)
{
    // TODO
    for (int i = 0; i < N; i++)
    {
        node *nodePtr = table[i];
        while (nodePtr != NULL)
        {
            node *deleteTable = nodePtr;
            nodePtr = nodePtr -> next;
            free(deleteTable);
        }
        table[i] = NULL;
    }

    return true;
}
