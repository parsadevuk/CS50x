-- Keep a log of any SQL queries you execute as you solve the mystery.
SELECT id, description FROM crime_scene_reports
WHERE crime_scene_reports.year = 2021
AND crime_scene_reports.month = 7
AND crime_scene_reports.day = 28
AND crime_scene_reports.street = "Humphrey Street";
-- IT is related to crime_scene_reports if 295
SELECT * FROM crime_scene_reports WHERE id = 295;
-- Interviews same day
SELECT * FROM interviews WHERE year = 2021 AND month = 7 and day = 28 AND (transcript LIKE '%bakery%');
-- id 161,162,163,193
--| 161 | Ruth    | 2021 | 7     | 28  | Sometime within ten minutes of the theft, I saw the thief get into a car in the bakery parking lot and drive away. If you have security footage from the bakery parking lot, you might want to look for cars that left the parking lot in that time frame.
--| 162 | Eugene  | 2021 | 7     | 28  | I don't know the thief's name, but it was someone I recognized. Earlier this morning, before I arrived at Emma's bakery, I was walking by the ATM on Leggett Street and saw the thief there withdrawing some money.
--| 163 | Raymond | 2021 | 7     | 28  | As the thief was leaving the bakery, they called someone who talked to them for less than a minute. In the call, I heard the thief say that they were planning to take the earliest flight out of Fiftyville tomorrow. The thief then asked the person on the other end of the phone to purchase the flight ticket. |
--| 193 | Emma    | 2021 | 7     | 28  | I'm the bakery owner, and someone came in, suspiciously whispering into a phone for about half an hour. They never bought anything.

-- bakery_security_logs same day from 9AM to 11 AM checks frim interviews id 161
SELECT DISTINCT id FROM people WHERE license_plate IN (
SELECT license_plate FROM bakery_security_logs
WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit");

-- FROM interviews 162
SELECT id FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
WHERE bank_accounts.account_number IN (
SELECT account_number FROM atm_transactions
WHERE year = 2021 AND month = 7 AND day = 28 AND transaction_type = "withdraw" AND atm_location = "Leggett Street");


-- Intersection of both
SELECT DISTINCT id FROM people WHERE license_plate IN (
SELECT license_plate FROM bakery_security_logs
WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit")
INTERSECT
SELECT id FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
WHERE bank_accounts.account_number IN (
SELECT account_number FROM atm_transactions
WHERE year = 2021 AND month = 7 AND day = 28 AND transaction_type = "withdraw" AND atm_location = "Leggett Street");
-- THE theif is luca with passport_number of 8496433585 and person id 467400 and phone_number is (389) 555-5198
-- from interview id 163
SELECT * FROM flights
JOIN passengers ON passengers.flight_id = flights.id
WHERE passengers.passport_number = 8496433585;

-- Finding flights
SELECT id FROM people
JOIN passengers ON passengers.passport_number = people.passport_number
JOIN flights ON passengers.flight_id = flights.id
WHERE flights.year = 2021 AND flights.month = 7 AND flights.day = 29 AND flights.origin_airport_id = 8

-- Intersection of three
SELECT DISTINCT id FROM people WHERE license_plate IN (
SELECT license_plate FROM bakery_security_logs
WHERE year = 2021 AND month = 7 AND day = 28 AND hour = 10 AND minute < 25 AND activity = "exit")
INTERSECT
SELECT id FROM people
JOIN bank_accounts ON bank_accounts.person_id = people.id
WHERE bank_accounts.account_number IN (
SELECT account_number FROM atm_transactions
WHERE year = 2021 AND month = 7 AND day = 28 AND transaction_type = "withdraw" AND atm_location = "Leggett Street")
INTERSECT
SELECT DISTINCT people.id FROM people
JOIN passengers ON passengers.passport_number = people.passport_number
JOIN flights ON passengers.flight_id = flights.id
WHERE flights.year = 2021 AND flights.month = 7 AND flights.day = 29 AND flights.origin_airport_id = 8
INTERSECT
SELECT DISTINCT id FROM people
WHERE phone_number IN (
SELECT DISTINCT receiver FROM phone_calls
WHERE year=2021 AND month = 7 and day = 28
UNION
SELECT DISTINCT caller FROM phone_calls
WHERE year=2021 AND month = 7 and day = 28);

-- suspicion people.id = 467400, 514354, 686048
SELECT * FROM people
WHERE id IN (467400, 514354, 686048);
-- Luca : (389) 555-5198, Diana : (770) 555-1861, Bruce: (367) 555-5533




SELECT DISTINCT * FROM phone_calls
JOIN people ON phone_calls.receiver = people.phone_number
WHERE people.id IN (467400, 514354, 686048)
AND year=2021 AND month = 7 and day = 28 AND duration < "60"
UNION
SELECT DISTINCT * FROM phone_calls
JOIN people ON phone_calls.caller = people.phone_number
WHERE people.id IN (467400, 514354, 686048)
AND year=2021 AND month = 7 and day = 28 AND duration < "60"

-- suspicion people.id = 514354, 686048

-- If Bruce then ACCOMPLICE :Philip id 847116
-- IF Diana then ACCOMPLICE :Robin id 864400
-- !!!FOR GOD SAKE!!!

SELECT * FROM people
WHERE phone_number IN (
SELECT DISTINCT receiver FROM phone_calls
JOIN people ON phone_calls.receiver = people.phone_number
WHERE people.id IN (467400, 514354, 686048)
AND year=2021 AND month = 7 and day = 28 AND duration < "60"
UNION
SELECT DISTINCT receiver FROM phone_calls
JOIN people ON phone_calls.caller = people.phone_number
WHERE people.id IN (467400, 514354, 686048)
AND year=2021 AND month = 7 and day = 28 AND duration < "60");
