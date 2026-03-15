#include "helpers.h"
#include "math.h"




// Convert image to grayscale
void grayscale(int height, int width, RGBTRIPLE image[height][width])
{
    int Red;
    int Green;
    int Blue;
    //int Average;

    for (int i = 0; i <= height; i++)
    {
        for (int j = 0; j <= width; j++)
        {
            Red = image[i][j].rgbtRed;
            Green = image[i][j].rgbtGreen;
            Blue = image[i][j].rgbtBlue;
            int sum = Red + Green + Blue;
            int Average = round(((float)Red + (float)Blue + (float)Green) / 3);
            image[i][j].rgbtRed = Average;
            image[i][j].rgbtGreen = Average;
            image[i][j].rgbtBlue = Average;
        }
    }



    return;
}

// Reflect image horizontally
void reflect(int height, int width, RGBTRIPLE image[height][width])
{
    for (int i = 0; i <= height; i++)
    {
        if (width % 2 == 1)
        {
            for (int j = 0; j <= (width / 2); j++)
            {
                RGBTRIPLE temp = image[i][j];
                image[i][j] = image[i][width - (j + 1)];
                image[i][width - (j + 1)] = temp;
            }
        }
        else
        {
            for (int j = 0; j < (width / 2); j++)
            {
                RGBTRIPLE temp = image[i][j];
                image[i][j] = image[i][width - (j + 1)];
                image[i][width - (j + 1)] = temp;
            }
        }
    }
    return;
}
int getBlur(int i, int j, int height, int width, RGBTRIPLE image[height][width], int color_position)
{
    float counter = 0;
    int sum = 0;
    for (int k = i - 1; k < (i + 2); k++)
    {
        for (int l = j - 1; l < (j + 2); l ++)
        {
            if (k < 0 || l < 0 || k >= height || l >= width)
            {
                continue;//ignore if neighbour pixel does not exist
            }
            switch (color_position)
            {
                case 0 :
                    sum += image[k][l].rgbtRed;
                    break;
                case 1 :
                    sum += image[k][l].rgbtGreen;
                    break;
                case 2 :
                    sum += image[k][l].rgbtBlue;
                    break;
            }
            counter++;
        }
    }
    return round(sum / counter);
}
// Blur image
void blur(int height, int width, RGBTRIPLE image[height][width])
{
    RGBTRIPLE copy[height][width];
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            copy[i][j] = image[i][j];
        }
    }
    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j].rgbtRed = getBlur(i, j, height, width, copy, 0);
            image[i][j].rgbtGreen = getBlur(i, j, height, width, copy, 1);
            image[i][j].rgbtBlue = getBlur(i, j, height, width, copy, 2);
        }
    }
    return;
}

// Detect edges
void edges(int height, int width, RGBTRIPLE image[height][width])
{

    RGBTRIPLE temp[height][width];

    //Algorithm
    int Gx[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
    int Gy[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            //first row is gx, second row gy, coloumns are RGB gColor[xy][RGB]
            int gColor[2][3] = {{0, 0, 0}, {0, 0, 0}};

            for (int r = -1; r < 2; r++)
            {
                for (int c = -1; c < 2; c++)
                {
                    if (i + r < 0 || i + r > height - 1)
                    {
                        continue;
                    }
                    if (j + c < 0 || j + c > width - 1)
                    {
                        continue;
                    }

                    gColor[0][2] += image[i + r][j + c].rgbtBlue * Gx[r + 1][c + 1];
                    gColor[1][2] += image[i + r][j + c].rgbtBlue * Gy[r + 1][c + 1];
                    gColor[0][1] += image[i + r][j + c].rgbtGreen * Gx[r + 1][c + 1];
                    gColor[1][1] += image[i + r][j + c].rgbtGreen * Gy[r + 1][c + 1];
                    gColor[0][0] += image[i + r][j + c].rgbtRed * Gx[r + 1][c + 1];
                    gColor[1][0] += image[i + r][j + c].rgbtRed * Gy[r + 1][c + 1];
                }
            }

            int blue = round(sqrt(gColor[0][2] * gColor[0][2] + gColor[1][2] * gColor[1][2]));
            int green = round(sqrt(gColor[0][1] * gColor[0][1] + gColor[1][1] * gColor[1][1]));
            int red = round(sqrt(gColor[0][0] * gColor[0][0] + gColor[1][0] * gColor[1][0]));

            temp[i][j].rgbtBlue = (blue > 255) ? 255 : blue;
            temp[i][j].rgbtGreen = (green > 255) ? 255 : green;
            temp[i][j].rgbtRed = (red > 255) ? 255 : red;
        }
    }

    for (int i = 0; i < height; i++)
    {
        for (int j = 0; j < width; j++)
        {
            image[i][j].rgbtBlue = temp[i][j].rgbtBlue;
            image[i][j].rgbtGreen = temp[i][j].rgbtGreen;
            image[i][j].rgbtRed = temp[i][j].rgbtRed;
        }
    }

    return;
}
