#include <cs50.h>
#include <stdio.h>
#include <string.h>

// Max number of candidates
#define MAX 9
// preferences[i][j] is number of voters who prefer i over j
int preferences[MAX][MAX];
// locked[i][j] means i is locked in over j
bool locked[MAX][MAX];

// Each pair has a winner, loser
typedef struct
{
    int winner;
    int loser;
} pair;

// Array of candidates
string candidates[MAX];
pair pairs[MAX * (MAX - 1) / 2];

int pair_count;
int candidate_count;

// Function prototypes
bool vote(int rank, string name, int ranks[]);
void record_preferences(int ranks[]);
void add_pairs(void);
void sort_pairs(void);
void lock_pairs(void);
void print_winner(void);
bool hasCycle(int winner, int loser);

int main(int argc, string argv[])
{
    // Check for invalid usage
    if (argc < 2)
    {
        printf("Usage: tideman [candidate ...]\n");
        return 1;
    }

    // Populate array of candidates
    candidate_count = argc - 1;
    if (candidate_count > MAX)
    {
        printf("Maximum number of candidates is %i\n", MAX);
        return 2;
    }
    for (int i = 0; i < candidate_count; i++)
    {
        candidates[i] = argv[i + 1];
    }

    // Clear graph of locked in pairs
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = 0; j < candidate_count; j++)
        {
            locked[i][j] = false;
        }
    }

    pair_count = 0;
    int voter_count = get_int("Number of voters: ");

    // Query for votes
    for (int i = 0; i < voter_count; i++)
    {
        // ranks[i] is voter's ith preference
        int ranks[candidate_count];

        // Query for each rank
        for (int j = 0; j < candidate_count; j++)
        {
            string name = get_string("Rank %i: ", j + 1);

            if (!vote(j, name, ranks))
            {
                printf("Invalid vote.\n");
                return 3;
            }
        }

        record_preferences(ranks);

        printf("\n");
    }

    add_pairs();
    sort_pairs();
    lock_pairs();
    print_winner();
    return 0;
}

// Update ranks given a new vote
bool vote(int rank, string name, int ranks[])
{
    // TODO
    int found_index = -1;

    for (int i = 0; i < candidate_count; i++)
    {
        if (strcmp(candidates[i], name) == 0)
        {
            found_index = i;
            break;
        }
    }
    if (found_index == -1)
    {
        return false;
    }
    ranks[rank] = found_index;
    return true;
}

// Update preferences given one voter's ranks
void record_preferences(int ranks[])
{
    for (int i = 0; i < candidate_count; i++)
    {
        for (int j = i + 1; j < candidate_count; j++)
        {
            preferences[ranks[i]][ranks[j]]++;
        }
    }
    // TODO
    return;
}

// Record pairs of candidates where one is preferred over the other
void add_pairs(void)
{
    for (int i = 0; i < MAX; i++)
    {
        for (int j = i + 1; j < MAX; j++)
        {
            int candidate_i = preferences[i][j];
            int candidate_j = preferences[j][i];
            pair p;
            // upper traingular nested loop
            if (candidate_i != candidate_j)
            {
                if (candidate_i > candidate_j)
                {
                    p.winner = i;
                    p.loser = j;
                }
                else
                {
                    p.winner = j;
                    p.loser = i;
                }
                pairs[pair_count++] = p;
            }
        }
    }
    // TODO
    return;
}

// Sort pairs in decreasing order by strength of victory
void sort_pairs(void)
{

    for (int i = 0; i < pair_count; i++)
    {
        int max_index = i;
        // finding the difference in the matrix
        int current_strength = preferences[pairs[i].winner][pairs[i].loser] -
                               preferences[pairs[i].loser][pairs[i].winner];
        // Finding victory person
        for (int j = i + 1; j < pair_count; j++)
        {
            int temp_strength = preferences[pairs[j].winner][pairs[j].loser] -
                                preferences[pairs[j].loser][pairs[j].winner];
            if (temp_strength > current_strength)
            {
                max_index = j;
                current_strength = preferences[pairs[j].winner][pairs[j].loser] -
                                   preferences[pairs[j].loser][pairs[j].winner];
            }
        }
        pair temp = pairs[max_index];
        pairs[max_index] = pairs[i];
        pairs[i] = temp;
    }
    // TODO
    return;
}
bool hasCycle(int winner, int loser)
{
    while (winner != -1 && winner != loser)
    {
        bool found = false;
        // iterate for each candidate between winner and loser
        for (int i = 0; i < candidate_count; i++)
        {
            if (locked[i][winner])
            {
                found = true;
                winner = i;
            }
        }
        // when cycle found
        if (!found)
        {
            winner = -1;
        }
    }
    if (winner == loser)
    {
        return true;
    }
    return false;
}

// Lock pairs into the candidate graph in order, without creating cycles
void lock_pairs(void)
{
    // TODO

    for (int i = 0; i < pair_count; i++)
    {
        if (!hasCycle(pairs[i].winner, pairs[i].loser))
        {
            locked[pairs[i].winner][pairs[i].loser] = true;
        }
    }
}

// Print the winner of the election
void print_winner(void)
{
    // TODO
    for (int i = 0; i < MAX; i++)
    {
        bool found_source = true;
        for (int j = 0; j < MAX; j++)
        {
            if (locked[j][i] == true)
            {
                found_source = false;
                break;
            }
        }
        if (found_source)
        {
            printf("%s\n", candidates[i]);
            return;
        }
    }

    return;
}
