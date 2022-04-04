using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO; 

namespace CSharp
{
    class OneProc
    {
        private int n;

        private Matrix MA;
        private Matrix MB;
        private Matrix MC;

        private Stopwatch timer = new Stopwatch();
        private TimeSpan ts = new TimeSpan();

        private double time;

        public OneProc(int n)
        {
            this.n = n;
        }

        public void Compute()
        {
            MA = new Matrix(n, 0);

            
                    
            MB = new Matrix(n, 1);
            MC = new Matrix(n, 1);

            timer.Restart();

            for (int i = 0; i < n; i++)
            {
                for (int j = 0; j < n; j++)
                {
                    int buf = 0;
                    for (int k = 0; k < n; k++)
                    {
                        buf += MB.Data[i, k] * MC.Data[k, j];
                    }
                    MA.Data[i, j] = buf;
                }
            }

            timer.Stop();

            //simulation of output
            MA.Print();

            

            ts += timer.Elapsed;
            time = ts.TotalSeconds;
        }

        public double Time
        {
            get { return this.time; }
        }
    }
}
