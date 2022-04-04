package tasks;

import lab2.Matrix;

/**
 * Created by Valeriy on 28-Sep-16.
 * 
 * F2: MK = TRANS(MA)*TRANS(MB*MM)+MX
 */
public class F2 extends Thread {
	
	private int n;

    public F2(String name, int priority, int n) {
        super(name);
        this.setPriority(priority);
        this.n=n;
    }

    @Override
    public void run() {
        System.out.println("Thread " + this.getName() + " started!");

        Matrix MA = new Matrix(n, true);
        Matrix MB = new Matrix(n, true);
        Matrix MM = new Matrix(n, true);
        Matrix MX = new Matrix(n, true);

        System.out.println("F2 results: \n" + MK(MA, MB, MM, MX).toString());
        
        System.out.println("Thread " + this.getName() + " finished!");
    }

    private Matrix MK(Matrix ma, Matrix mb, Matrix mm, Matrix mx) {
        return ma.transp().mulMatrix(mb.mulMatrix(mm).transp()).add(mx);
    }

}