package com.kirintor;

/**
 * Created by kirintor830 on 14.09.2017.
 */

public class Matrix {

    private int n;
    private int[][] data;

    public Matrix(int n, int number){
        data = new int[n][n];
        this.n = n;
        for (int i = 0; i < n; i++)
            for (int j = 0; j < n; j++)
            {
                data[i][j] = number;
            }
    }

    public Matrix(Matrix MA){
        data = new int[MA.getN()][MA.getN()];
        this.n = MA.getN();
        for (int i = 0; i < n; i++)
            for (int j = 0; j < n; j++)
            {
                data[i][j] = MA.getElement(i, j);
            }
    }

    public Matrix(int n){
        data = new int[n][n];
        this.n = n;
    }

    public void print(){
        if (n <= 20)
        {
            for (int i = 0; i < n; i++)
            {
                System.out.print("[");
                for (int j = 0; j < n - 1; j++)
                {
                    System.out.print(data[i][j] + ", ");
                }
                System.out.print(data[i][n - 1] + "]\n");
            }
        }
        else
        {
            System.out.println("Output is too big!");
        }
    }

    public Matrix Copy(){
        Matrix result = new Matrix(n,0);
        for (int i = 0; i < this.n; i++)
            for (int j = 0; j < this.n; j++)
            {
                result.data[i][j] = data[i][j];
            }
        return result;
    }

    public int getN() {
        return n;
    }

    public void setN(int n) {
        this.n = n;
    }

    public int[][] getData()
    {
        return this.data;
    }

    public int getElement(int indexI, int indexJ) {
        return data[indexI][indexJ];
    }

    public void setElement(int element, int indexI, int indexJ) {
        data[indexI][indexJ] = element;
    }


}
