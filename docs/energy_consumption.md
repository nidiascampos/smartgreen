SMARTGREEN
# raspberry pi zero
- pi zero only: 0.06 ~ 0.08A
- pi zero + usb hub: 0.06 ~ 0.08A
- pi zero + usb hub + usb 3g modem: 0.20 ~ 0.25A
    + usb disabled: 0.10 ~ 0.15A
    + usb disabled and rf24 active: ~0.30A
    + 3g connection on: up to 0.35A
    + 3g connection on + rf24 active: FIXME (0.40A ?)

# arduino pro mini
## unmodified
- fullboard:
    + initial run: 12.5mA
    + sequential runs: 11.5mA

- arduino only:
    + 3.05mA

## modified
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

## modified (arduino only)
- 0.01mA or lower (display shows 0.00)

# arduino pro mini: sleep
## test sleep code
- 0.03mA