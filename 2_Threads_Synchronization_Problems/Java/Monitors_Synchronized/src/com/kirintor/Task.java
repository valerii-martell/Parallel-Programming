package com.kirintor;

import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.ForkJoinTask;
import java.util.concurrent.RecursiveAction;

/**
 * Created by kirintor830 on 18.05.2017.
 */
public class Task extends Thread {

    private int threadID;

    private static final int N = Main.N;
    private static final int P = Main.P;
    private static final int H = N / P;

    private static Matrix MA = new Matrix(N);
    private static Vector Z;
    private static Matrix MZ;
    private static Matrix MK;
    private static Matrix MT;
    private static int d;
    private static int a;

    private static ResourceMonitor<Integer> aCopyMonitor = new ResourceMonitor<Integer>();
    private static ResourceMonitor<Integer> dCopyMonitor = new ResourceMonitor<Integer>();
    private static ResourceMonitor<Matrix> mkCopyMonitor = new ResourceMonitor<Matrix>();
    private static BarrierMonitor inputBarrier = new BarrierMonitor(P);
    private static BarrierMonitor minBarrier = new BarrierMonitor(P);
    private static BarrierMonitor computeBarrier = new BarrierMonitor(P);

    public Task(int threadID, int priority) {
        this.setPriority(priority);
        this.threadID = threadID;
    }

    @Override
    public void run() {
        System.out.println("Thread " + threadID + " started!");

        switch (threadID) {
            case 0:
                MK = new Matrix(N, 1);
                MT = new Matrix(N, 1);
                mkCopyMonitor.set(MK);
                break;
            case 2:
                MZ = new Matrix(N, 1);
                d = 1;
                dCopyMonitor.set(d);
                break;
            case 3:
                Z = new Vector(N, 1);
                Z.getData()[2] = 10;
                aCopyMonitor.set(Integer.MAX_VALUE);
                break;
        }

        inputBarrier.signalAndWait();

        ForkJoinPool pool = new ForkJoinPool(1);
        pool.invoke(new ParallelFor(threadID*H, (threadID+1)*H, Z));

        minBarrier.signalAndWait();

        Matrix MKi = new Matrix(mkCopyMonitor.get());
        int di = dCopyMonitor.get().intValue();
        int ai = aCopyMonitor.get().intValue();

        for (int i = threadID*H; i < (threadID+1)*H; i++){
            int buf;
            for (int j = 0; j < N; j++){
                buf = 0;
                for (int k = 0; k < N; k++){
                    buf += MZ.getData()[i][k] * MKi.getData()[k][j];
                }
                MA.getData()[i][j] = buf*di + ai*MT.getData()[i][j];
            }
        }

        computeBarrier.signalAndWait();

        if (threadID == 3) {
            MA.print();
        }

        System.out.println("Thread " + threadID + " finished!");
    }

    @SuppressWarnings("serial")
    private class ParallelFor extends RecursiveAction {

        private int from;
        private int to;

        private Vector Z;

        public int TASK_LEN;

        public ParallelFor(int from, int to, Vector Z) {
            this.from = from;
            this.to = to;
            this.Z = new Vector(Z);
            this.TASK_LEN = Z.getN() / 2;
        }

        @Override
        protected void compute() {
            int len = to - from;
            if (len < TASK_LEN) {
                work(from, to, Z);
            } else {
                int mid = (from + to) >>> 1;
                ForkJoinTask<Void> parallelFor1 = new ParallelFor(from, mid, Z).fork();
                ForkJoinTask<Void> parallelFor2 = new ParallelFor(mid, to, Z).fork();
                parallelFor1.join();
                parallelFor2.join();

            }
        }

        private void work(int from, int to, Vector Z) {
            for (int i = from; i < to; i++) {
                if (Z.getData()[i] < aCopyMonitor.get().intValue()) aCopyMonitor.set(Z.getData()[i]);
            }
        }
    }
}
