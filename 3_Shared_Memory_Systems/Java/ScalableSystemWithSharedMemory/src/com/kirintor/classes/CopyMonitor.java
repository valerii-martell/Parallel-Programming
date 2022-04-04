package com.kirintor.classes;
public class CopyMonitor<T> {
		
	private T value;
	
	synchronized T get(){
		return value;
	}
	
	synchronized void set(T value){
		this.value = value;
	}
}
