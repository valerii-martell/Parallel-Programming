package com.kirintor;

/**
 * Created by kirintor830 on 18.05.2017.
 */
public class BarrierMonitor {
    private int maxCount;
    private int currentCount = 0;

    public BarrierMonitor(int maxCount){
        this.maxCount = maxCount;
    }

    synchronized void signalAndWait(){
        currentCount++;
        if (currentCount<maxCount){
            try{
                wait();
            }
            catch(InterruptedException e){
                System.out.println("Thread finished");
            }
        }else{
            notifyAll();
        }
    }
}