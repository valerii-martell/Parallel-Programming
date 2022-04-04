package com.kirintor;

import java.util.concurrent.ForkJoinPool;

public class Main {

    //system parameters
    public static final int N = 5;
    public static final int P = 5;

    private static Thread[] threads = new Thread[P];

    public static void main(String[] args) throws InterruptedException{

        System.out.println("Java started");

        Vector vect = new Vector(100000, true);

        long timer = -System.nanoTime();

        //vect.print();

        vect.sort();

        //vect.print();

        timer += System.nanoTime();

        System.out.println("Time (sec): " + (double)timer/1000000000);

        ///

        vect = new Vector(100000, true);

        timer = -System.nanoTime();

        vect = multiprocessingSort(vect, 10);

        timer += System.nanoTime();

        System.out.println("Time (sec): " + (double)timer/1000000000);

        System.out.println("Java finished");

    }

    private static Vector multiprocessingSort(Vector vector, int procCount){
        Vector result = null;
        int newN = vector.getN()-getTwoPow(vector.getN());
        int newProcCount = procCount-getTwoPow(procCount);
        if((vector.getN()==getTwoPow(vector.getN()))&&(procCount==getTwoPow(procCount))){
            ForkJoinSort ForkJoinSort = new ForkJoinSort(getTwoPow(procCount),0,getTwoPow(vector.getN()),vector);
            ForkJoinPool pool = new ForkJoinPool(getTwoPow(procCount));
            pool.invoke(ForkJoinSort);
            result = ForkJoinSort.getVector();
        }else if((procCount >=2)&&(newProcCount>1)&&(newN>=newProcCount)){
            result = new Vector().mergeSort(multiprocessingSort(new Vector(vector, 0, getTwoPow(vector.getN())), getTwoPow(procCount)),
                    multiprocessingSort(new Vector(vector, getTwoPow(vector.getN()), vector.getN()), newProcCount));
        }else{
            result = new Vector().mergeSort(multiprocessingSort(new Vector(vector, 0, getTwoPow(vector.getN())), getTwoPow(procCount)),
                    new Vector(vector, getTwoPow(vector.getN()), vector.getN()).sort());
        }
        return result;
    }

    private static int getTwoPow(int number){
        int result = 1;
        while(result <= number){
            result *= 2;
        };
        result /=2;
        return result;
    }

}
