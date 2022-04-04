package com.kirintor.classes;

public class ComputeMonitor {

	private int flag = 0;
	private int p;
	
	public ComputeMonitor(int p){
		this.p = p;
	}
	
	synchronized void WaitCompute(){
		if (flag != p-1)
		{
			try{
				wait();
			}
			catch(InterruptedException e){
				System.out.println("Thread finished");
			}
		}
	}
	
	synchronized void EventCompute(){
		flag++;
		if(flag==p-1){
			notify();
		}
	}
}