import threading
import time


def wrapper():
    print('.')
    time.sleep(10)
    print('cabou')


t = threading.Thread(target=wrapper)
t.start()

print('deu certo')
