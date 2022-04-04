package com.kirintor;

public class Main{

    //system parameters
    public static final int N = 12;
    public static final int P = 6;

    private static Thread[] threads = new Thread[P];

    public static void main(String[] args) throws InterruptedException{

        for(int i = 0; i< P; i++){
            threads[i] = new Task(i, Thread.NORM_PRIORITY);
            threads[i].start();
        }

        for(int i = 0; i< P; i++){
            threads[i].join();
        }
    }
}
