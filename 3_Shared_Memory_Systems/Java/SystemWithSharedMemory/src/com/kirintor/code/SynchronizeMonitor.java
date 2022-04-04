package com.kirintor.code;

public class SynchronizeMonitor {

	private int maxCount;
	private int currentCount = 0;
	
	public SynchronizeMonitor(int maxCount){
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
