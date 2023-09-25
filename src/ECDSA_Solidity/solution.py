import miniecdsa as task

def mul(x, y):
    return task.bigint_mul_mod(x,y, task.SN)

def add(x, y):
    return task.bigint_add_mod(x,y, task.SN)

def sub(x, y):
    return task.bigint_sub_mod(x,y, task.SN)


def div(x, y):
    return task.bigint_div_mod(x,y, task.SN)

def solve():
    # From task.random:
    x1 = 0x53b907251bc1ceb7ab0eb41323afb7126600fe4cb2a9a2e8a797127508f97009
    y1 = 0xc7b390484e2baae92df41f50e537e57185cb18017650a6d3220a42a97727217d
    P1 = task.EPoint(x1,y1)

    # Find known values
    PM1 = task.mult(P1, task.pm1)
    PM2 = task.mult(P1, task.pm2)

    # k1 - k2
    N = sub(PM1.x, PM2.x)

    #             s1*s2*N + m2*s1 - m1*s2          A + B - C
    # SecretKey = -----------------------, also ----------------
    #                  s2*x1 - s1*x2                 D - E

    S1_S2 = mul(task.ps1, task.ps2)

    A = mul(S1_S2, N)
    B = mul(task.pm2, task.ps1)

    AB = add(A, B)
    C = mul(task.pm1, task.ps2)

    numerator = sub(AB, C)

    D = mul(task.ps2, task.pr1)
    E = mul(task.ps1, task.pr2)

    denominator = sub(D, E)

    # ------------------------------------------------------
    privateKey = div(numerator, denominator)


    # Sign the message
    pm3 = 0xd935bb512b4f5e4bcb07f2be42ee5a54804379008b86b9c6c98fd605cca64f55
    (r,s) = task.sign_ecdsa(privateKey, pm3)

    # Check correctness of the result
    task.verify_ctf(r,s)

    print(f"|r: {r}|\n|s: {s}|")

solve()