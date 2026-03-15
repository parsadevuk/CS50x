import string
import cs50

text = cs50.get_string("Text: ")
cLett = 0
cFStop = 0
cSpace = 0

for i in range(len(text)):
    for j in range(52):
        if text[i] == string.ascii_letters[j]:
            cLett += 1
    if text[i] == "." or text[i] == "!" or text[i] == "?":
        cFStop += 1
    elif (i == 0 and text[i] != " ") or (i != (len(text)) and text[i] == " " and text[i + 1] != " "):
        cSpace += 1

L = float(cLett/cSpace * 100)
S = float(cFStop/cSpace * 100)

# index = 0.0588 * L - 0.296 * S - 15.8
index = round((0.0588 * L) - (0.296 * S) - 15.8)
# print(f"cLett: {cLett}, cFStop: {cFStop}, cSpace: {cSpace}, L: {L}, S: {S}, ind :{ind}, index :{index}")

if (index <= 1):
    print("Before Grade 1")
elif (index >= 16):
    print("Grade 16+")
else:
    print("Grade", index)
