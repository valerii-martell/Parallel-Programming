//Programming for parallel computer systems
//Laboratory work #3. C#. Semaphores, mutexes, locks, events, barriers, monitors.
//Valeriy Demchik
//NTUU "KPI"
//FICT IO - 41
//25.03.2017
//Task: A=B+e*D*(MO*MK)+sort(B)

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CSharpThreads
{
    class Program
    {
        //System parameters
        private const int N = 12;
        private const int P = 6;
        private const int H = N / P;

        //Instruments of interaction
        private static Barrier inputBarrier = new Barrier(P);
        private static Barrier firstSortBarrier = new Barrier(P);
        private static Barrier twoSortBarrier = new Barrier(P/2);
        private static Barrier computeBarrier = new Barrier(P);
        private static EventWaitHandle eventSort = new ManualResetEvent(false);
        private static object objLock = new object();
        private static object objMonitor = new object();

        //Input and output values
        private static Matrix MO;
        private static Matrix MK;
        private static Vector A = new Vector(N, 0);
        private static Vector B;
        private static Vector S;
        private static Vector[] firsSort = new Vector[6];
        private static Vector[] twoSort = new Vector[3]; 
        private static Vector D;
        private static volatile int e;

        private static void ThreadFunction(int threadID)
        {
            Console.WriteLine("Thread {0} started!", threadID+1);

            switch(threadID)
            {
                case 0:
                    //input data in first thread
                    B = new Vector(N, 1);
                    //B.Data[4] = 10;
                    break;
                case 1:
                    e = 1;
                    break;
                case 2:
                    MO = new Matrix(N, 1);
                    D = new Vector(N, 1);
                    break;
                case 3:
                    MK = new Matrix(N, 1);
                    break;
            }
            //input barrier
            inputBarrier.SignalAndWait();

            //sort first
            firsSort[threadID] = new Vector(B, threadID * H, (threadID + 1) * H).Sort();
            //first sort barrier
            firstSortBarrier.SignalAndWait();

            //two sort
            switch (threadID)
            {
                case 0:
                    twoSort[0] = new Vector().MergeSort(firsSort[0], firsSort[1]);
                    break;
                case 2:
                    twoSort[1] = new Vector().MergeSort(firsSort[2], firsSort[3]);
                    break;
                case 4:
                    twoSort[2] = new Vector().MergeSort(firsSort[4], firsSort[5]);
                    break;
            }

            //two sort barrier
            twoSortBarrier.SignalAndWait();

            //final sort
            if (threadID == 0)
            {
                S = new Vector().MergeSort(twoSort[0], twoSort[1]);
                S = S.MergeSort(S, twoSort[2]);
                eventSort.Set();
            }
            else
            {
                eventSort.WaitOne();
            }

            //shared resources
            int ei = e;

            Vector Di = new Vector(N);
            lock (objLock)
            {
                Di = new Vector(D);
            }

            Matrix MKi = new Matrix(N);
            Monitor.Enter(objMonitor);
            try
            {           
                MKi = new Matrix(MK);
            }
            finally
            {
                Monitor.Exit(objMonitor);
            }

            //calculation
            Matrix MA = new Matrix(N, 0);
            Parallel.For(threadID * H, (threadID + 1) * H, i =>
            {
                int buf;
                for (int j = 0; j < N; j++)
                {
                    buf = 0;
                    for (int k = 0; k < N; k++)
                    {
                        buf += MO.Data[i, k] * MKi.Data[k, j];
                    }
                    MA.Data[i, j] = buf;
                }
                buf = 0;
                for (int j = 0; j < N; j++)
                {
                    buf += Di.Data[j] * MA.Data[i, j];
                }
                A.Data[i] = B.Data[i] + S.Data[i] + ei * buf;
            });

            //compute barrier
            computeBarrier.SignalAndWait();

            //show result in first thread
            if (threadID == 0) A.Print();

            Console.WriteLine("Thread {0} finished!", threadID+1);
        }

        static void Main(string[] args)
        {
            Console.WriteLine("Main thread started!");

            Parallel.For(0, P, i =>
            {
                Thread thread = new Thread(() => ThreadFunction(i));
                thread.Start();
                thread.Join();
            });
         
            Console.WriteLine("Main thread started!");
            Console.ReadKey();
        }
    }
}