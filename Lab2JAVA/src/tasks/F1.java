package tasks;

import lab2.Main;
import lab2.Matrix;
import lab2.Vector;

/**
 * Created by Valeriy on 28-Sep-16.
 * 
 * F1: MC = MIN(A)*(MA*MD)
 */
public class F1 extends Thread {

    public F1(String name, int priority) {
        super(name);
        this.setPriority(priority);
    }

    @Override
    public void run() {
        System.out.println("Thread " + this.getName() + " started!");

        Vector A = new Vector(Main.N, true);

        Matrix MA = new Matrix(Main.N, true);
        Matrix MD = new Matrix(Main.N, true);

        System.out.println("F1 results: \n" + MC(A, MA, MD).toString());
        
        System.out.println("Thread " + this.getName() + " finished!");
    }

    private Matrix MC(Vector a, Matrix ma, Matrix md) {
        return ma.mulMatrix(md).mul(a.min());
    }

}