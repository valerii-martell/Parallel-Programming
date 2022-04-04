package lab2;

import java.util.Arrays;
import java.util.Random;

/**
 * Created by Valeriy on 28-Sep-16.
 */
public class Vector {

    private int[] data;

    private int n;

    public Vector(int n, boolean isRandom) {
        this.n = n;
        this.data = new int[n];
        if (isRandom) {
            Random rnd = new Random();
            for (int i = 0; i < n; i++) {
                this.data[i] = rnd.nextInt(10);
            }
        }
    }

    public Vector add(Vector that) {
        if (this.n != that.n)
            throw new RuntimeException("Different dimensions.");
        
        Vector result = new Vector(this.n, false);
        for (int i = 0; i < n; i++) {
            result.data[i] = this.data[i] + that.data[i];
        }
        return result;
    }
    
    

    public long mul(Vector that) {
        if (this.n != that.n)
            throw new RuntimeException("Different dimensions.");
        int result = 0;
        for (int i = 0; i < n; i++) {
            result += this.data[i] * that.data[i];
        }
        return result;
    }

    public Vector sort() {
        Arrays.sort(this.data);
        return this;
    }

    public int max() {
        int max = Integer.MIN_VALUE;
        for (int i : this.data) {
            if (i > max) {
                max = i;
            }
        }
        return max;
    }
    
    public int min() {
        int min = Integer.MAX_VALUE;
        for (int i : this.data) {
            if (i < min) {
                min = i;
            }
        }
        return min;
    }

    public void print() {
        System.out.println(this);
    }

    @Override
    public String toString() {
        return this.n < 6 ? Arrays.toString(this.data) : "The dimension is too large.";
    }

    public int[] getData() {
        return data;
    }

    public int getN() {
        return n;
    }

}