package com.kirintor.classes;

public class Threads extends Thread{
	
	private int threadID;
	private int n;
	private int p;
	private int h;
	Vector B;
	
	private InputMonitor inputMonitor;
	private ComputeMonitor computeMonitor;
	
	public Threads(int threadID, int priority, int p, int n, Vector B, InputMonitor inputMonitor, ComputeMonitor computeMonitor) {
		this.threadID = threadID;
		this.setPriority(priority);
		this.p = p;
		this.n = n;
		this.h = n/p;
		this.B = B;
		this.inputMonitor = inputMonitor;
		this.computeMonitor = computeMonitor;
	}

	   
	@Override
	public void run(){
		System.out.println("Thread "+threadID+" started!");

		//input B in T0
		/*if (threadID == 0){
			B = new Vector(n, 1);
			inputMonitor.eventInput();
		}
		else{
			inputMonitor.waitInput();
		}*/
		
		//if( threadID % 2 != 0) B.mergeSort(threadID, threadID*2);
		
		//output B in T3
		if (threadID != 0)
			computeMonitor.EventCompute();
		else{
			computeMonitor.WaitCompute();
			B.Print();
		}
			
		      
	    System.out.println("Thread "+threadID+" finished!");
	}	
}
