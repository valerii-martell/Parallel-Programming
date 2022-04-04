package com.kirintor.classes;

public class InputMonitor {
	
	private int flag;
	
	synchronized void waitInput(){
		if (flag==0)
		{
			try{
				wait();
			}
			catch(InterruptedException e){
				System.out.println("Thread finished");
			}
		}
	}
	
	synchronized void eventInput(){
		flag++;
		notifyAll();
	}
}