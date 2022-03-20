# QuantumHammer: A Practical Hybrid Attack on the LUOV Signature Scheme

## Citation
```
@inbook{10.1145/3372297.3417272,
author = {Mus, Koksal and Islam, Saad and Sunar, Berk},
title = {QuantumHammer: A Practical Hybrid Attack on the LUOV Signature Scheme},
year = {2020},
isbn = {9781450370899},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3372297.3417272},
abstract = {Post-quantum schemes are expected to replace existing public-key schemes within a decade in billions of devices. To facilitate the transition, the US National Institute for Standards and Technology (NIST) is running a standardization process. Multivariate signatures is one of the main categories in NIST's post-quantum cryptography competition. Among the four candidates in this category, the LUOV and Rainbow schemes are based on the Oil and Vinegar scheme, first introduced in 1997 which has withstood over two decades of cryptanalysis. Beyond mathematical security and efficiency, security against side-channel attacks is a major concern in the competition. The current sentiment is that post-quantum schemes may be more resistant to fault-injection attacks due to their large key sizes and the lack of algebraic structure. We show that this is not true. We introduce a novel hybrid attack, QuantumHammer, and demonstrate it on the constant-time implementation of LUOV currently in Round 2 of the NIST post-quantum competition. The QuantumHammer attack is a combination of two attacks, a bit-tracing attack enabled via Rowhammer fault injection and a divide and conquer attack that uses bit-tracing as an oracle. Using bit-tracing, an attacker with access to faulty signatures collected using Rowhammer attack, can recover secret key bits albeit slowly. We employ a divide and conquer attack which exploits the structure in the key generation part of LUOV and solves the system of equations for the secret key more efficiently with few key bits recovered via bit-tracing. We have demonstrated the first successful in-the-wild attack on LUOV recovering all 11K key bits with less than 4 hours of an active Rowhammer attack. The post-processing part is highly parallel and thus can be trivially sped up using modest resources. QuantumHammer does not make any unrealistic assumptions, only requires software co-location (no physical access), and therefore can be used to target shared cloud servers or in other sandboxed environments.},
booktitle = {Proceedings of the 2020 ACM SIGSAC Conference on Computer and Communications Security},
pages = {1071–1084},
numpages = {14}
}
```

### Prerequisites:
A DRAM vulnerable to Rowhammer must be present in the system.
Our system and DRAM specifications are included in "dmidecode.txt" and "cpuinfo.txt" respectively in rowhammer_luov-7-57-197-chacha.
We are using the author's code from their website:
https://www.esat.kuleuven.be/cosic/pqcrypto/luov/

Run this code first and make sure the chacha and keccak (if used) libraries are included and integrated.

## Bit-tracing Attack/rowhammer_luov-7-57-197-chacha:

Run the script "rowhammer.sh" using the following command:
```
$ time sudo sh rowhammer.sh
```
Following thresholds are needed to be adjusted according to the plots generated from "t2.txt" and "c.txt".

- THRESH_OUTLIER
- THRESH_LOW
- THRESH_HI
- THRESH_ROW_CONFLICT

If the thresholds are set properly and the SPOILER is able to find the contiguous memory, you should start seeing the flips. The DRAM must be vulnerable to Rowhammer for the experiments to work. Any other working Rowhammer tool / technique can also be integrated if this particular Rowhammer does not produce flips in your system.

The code collects the faulty signatures and saves them in "faulty_signatures.txt".

## Bit-tracing Attack/bit_tracing_algo_luov-7-57-197-chacha:

The faulty signatures then can be used to recover the key bits offline on any other system.
A proof of concept implementation of bit-tracing algorithm can be seen in "test.c", we are inducing the bit flips one at a time in "LUOV.c" and recovering the location of the flip using bit_tracing algorithm.

Note: The compression and decompression functions are only needed for the updated LUOV on the author's website here:
https://www.esat.kuleuven.be/cosic/pqcrypto/luov/

For previous version, available on NIST website, the bit_tracing_algorithm does not need additional decompression and compression.

The reason is that the new version outputs the signature in compressed form which is needed to be decompressed first for the bit_tracing_algorithm to work.

## Equation Generation:

Make using the following command:
```
$ make test
```
Run test to generate the keys "C_L_Q1.txt, Q2.txt and T.txt":
```
$ ./test
```
Run "Q2_eqn_gen.m" using MATLAB to generate the equations "equations.txt".

Note: You need to adjust the LUOV parameters in "parameters.h" and "Q2_eqn_gen.m".
Default values are for LUOV-7-57-197.

## Solving Equations:

### Prerequisites:
We are using the libFES library to solve the equations using exhaustive search from the following link:

https://www.lifl.fr/~bouillag/fes/index.html

You can follow the instruction on this website to make sure the library is functioning properly.
Once you generate the equations "equations.txt", copy the equations in "solve_col5_48_unknowns.sage" code inside the exhaustive_search function and run the code using the following command:

```
$ time ./sage solve_col5_48_unknowns.sage
```
This code uses the CPU version of the libFES library and may take more than 15 hours.

The GPU version can solve the same problem in a few minutes depending upon the GPU.
http://www.polycephaly.org/projects/forcemq/index.shtml

## plots
We have also included our MATLAB codes to reproduce the figures.
