﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Lab3CSharp
{
    class Matrix
    {
        private int n;
        private int[,] data;

        public Matrix(int n, bool fill)
        {
            data = new int[n, n];
            this.n = n;
            if (fill)
            {
                Random random = new Random();
                for (int i = 0; i < this.n; i++)
                    for (int j = 0; j < this.n; j++)
                    {
                        data[i, j] = random.Next(10);
                    }
            }
        }

        public static Matrix operator +(Matrix m1, Matrix m2)
        {
            Matrix result = new Matrix(m1.n, false);
            for (int i = 0; i < result.n; i++)
                for (int j = 0; j < result.n; j++)
                {
                    result.data[i, j] = m1.data[i, j] + m2.data[i, j];
                }
            return result;
        }

        public static Matrix operator *(Matrix m1, Matrix m2)
        {
            Matrix result = new Matrix(m1.n, false);
            for (int i = 0; i < result.n; i++)
                for (int j = 0; j < result.n; j++)
                    for (int k = 0; k < result.n; k++)
                    {
                        result.data[i, j] += m1.data[i, k] * m2.data[k, j];
                    }
            return result;
        }

        public static Matrix operator *(int value, Matrix m)
        {
            Matrix result = new Matrix(m.N, false);
            for (int i = 0; i < result.n; i++)
                for (int j = 0; j < result.n; j++)
                    {
                        result.data[i, j] *= value;
                    }
            return result;
        }

        public static Vector operator *(Matrix m, Vector v)
        {
            Vector result = new Vector(m.n, false);
            for (int i = 0; i < result.N; i++)
                for (int j = 0; j < result.N; j++)
                {
                    result.Data[i] += m.data[i, j] * v.Data[i];
                }
            return result;
        }

        public static Vector operator *(Vector v, Matrix m)
        {
            Vector result = new Vector(m.n, false);
            for (int i = 0; i < result.N; i++)
                for (int j = 0; j < result.N; j++)
                {
                    result.Data[i] += m.data[i, j] * v.Data[i];
                }
            return result;
        }

        public Matrix Transpose()
        {
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                {
                    if (i > j)
                    {
                        int tmp = data[i, j];
                        data[i, j] = data[j, i];
                        data[j, i] = tmp;
                    }
                }
            return this;
        }

        public Matrix Sort()
        {
            {
                int[] tmp = new int[n];
                for (int i = 0; i < n; i++)
                {
                    for (int j = 0; j < n; j++)
                        tmp[j] = data[i, j];
                    tmp = tmp.OrderByDescending(c => c).ToArray();
                    for (int j = 0; j < n; j++)
                        data[i, j] = tmp[j];
                }
            }
            return this;
        }

        public void Print()
        {
            if (n < 6)
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
        }

        public override string ToString()
        {
            string str = "\n";

            if (n < 6)
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
