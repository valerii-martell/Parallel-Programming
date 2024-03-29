# Parallel-Programming

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/12f5696553a14426b984689b7cae738a)](https://www.codacy.com/gh/valerii-martell/Parallel-Programming/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=valerii-martell/Parallel-Programming&amp;utm_campaign=Badge_Grade)

Programming assignments in university courses "Parallel Programming" and "Parallel Programming for Computer Systems".
Several programs from my scientific practise.

**Main stack of used technologies:**
1. Ada (semaphores, protected units, randezvous)
2. Java (semaphores, synchronized, custom generalized monitors and barriers, volatile, fork-join concurrency) 
4. C# (semaphores, mutexes, volatile, monitors, locks, critical sections, parallel.for, parallel.foreach, parallel.invoke)
5. Python (multiprocessing, threading)
6. C++ (WinAPI threading)
7. OpenMP via C++ (pragma omp parallel, for, reduce, locks, barriers, scheduling, etc.)
8. MPI via C++ (basic multiprocessing, blocking send/receive, structuring, communicators, synchronization, etc.).   
9. OpenCL via C# and C++ (for CPU-GPU text recognition problem)
_**Much deeper work with OpenMP and MPI was carried out on a separate course, repository:**_
https://github.com/valerii-martell/High-Performance-Computing

**Main problems considered:**
1. Thread/Process Synchronization Problem
2. Mutual Exclusion Problem

**Applied tasks, the parallel implementation of which is implemented:**
1. Vector-matrix arithmetic operations
2. Search for minimum / maximum
3. Merge sort
4. Text recognition

**The work of parallel systems is considered and emulated:**
1. (Scalable) Systems with Shared Memory
2. (Scalable) Systems with Local Memory

Models of fixed and scalable systems are built, practical problems in them are solved.

**The parallelism of different degree of granularity is considered, namely:**
1. Coarse-grained parallelism
2. Medium-grained parallelism
3. Fine-grained parallelism

**The Fork-Join mechanism based on the Divide-and-Conquer algorithm is considered.**

**The basics of separate use of GPU and joint use of CPU and GPU for solving the practical problem of text recognition by an elementary neural network are considered.**

_Based on this, several scientific articles in international journals and theses in international conferences proceedings have been published. See my CV for details:_
https://www.overleaf.com/read/jbjyzwftsrsn
https://github.com/valerii-martell/CV_LaTeX
