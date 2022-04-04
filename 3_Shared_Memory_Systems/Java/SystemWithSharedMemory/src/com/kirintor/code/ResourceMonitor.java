package com.kirintor.code;

public class ResourceMonitor<T> {

	private T value;
	
	synchronized T get(){
		return value;
	}
	
	synchronized void set(T value){
		this.value = value;
	}
}
