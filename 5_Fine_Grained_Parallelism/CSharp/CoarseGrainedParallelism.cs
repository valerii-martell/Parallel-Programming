using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CSharp
{
    class CoarseGrainedParallelism
    {
        //System parameters
        private int n;
        private int p = Program.P;
        private int h;

        //Input and output values
        private Matrix MA;
        private Matrix MB;
        private Matrix MC;

        //Instruments of interaction
        private Barrier inputBarrier;
        private Barrier computeBarrier;
        private object objLock = new object();

        //Instruments of diagnostics
        private Stopwatch timer = new Stopwatch();
        private TimeSpan ts = new TimeSpan();
        private double time;

        public CoarseGrainedParallelism(int n)
        {
            this.n = n;
            this.h = n/p;
            inputBarrier = new Barrier(p);
            computeBarrier = new Barrier(p);
        }
        private void ThreadFunction(int threadID)
        {
            //Console.WriteLine("Thread {0} started!", threadID);

            if (threadID == 0)
            {
                MA = new Matrix(n);  
                MB = new Matrix(n, 1);
                MC = new Matrix(n, 1);
            }
            //input barrier
            inputBarrier.SignalAndWait();

            Matrix MCi;
            lock(objLock)
            {
                MCi = new Matrix(MC);
            }

            for(int i = threadID * h; i< (threadID + 1) * h; i++)
            {
                int buf;
                for (int j = 0; j < n; j++)
                {
                    buf = 0;
                    for (int k = 0; k < n; k++)
                    {
                        buf += MB.Data[i, k] * MCi.Data[k, j];
                    }
                    MA.Data[i, j] = buf;
                }
            }

            //compute barrier
            computeBarrier.SignalAndWait();

            //show result in first thread
            if (threadID == 0) MA.Print();

            //Console.WriteLine("Thread {0} finished!", threadID);
        }

        public void Compute()
        {
            timer.Restart();

            Parallel.For(0, p, i =>
            {
                Thread thread = new Thread(() => ThreadFunction(i));
                thread.Start();
                thread.Join();
            });


            timer.Stop();

            ts += timer.Elapsed;
            time = ts.TotalSeconds;
        }

        public double Time
        {
            get { return this.time; }
        }
    }
}
