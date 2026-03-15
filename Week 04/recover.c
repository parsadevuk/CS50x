#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

typedef uint8_t BYTE;

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("please use the correct format.  ./recover image\n");
        return 1;
    }

    char *infile = argv[1];

    FILE *inptread = fopen(infile, "r");

    if (inptread == NULL)
    {
        printf("file not readable\n");
        return 1;
    }

    FILE *outFile = NULL;
    int bCounter = 0;
    char filename[8];
    uint8_t buffer[512];

    while (fread(buffer, 512, 1, inptread))
    {
        if (buffer[0] == 0xff && buffer[1] == 0xd8 && buffer[2] == 0xff &&
            (buffer[3] & 0xf0) == 0xe0)
        {
            if (outFile != 0)
            {
                fclose(outFile);
            }

            sprintf(filename, "%03i.jpg", bCounter);
            outFile = fopen(filename, "w");
            bCounter++;
        }
        if (outFile != 0)
        {
            // if already found, continue writing
            fwrite(buffer, 512, 1, outFile);
        }
    }
    // last out put file close
    if (outFile != NULL)
    {
        fclose(outFile);
    }

    // Close input file
    fclose(inptread);

    return 0;
}
