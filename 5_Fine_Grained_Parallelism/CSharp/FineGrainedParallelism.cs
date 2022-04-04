using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;

namespace CSharp
{
    class FineGrainedParallelism
    {
        //System parameters
        private int n;
        private int p = Program.P;
        private int h;

        //Input and output values
        private Matrix MA;
        private Matrix MB;
        private Matrix MC;

        //Instruments of diagnostics
        private Stopwatch timer = new Stopwatch();
        private TimeSpan ts = new TimeSpan();
        private double time;

        public FineGrainedParallelism(int n)
        {
            this.n = n;
            this.h = n/p;
        }

        public void Compute()
        {
            

            MA = new Matrix(n);
            MB = new Matrix(n, 1);
            MC = new Matrix(n, 1);

            timer.Restart();

            Parallel.For(0, n, new ParallelOptions { MaxDegreeOfParallelism = Program.P }, i =>
            {
                int buf;
                for (int j = 0; j < n; j++)
                {
                    buf = 0;
                    for (int k = 0; k < n; k++)
                    {
                        buf += MB.Data[i, k] * MC.Data[k, j];
                    }
                    MA.Data[i, j] = buf;
                }
            });

            MA.Print();

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




