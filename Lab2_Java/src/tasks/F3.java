package tasks;

import lab2.Matrix;
import lab2.Vector;

/**
 * Created by Valeriy on 28-Sep-16.
 * 
 * F3:  O = SORT(P)*(MR*MS)
 */
public class F3 implements Runnable {
	
	private int n;

    public F3(int n) {
    	this.n=n;
    }

    @Override
    public void run() {
        System.out.println("Thread T3 started!");
        
        Vector P = new Vector(n, true);

        Matrix MR = new Matrix(n, true);
        Matrix MS = new Matrix(n, true);

        System.out.println("F3 results: \n" + O(P, MR, MS).toString());
        
        System.out.println("Thread T3 finished!");

    }

    private Vector O(Vector p, Matrix mr, Matrix ms) {
        return mr.mulMatrix(ms).mulVect(p.sort());
    }

}