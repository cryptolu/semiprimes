#Run this script inside MP-SPDZ folder
import os

bits = 256
no_of_players = 2
p = random_prime(2^bits-1,False,2^(bits-1))

mpz_folder = "/home/ubuntu/mp-spdz"
cmd_flags = " >/dev/null 2>&1"
small_factors = primes_first_n(100)

#We compile for the new modulus
cmd = mpz_folder+"/compile.py -P " + str(p) + " semiprimes" + cmd_flags
res = os.system(cmd)

D = -4
s_a = 23200685
s_b = 289158
S = s_a**2 + abs(D)*s_b**2
assert(is_prime(S))

#Montgomery Conversion Parameters
R2 = pow(pow(2,bits,p),2,p)
R = sqrt(R2)
assert R**2 == R2

found = 0
counter = 0
while found == 0:
    #We run the protocol
    cmd = mpz_folder + "/Scripts/semi.sh semiprimes -OF " + mpz_folder + "/Player-Data/output" + cmd_flags
    res = os.system(cmd)
    counter += 1
    print(counter)
    #Shares recovery
    SHARES = {i:0 for i in range(no_of_players)}
    for player in range(no_of_players):
        filename = mpz_folder+"/Player-Data/Private-Output-"+str(player)
        with open(filename, 'rb') as file:
            for c in range(no_of_players):
                share = int.from_bytes(file.read(bits//8), byteorder='little')
                SHARES[c] += int(GF(p)(share/R))

    #Read computed modulus
    with open(mpz_folder + "/Player-Data/output-P0-0", "r", encoding="utf-8") as Nfile:
        allN = [int(Nfile.readline()),int(Nfile.readline()),int(Nfile.readline()),int(Nfile.readline())]

    #Let's quickly check small factors of N, and test certificate only for good candidates
    for N in allN:

        if S < floor((N^(1/6)+1)^2):
            print("- S too small")
            continue

        Nmod = [N % sf for sf in small_factors]
        if 0 in Nmod:
            continue

        Zn = Integers(N)

        for _ in range(10*4):
            #Picking points in XY-coordinates for D = -4
            if D not in [-3,-4]:
                j = hilbert_class_polynomial(D).roots()[0][0]
                k = Zn(j/(j-1728))
                x = Zn.random_element()
                c = Zn(3*x**2/2)
                A = int(Zn(-3*k*c**2))
                B = int(Zn(2*k*c**3))
                E = EllipticCurve(Zn, [A,B])
                P = E([x**2,x**3])
            if D == -4:
                x = Zn.random_element()
                w = Zn.random_element()
                c = Zn(x**2-x*w**2)
                A = -c
                B = 0
                E = EllipticCurve(Zn, [A,B])
                P = E([x,x*w])

            #we need to hit the good curve pair on first try, otherwise we might factor N!
            try:
                #Each player computes a public point to sum up
                Q = E(0)
                for player in range(no_of_players):
                    Q += SHARES[player]*P

                #We remove eventual multiples of p
                testPoints = [Q - i*p*P for i in range(no_of_players)]
                for Q in testPoints:
                    if S*Q == E(0) and Q != E(0):
                        cert = (N,S,E,Q)
                        found = 1
                        break
            except:
                print("- Inversion failed..")
                break

            if found:
                break

        if found:
            break

N,S,E,Q = cert
print(cert)
