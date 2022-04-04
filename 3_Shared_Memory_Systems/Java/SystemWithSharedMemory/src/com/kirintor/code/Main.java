package com.kirintor.code;

public class Main{

	public static final int N = 2000;
	public static final int P = 4;
	public static final int H = N/P;
	
	public static Matrix MA = new Matrix(N);
    public static Matrix MB;
    public static Matrix MC;
    public static Matrix MO;
    public static Matrix MK;
    public static Vector Z;
    
    public static SynchronizeMonitor inputBarrierMonitor = new SynchronizeMonitor(P);
    public static SynchronizeMonitor maxBarrierMonitor = new SynchronizeMonitor(P);
    public static SynchronizeMonitor computeBarrierMonitor = new SynchronizeMonitor(P);
    public static ResourceMonitor<Matrix> mcCopyMonitor = new ResourceMonitor<Matrix>();
    public static ResourceMonitor<Matrix> mkCopyMonitor = new ResourceMonitor<Matrix>();
    public static ResourceMonitor<Integer> zCopyMonitor = new ResourceMonitor<Integer>();
    
    private static Thread[] threads = new Thread[P];
    	
	public static void main(String[] args) throws InterruptedException{
		
		System.out.println("Java started");
		
		long timer = -System.nanoTime();
		
		for(int i = 0; i< P; i++){
			threads[i] = new Task(i, Thread.NORM_PRIORITY);      
	        threads[i].start();
		}
		
		for(int i = 0; i< P; i++){
	        threads[i].join();
		}
		
		
		timer += System.nanoTime();
		
		System.out.println("Time (sec): " + (double)timer/1000000000);

        System.out.println("Java finished");



    }
}