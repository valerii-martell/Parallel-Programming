using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSharp
{
    class Matrix
    {
        private int n;
        private int[,] data;

        public Matrix()
        {

        }
        public Matrix(Matrix MA)
        {
            data = new int[MA.N, MA.N];
            this.n = MA.N;
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                {
                    data[i, j] = MA.Data[i, j];
                }
        }
        public Matrix(int n, bool isRandom)
        {
            data = new int[n, n];
            this.n = n;
            if (isRandom)
            {
                Random random = new Random();
                for (int i = 0; i < this.n; i++)
                    for (int j = 0; j < this.n; j++)
                    {
                        data[i, j] = random.Next(10);
                    }
            }
        }

        public Matrix(int n)
        {
            data = new int[n, n];
            this.n = n;
        }

        public Matrix(int n, int number)
        {
            data = new int[n, n];
            this.n = n;
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                {
                    data[i, j] = number;
                }
        }

        public void Print()
        {
            if (n <= Program.MaxElevementsForShow)
            {
                for (int i = 0; i < n; i++)
                {
                    Console.Write("[");
                    for (int j = 0; j < n - 1; j++)
                    {
                        Console.Write(data[i, j] + ", ");
                    }
                    Console.Write(data[i, n - 1] + "]\n");
                }
            }
            else
            {
                Console.WriteLine("Output is to big!");
            }
        }

        public override string ToString()
        {
            string str = "\n";

            if (n <= Program.MaxElevementsForShow)
            {
                for (int i = 0; i < n; i++)
                {
                    str += "[";
                    for (int j = 0; j < n - 1; j++)
                    {
                        str += data[i, j] + ", ";
                    }
                    str += data[i, n - 1] + "]\n";
                }
            }
            else
            {
                str = "Output is to cumbersome!";
            }
            return str;
        }

        public bool IsEquals(Matrix MA)
        {
            for (int i = 0; i < this.n; i++)
                for (int j = 0; j < this.n; j++)
                {
                    if (data[i, j] != MA.data[i, j]) return false;
                }
            return true;
        }

        public Matrix Copy()
        {
            Matrix result = new Matrix(n, 0);
            for (int i = 0; i < this.n; i++)
                for (int j = 0; j < this.n; j++)
                {
                    result.data[i, j] = data[i, j];
                }
            return result;
        }

        public int[,] Data
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
