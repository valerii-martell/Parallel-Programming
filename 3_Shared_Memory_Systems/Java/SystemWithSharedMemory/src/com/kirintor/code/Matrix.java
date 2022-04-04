package com.kirintor.code;

import java.util.Random;

public class Matrix {

        private int n;
        private int[][] data;

        public Matrix()
        {

        }
        
        public Matrix(Matrix MA)
        {
            data = new int[MA.getN()][MA.getN()];
            this.n = MA.getN();
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                {
                    data[i][j] = MA.getData()[i][j];
                }
        }
        public Matrix(int n, boolean isRandom)
        {
            data = new int[n][n];
            this.n = n;
            if (isRandom)
            {
                Random random = new Random();
                for (int i = 0; i < this.n; i++)
                    for (int j = 0; j < this.n; j++)
                    {
                        data[i][j] = random.nextInt(10);
                    }
            }
        }

        public Matrix(int n)
        {
            data = new int[n][n];
            this.n = n;
        }

        public Matrix(int n, int number)
        {
            data = new int[n][n];
            this.n = n;
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                {
                    data[i][j] = number;
                }
        }
        
        public String toString()
        {
            String str = "\n";

            if (n <= 100)
            {
                for (int i = 0; i < n; i++)
                {
                    str += "[";
                    for (int j = 0; j < n - 1; j++)
                    {
                        str += data[i][j] + ", ";
                    }
                    str += data[i][n - 1] + "]\n";
                }
            }
            else
            {
                str = "Output is to cumbersome!";
            }
            return str;
        }

        public void print()
        {
            if (n <= 12)
            {
                for (int i = 0; i < n; i++)
                {
                	System.out.print("[");
                    for (int j = 0; j < n - 1; j++)
                    {
                    	System.out.print(data[i][j] + ", ");
                    }
                    System.out.println(data[i][n - 1] + "]");
                }
            }
        }
        
        public int[][] getData()
        {
        	return data; 
        }

        public int getN()
        {
            return n;
        }
    }
