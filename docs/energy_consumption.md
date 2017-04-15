SMARTGREEN
# unmodified
- fullboard:
    + initial run: 12.5mA
    + sequential runs: 11.5mA

- arduino only:
    + 3.05mA

# modified
- full board:
    + initial run: 7.4mA
    + sequential run: 7.4mA

- arduino only:
    + > 0.01mA (display shows 0.00mA)

- arduino + microsd + board:
    + 4.12mA

- arduino + RTC + board:
    + 3.26mA

- arduino + board: 
    + > 0.01mA (display shows 0.00mA)

- arduino + RF24 (with led) + board:
    + initial run: 8.5mA
    + transmitting: 15 a 21mA
    + sequential run: 3.7mA

- arduino + RF24 (no led) + board:
    + initial run: 7.1mA
    + transmitting: 14 a 21mA
    + sequential run: 2.2mA

# modified (arduino only)
- 0.01mA or lower (display shows 0.00)

--
SLEEP
# test sleep code
- 0.03mA