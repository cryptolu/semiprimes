## About
This repository contains a [SageMath](https://www.sagemath.org) and [MP-SPDZ](https://github.com/data61/MP-SPDZ) implementation of the distributed semiprime generation protocol detailed in the paper 

[Factoring Primes to Factor Moduli: Backdooring and Distributed Generation of Semiprimes](https://eprint.iacr.org/2021/1610)

by _Giuseppe Vitto_.


## Functionalities

The script `gen_semiprime.sage` automates the execution of the MP-SPDZ multi-party computation script `semiprimes.mpc`, which performs the required distributed
arithmetic operations over parties’ secret values, further processing the retrieval of the opened moduli and parties’ additive shares, the elliptic curve arithmetic and the final checks on the returned semiprimality certificate.

The output returned by `gen_semiprime.sage` is a tuple `(N,s,E,Q)`, with `N` an integer with unknown factorization and `E` an elliptic curve over the ring of integers modulo `N`. The public prime `s` is greater than the cube root of `N` and the elliptic curve point `Q` in  `E` satisfies `s*Q=O`: this proves `N` to be semiprime.

## Execution

Ideally, `semiprimes.mpc` should go in the MP-SPDZ folder `Programs/Source/` and `gen_semiprime.sage` executed inside MP-SPDZ main directory.

The scripts `semiprimes.mpc` and `gen_semiprime.sage` contain the discriminant and a Cornacchia decomposition for the public prime `s` returned in semiprimality certificates, and can be changed accordingly to the required bitsize for `N`.
