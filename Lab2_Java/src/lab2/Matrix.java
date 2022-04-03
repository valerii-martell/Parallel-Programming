package lab2;

import java.util.Arrays;
import java.util.Random;

/**
 * Created by Valeriy on 28-Sep-16.
 */
public class Matrix {

    private int[][] data;

    private int n;

    public Matrix(int n, boolean isRandom) {
        this.n = n;
        this.data = new int[n][n];
        if (isRandom) {
            Random random = new Random();
            for (int i = 0; i < n; i++) {
                for (int j = 0; j < n; j++) {
                    this.data[i][j] = random.nextInt(10);
                }
            }
        }
    }

    public Matrix add(Matrix that) {
        if (this.n != that.n)
            throw new RuntimeException("Different dimensions.");
        
        Matrix result = new Matrix(this.n, false);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                result.data[i][j] = this.data[i][j] + that.data[i][j];
            }
        }
        return result;
    }
    
    public Matrix mul(int value) {
        Matrix result = new Matrix(this.n, false);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                result.data[i][j] = this.data[i][j]*value;
            }
        }
        return result;
    }

    public Matrix mulMatrix(Matrix that) {
        if (this.n != that.n)
            throw new RuntimeException("Different dimensions.");
        
        Matrix result = new Matrix(this.n, false);
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                for (int k = 0; k < n; k++) {
                    result.data[i][j] += this.data[i][k] * that.data[k][j];
                }
            }
        }
        return result;
    }

    public Vector mulVect(Vector that) {
        if (this.n != that.getN())
            throw new RuntimeException("Different dimensions.");
        
        Vector result = new Vector(this.n, false);
        for (int i = 0; i < n; i++) {
            result.getData()[i] = 0;
            for (int j = 0; j < n; j++) {
                result.getData()[i] += this.data[i][j] * that.getData()[i];
            }
        }
        return result;
    }

    public Matrix transp() {
        int tmp;
        for (int i = 0; i < this.n; i++) {
            for (int j = 0; j < this.n; j++) {
                if (j < i) {
                    tmp = this.data[i][j];
                    this.data[i][j] = this.data[j][i];
                    this.data[j][i] = tmp;
                }
            }
        }
        return this;
    }

    public Matrix sort() {
        for (int i = 0; i < this.n; i++) {
            Arrays.sort(this.data[i]);
        }
        Arrays.sort(this.data, (o1, o2) -> o1[0] - o2[0]);
        return this;
    }

    @Override
    public String toString() {
        if (this.n < 6) {
            StringBuilder s = new StringBuilder();
            for (int i = 0; i < n; i++) {
                s.append(Arrays.toString(data[i])).append("\n");
            }
            return s.toString();
        } else {
            return "The dimension is too large.";
        }
    }

    public void print() {
        System.out.println(this);
    }
}