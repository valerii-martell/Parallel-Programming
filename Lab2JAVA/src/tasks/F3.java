package tasks;

import lab2.Main;
import lab2.Matrix;
import lab2.Vector;

/**
 * Created by Valeriy on 28-Sep-16.
 * 
 * F3:  O = SORT(P)*(MR*MS)
 */
public class F3 implements Runnable {

    public F3() {
    }

    @Override
    public void run() {
        System.out.println("Thread T3 started!");
        
        Vector P = new Vector(Main.N, true);

        Matrix MR = new Matrix(Main.N, true);
        Matrix MS = new Matrix(Main.N, true);

        System.out.println("F3 results: \n" + O(P, MR, MS).toString());
        
        System.out.println("Thread T3 finished!");

    }

    private Vector O(Vector p, Matrix mr, Matrix ms) {
        return mr.mulMatrix(ms).mulVect(p.sort());
    }

}