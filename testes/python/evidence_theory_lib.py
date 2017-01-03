from evidence.theory import dst
from evidence.tests.assets import INPUT
print(INPUT['bba1'])

bba = []
with open(INPUT['bba1'], 'r') as f:
    N = int(f.readline())
    for _  in range(1<<N):
        bba += [ float(f.readline()) ]
print (bba) # verify a table with values between 0 and 1 
print (len(bba))

bel1 = dst.Bel(m=bba)
for i in range(1<<N):
    print (i, bel1(i)) # i is a set represents in binary form.