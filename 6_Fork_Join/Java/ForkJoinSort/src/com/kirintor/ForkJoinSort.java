package com.kirintor;

/**
 * Created by kirintor830 on 14.09.2017.
 */
import java.util.concurrent.ForkJoinTask;
import java.util.concurrent.RecursiveAction;

@SuppressWarnings("serial")
public class ForkJoinSort extends RecursiveAction {

    private int startIndex;
    private int finishIndex;
    private Vector vector;
    private static Vector inputedVector;

    public Vector getVector(){
        return this.vector;
    }

    public static int FINAL_LEN;

    private ForkJoinSort(Vector vector, int startIndex, int finishIndex) {
        this.finishIndex = finishIndex;
        this.startIndex = startIndex;
        this.vector = vector;
    }

    public ForkJoinSort(int procCount, int startIndex, int finishIndex, Vector inputedVector) {
        this.finishIndex = finishIndex;
        this.startIndex = startIndex;
        this.vector = new Vector(inputedVector.getN(), 0);
        ForkJoinSort.inputedVector = new Vector(inputedVector);
        ForkJoinSort.FINAL_LEN = inputedVector.getN()/procCount;
    }

    @Override
    protected void compute() {
        int len = finishIndex - startIndex;
        if (len == FINAL_LEN) {
            vector = new Vector(inputedVector,startIndex,finishIndex).sort();

            //System.out.println("bubble sort " +new Vector(inputedVector,startIndex,finishIndex).toString() + " from "+startIndex+" to "+ finishIndex+" = " + vector.toString());
        } else{
            //System.out.println("sort from "+startIndex+" to "+ finishIndex);

            int mid = (finishIndex + startIndex) >>> 1;
            //System.out.println("mid=" + mid);

            ForkJoinTask<Void> task1 = new ForkJoinSort(new Vector(inputedVector, startIndex, mid), startIndex, mid).fork();
            //System.out.println(" task1 sort "+ new Vector(vector,startIndex, mid).toString()+ " form "+startIndex+ " to "+mid);

            ForkJoinTask<Void> task2 = new ForkJoinSort(new Vector(inputedVector, mid, finishIndex), mid, finishIndex).fork();
            //System.out.println(" task2 sort "+ new Vector(vector, mid, finishIndex).toString()+ " form "+mid+ " to "+finishIndex);

            task1.join();
            task2.join();
            //System.out.println(((ForkJoinSort) task1).getVector().toString());
            //System.out.println(((ForkJoinSort) task2).getVector().toString());

            this.vector = new Vector(vector.mergeSort(((ForkJoinSort) task1).getVector(), ((ForkJoinSort) task2).getVector()));
            //System.out.println(vector.toString());


        }
    }
}

