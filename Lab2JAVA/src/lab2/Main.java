package lab2;

import tasks.*;

/**
 *         Lab ¹2
 *    Student: Valeriy Demchik
 *    Group:   IO-41
 *    Date:    28/09/2016
 *
 *    F1: MC = MIN(A)*(MA*MD)
 *	  F2: MK = TRANS(MA)*TRANS(MB*MM)+MX
 *    F3:  O = SORT(P)*(MR*MS)
 *
 */
public class Main {

    public static final int N = 3;

    public static void main(String[] args) throws InterruptedException {
    	
        Thread t1 = new F1("T1", Thread.MIN_PRIORITY, N);
        Thread t2 = new F2("T2", Thread.MAX_PRIORITY, N);
        Thread t3 = new Thread(new F3(N));
        t3.setName("T3");
        t3.setPriority(Thread.NORM_PRIORITY);

        t1.start();
        t2.start();
        t3.start();
        

        t1.join();
        t2.join();
        t3.join();

    }

}