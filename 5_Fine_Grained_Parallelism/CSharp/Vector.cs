using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CSharp
{
    class Vector
    {
        private int[] data;
        private int n;

        public Vector()
        {

        }

        public Vector(int n, bool isRandom)
        {
            this.n = n;
            data = new int[n];

            if (isRandom)
            {
                Random random = new Random();
                for (int i = 0; i < this.n; i++)
                {
                    this.data[i] = random.Next(10);
                }
            }
        }

        public Vector(int n, int number)
        {
            this.n = n;
            data = new int[n];
            for (int i = 0; i < this.n; i++)
            {
                this.data[i] = number;
            }
        }
        public Vector(int n)
        {
            this.n = n;
            data = new int[n];
        }

        public Vector(Vector vector)
        {
            this.n = vector.n;
            data = new int[n];
            for (int i = 0; i < this.n; i++)
            {
                this.data[i] = vector.data[i];
            }
        }

        public Vector(Vector vector, int startIndex, int finishIndex)
        {
            this.n = finishIndex - startIndex;
            data = new int[n];
            for (int i = 0; i < this.n; i++)
            {
                this.data[i] = vector.data[i + startIndex];
            }
        }

        public Vector(int[] array)
        {
            this.n = array.Length;
            data = new int[n];
            for (int i = 0; i < this.n; i++)
            {
                this.data[i] = array[i];
            }
        }

        public Vector Sort()
        {
            Array.Sort(data);
            return this;
        }

        public Vector Sort(int startIndex, int finishIndex)
        {
            Array.Sort(data, startIndex, finishIndex - startIndex);
            return this;
        }

        public Vector MergeSort(Vector vector1, Vector vector2)
        {
            Vector result = new Vector(vector1.N + vector2.N, 0);
            List<int> array1 = new List<int>(vector1.Data.ToList());
            List<int> array2 = new List<int>(vector2.Data.ToList());
            List<int> resultList = new List<int>();

            while (((array1.Any())
                 && (array2.Any())))
            {
                if (array1[0] <= array2[0])
                {
                    resultList.Add(array1[0]);
                    array1.RemoveAt(0);
                }
                else
                {
                    resultList.Add(array2[0]);
                    array2.RemoveAt(0);
                }
            }
            if (!array1.Any())
            {
                while (array2.Any())
                {
                    resultList.Add(array2[0]);
                    array2.RemoveAt(0);
                }
            }
            else
            {
                while (array1.Any())
                {
                    resultList.Add(array1[0]);
                    array1.RemoveAt(0);
                }
            }

            result.Data = resultList.ToArray();

            return result;
        }

        private void Swap(int indexI, int indexJ)
        {
            int buf = data[indexI];
            data[indexI] = data[indexJ];
            data[indexJ] = buf;
        }

        public void Print()
        {
            if (n <= 12)
            {
                Console.Write("[");
                for (int i = 0; i < n - 1; i++)
                {
                    Console.Write(data[i] + ", ");
                }
                Console.Write(data[n - 1] + "]\n");
            }
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

            if (n <= 12)
            {
                str += "[";
                for (int i = 0; i < n - 1; i++)
                {
                    str += data[i] + ", ";
                }
                str += data[n - 1] + "]\n";
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
