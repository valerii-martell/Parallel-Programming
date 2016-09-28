package tasks;

import lab2.Main;
import lab2.Matrix;

/**
 * Created by Valeriy on 28-Sep-16.
 * 
 * F2: MK = TRANS(MA)*TRANS(MB*MM)+MX
 */
public class F2 extends Thread {

    public F2(String name, int priority) {
        super(name);
        this.setPriority(priority);
    }

    @Override
    public void run() {
        System.out.println("Thread " + this.getName() + " started!");

        Matrix MA = new Matrix(Main.N, true);
        Matrix MB = new Matrix(Main.N, true);
        Matrix MM = new Matrix(Main.N, true);
        Matrix MX = new Matrix(Main.N, true);

        System.out.println("F2 results: \n" + MK(MA, MB, MM, MX).toString());
        
        System.out.println("Thread " + this.getName() + " finished!");
    }

    private Matrix MK(Matrix ma, Matrix mb, Matrix mm, Matrix mx) {
        return ma.transp().mulMatrix(mb.mulMatrix(mm).transp()).add(mx);
    }

}