from cs50 import get_int

while True:
    height = get_int("Height :")
    if height > 0 and height < 9:
        break

for i in range(height):
    # a is number of spaces
    a = height - 1 - i
    # b is number of hashes
    b = i + 1
    print((" "*(a))+("#"*(b))+("  ")+("#"*(b)), end='\n')
