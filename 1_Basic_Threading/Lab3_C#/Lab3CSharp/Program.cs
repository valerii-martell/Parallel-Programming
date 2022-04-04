using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Threading;

//          Lab #3
//    Student: Valeriy Demchik
//    Group:   IO-41
//    Date:    19/10/2016
//
//    F1: MC = MIN(A)*(MA*MD)
//    F2: MK = TRANS(MA)* TRANS(MB* MM)+MX
//    F3:  O = SORT(P)*(MR* MS)
namespace Lab3CSharp
{
    class Program
    {

        private const int N = 5;

        static void Main(string[] args)
        {
            Thread t1 = new Thread(new ThreadStart(F1));
            Thread t2 = new Thread(new ThreadStart(F2));
            Thread t3 = new Thread(new ThreadStart(F3));

            t1.Priority = ThreadPriority.BelowNormal;
            t2.Priority = ThreadPriority.Highest;
            t3.Priority = ThreadPriority.Normal;

            t1.Start();
            t2.Start();
            t3.Start();

            Console.ReadKey();
        }

        //    F1: MC = MIN(A)*(MA*MD)
        static void F1()
        {
            Console.WriteLine("Thread T1 started!");

            Vector A = new Vector(N, true);
            Matrix MA = new Matrix(N, true);
            Matrix MD = new Matrix(N, true);

            Thread.Sleep(1000);

            Console.WriteLine("MC = " + (A.Min()*(MA*MD)));
            Console.WriteLine("Thread T1 finished!");
        }

        //    F2: MK = TRANS(MA)* TRANS(MB* MM)+MX
        static void F2()
        {
            Console.WriteLine("Thread T2 started!");

            Matrix MA = new Matrix(N, true);
            Matrix MB = new Matrix(N, true);
            Matrix MM = new Matrix(N, true);
            Matrix MX = new Matrix(N, true);

            Thread.Sleep(500);

            Console.WriteLine("MK = " + ((MA.Transpose())*((MB*MM).Transpose())+MX));
            Console.WriteLine("Thread T2 finished!");
        }

        //    F3:  O = SORT(P)*(MR* MS)
        static void F3()
        {
            Console.WriteLine("Thread T3 started!");

            Vector P = new Vector(N, true);
            Matrix MR = new Matrix(N, true);
            Matrix MS = new Matrix(N, true);

            Thread.Sleep(1500);

            Console.WriteLine("O = " + (P.Sort())*((MR*MS)));
            Console.WriteLine("Thread T3 finished!");
        }
    }
}
