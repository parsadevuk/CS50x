
#include <cs50.h>
#include <math.h>
#include <stdio.h>

// cn is Credit Number and dg is Number of Digit
// Protoyping function

int dg(long cn);
int ct(long cn, int no);
char credit_type_checck(long cn);
int luhns_alg(long cn, int dg);

// main function is here just because
int main(void)
{
    // asking the credit number from user
    long cnn = get_long("Number: ");
    int dgg = dg(cnn);
    if (dgg < 13 || dgg > 16)
    {
        printf("INVALID\n");
    }
    else
    {
        int la = luhns_alg(cnn, dgg);
        if (la == 1)
        {
            credit_type_checck(cnn);
        }
        else if (la == 0)
        {
            printf("INVALID\n");
        }
    }
}
// //--- Functions Area

//-- Function of counting digits
int dg(long cn)
{
    int count = 0;
    do
    {
        cn /= 10;
        ++count;
    }
    while (cn != 0);
    return count;
}

//-- Function find digit respects to its order
int ct(long cn, int no)
{
    long r;
    int dgg = dg(cn);
    int nno = dgg - no;
    r = cn / pow(10, nno);
    r = r % 10;
    return r;
}

// Function of checking luhns algorithm
int luhns_alg(long cn, int dg)
{
    // sd stands for sum of digit
    int sd = 0;
    int result;
    // counting from the end

    for (int i = 1; i <= dg; i = i + 2)
    {
        // vd is varible digit which keep changing in each loop
        // finding the figit with respect to order
        int vd = ct(cn, dg - i);
        int vd2 = vd * 2;
        if (vd2 <= 9)
        {
            sd = sd + vd2;
        }
        else
        {
            int ct1 = ct(vd2, 1);
            int ct2 = ct(vd2, 2);
            sd = sd + ct1 + ct2;
        }
        vd = 0;
    }
    for (int i = 0; i < dg; i = i + 2)
    {
        int vd2 = ct(cn, dg - i);
        sd = sd + vd2;
    }
    int sd2 = sd % 10;
    if (sd2 == 0)
    {
        result = 1;
    }
    else
    {
        result = 0;
    }
    return result;
}

// Credit card check function
char credit_type_checck(long cn)
{
    // card typ v is visa, a is american express and m is master cards and on defult is i which is invalid
    char card_type = 'i';
    int dgg = dg(cn);
    int ct1 = ct(cn, 1);
    int ct2 = ct(cn, 2);
    unsigned pow = 10;
    while (ct2 >= pow)
    {
        pow *= 10;
    }
    int cct = ct1 * pow + ct2;
    switch (dgg)
    {
        case 13:
            if (ct1 == 4)
            {
                card_type = 'v';
                printf("VISA\n");
            }
            else
            {
                card_type = 'i';
                printf("INVALID\n");
            };
            break;
        case 15:
            if (cct == 34 || cct == 37)
            {
                card_type = 'a';
                printf("AMEX\n");
            }
            else
            {
                card_type = 'i';
                printf("INVALID\n");
            };
            break;
        case 16:
            if (ct1 == 4)
            {
                card_type = 'v';
                printf("VISA\n");
            }
            else if (cct == 51 || cct == 52 || cct == 53 || cct == 54 || cct == 55)
            {
                card_type = 'm';
                printf("MASTERCARD\n");
            }
            else
            {
                card_type = 'i';
                printf("INVALID\n");
            };
            break;
        default:
            card_type = 'i';
            printf("INVALID\n");
            break;
    }
    return card_type;
}
