package tasks;

import lab2.Matrix;
import lab2.Vector;

/**
 * Created by Valeriy on 28-Sep-16.
 * 
 * F1: MC = MIN(A)*(MA*MD)
 */
public class F1 extends Thread {
	
	private int n;

    public F1(String name, int priority, int n) {
        super(name);
        this.setPriority(priority);
        this.n = n;
    }

    @Override
    public void run() {
        System.out.println("Thread " + this.getName() + " started!");

        Vector A = new Vector(n, true);

        Matrix MA = new Matrix(n, true);
        Matrix MD = new Matrix(n, true);

        System.out.println("F1 results: \n" + MC(A, MA, MD).toString());
        
        System.out.println("Thread " + this.getName() + " finished!");
    }

    private Matrix MC(Vector a, Matrix ma, Matrix md) {
        return ma.mulMatrix(md).mul(a.min());
    }

}