using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lab3CSharp
{
    class Vector
    {
        private int[] data;
        private int n;

        public Vector(int n, bool fill)
        {
            this.n = n;
            data = new int[n];

            if (fill)
            {
                Random random = new Random();
                for (int i = 0; i < this.n; i++)
                {
                    this.data[i] = random.Next(10);
                }
            }
        }

        public static Vector operator +(Vector v1, Vector v2)
        {
            Vector result = new Vector(v1.n, false);
            for (int i = 0; i < result.n; i++)
            {
                result.data[i] = v1.data[i] + v2.data[i];
            }
            return result;
        }

        public static int operator *(Vector v1, Vector v2)
        {
            int res = 0;
            for (int i = 0; i < v1.n; i++)
            {
                res += v1.data[i] * v2.data[i];
            }
            return res;
        }

        public Vector Sort()
        {
            Array.Sort(this.data);
            return this;
        }

        public int Max()
        {
            int max = Int32.MinValue;
            for (int i = 0; i < n; i++)
            {
                if (data[i] > max) max = data[i];
            }
            return max;
        }

        public int Min()
        {
            int min = Int32.MaxValue;
            for (int i = 0; i < n; i++)
            {
                if (data[i] < min) min = data[i];
            }
            return min;
        }

        public override string ToString()
        {
            string str = "\n";

            if (n < 6)
            {
                str += "[";
                for (int i = 0; i < n-1; i++)
                {
                    str += data[i] + ", ";
                }
                str += data[n-1] + "]\n";
            }
            else
            {
                str = "Output is to cumbersome!";
            }
            return str;
        }

        public int[] Data
        {
            get { return data; }
            set { data = value; }
        }

        public int N
        {
            get { return n; }
            set { n = value; }
        }
    }
}
