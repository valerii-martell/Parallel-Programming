package com.kirintor;

/**
 * Created by kirintor830 on 18.05.2017.
 */
public class ResourceMonitor<T> {

    private T value;

    synchronized T get(){
        return value;
    }

    synchronized void set(T value){
        this.value = value;
    }
}

