# Parallel-Programming

Programming assignments in university courses "Parallel Programming" and "Parallel Programming for Computer Systems".

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

**Main problems considered:**
1. Thread/Process Synchronization Problem
2. Mutual Exclusion Problem

**The work of parallel systems is considered and emulated:**
1. (Scalable) Systems with Shared Memory
2. (Scalable) Systems with Local Memory
Models of fixed and scalable systems are built, practical problems in them are solved.

**The parallelism of different degree of granularity is considered, namely:**
1. Coarse-grained parallelism
2. Medium-grained parallelism
3. Fine-grained parallelism

**The Fork-Join mechanism based on the Divide-and-Capture algorithm is considered.**

**The basics of separate use of GPU and joint use of CPU and GPU for solving the practical problem of text recognition by an elementary neural network are considered.**

_**Based on this, several scientific articles in international journals and theses in international conferences proceedings have been published. See CV for details:**_
