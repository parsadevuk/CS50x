import math


def check_user_input():
    while True:
        try:
            # Convert it into integer
            val = int(input("Number: "))
            if val > 0:
                return val
            elif val < 1:
                raise ValueError
            break
        except:
            print("INVALID")


cardNumber = check_user_input()
lenDigits = int(math.log10(cardNumber))+1


def luhn_checksum(card_number):
    def digits_of(n):
        return [int(d) for d in str(n)]
    digits = digits_of(card_number)
    odd_digits = digits[-1::-2]
    even_digits = digits[-2::-2]
    checksum = 0
    checksum += sum(odd_digits)
    for d in even_digits:
        checksum += sum(digits_of(d*2))
    return checksum % 10


if 13 <= lenDigits <= 16 and luhn_checksum(cardNumber) == 0:
    firstDigit = int(str(cardNumber)[:1])
    twoDigit = int(str(cardNumber)[:2])
    if lenDigits == 13 and firstDigit == 4:
        print("VISA")
    elif lenDigits == 16:
        if firstDigit == 4:
            print("VISA")
        elif 51 <= twoDigit <= 55:
            print("MASTERCARD")
    elif lenDigits == 15:
        if twoDigit == 34 or twoDigit == 37:
            print("AMEX")
else:
    print("INVALID")
