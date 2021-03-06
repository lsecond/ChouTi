//
//  DelayedTask.swift
//  Pods
//
//  Created by Honghao Zhang on 2016-02-04.
//
//

import Foundation

/// Cancelable task
open class Task {
    /// Whether this task is canceled
    open var canceled: Bool = false
    
    var _executed: Bool = false
    /// Whether this task has been called to execute
    open var executed: Bool { return _executed }
    
    /// Closure to be executed
    open let task: ()->()
	
	/// Queue the task will run
    open let queue: DispatchQueue
	
	/// Delay seconds
	fileprivate let seconds: TimeInterval
	
	/**
	Init a Task with delay seconds, queue and task closure
	
	- parameter seconds: delay seconds.
	- parameter queue:   queue to be executed in.
	- parameter task:    task closure
	
	- returns: a dispatched Task
	*/
    init(seconds: TimeInterval, queue: DispatchQueue, task: @escaping ()->()) {
		self.seconds = seconds
		self.queue = queue
        self.task = task
    }
    
    /**
     Cancel this task
     */
    open func cancel() {
        canceled = true
    }
    
    /**
     Resume this task
     */
    open func resume() {
        canceled = false
    }
	
    /// Next chained task
    var nextTask: Task?

    /**
     Chain a delayed task in main queue to this task.
     
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A Task.
     */
	@discardableResult
    open func then(_ seconds: TimeInterval = 0.0, task: @escaping ()->()) -> Task {
        return thenOnMainQueue(seconds, task: task)
    }
    
    /**
     Chain a delayed task in main queue to this task.
     
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A Task.
     */
	@discardableResult
    open func thenOnMainQueue(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
        return thenDelayOnQueue(DispatchQueue.main, seconds: seconds, task: task)
    }
    
    /**
     Chain a delayed task in background queue to this task.
     
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A Task.
     */
	@discardableResult
    open func thenOnBackgroundQueue(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        return thenDelayOnQueue(backgroundQueue, seconds: seconds, task: task)
    }
	
    /**
     Chain a delayed task in queue to this task.
     
     - parameter queue:   Queue for this task to execute.
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A Task.
     */
	fileprivate func thenDelayOnQueue(_ queue: DispatchQueue, seconds: TimeInterval, task: @escaping ()->()) -> Task {
        let task = Task(seconds: seconds, queue: queue, task: task)
        nextTask = task
        return task
	}
}

// MARK: - Public Methods
public extension Task {
    /**
     Executes the task on the main queue after a set amount of seconds.
     
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A delayed Task.
     */
    public class func delay(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
        return delayOnMainQueue(seconds, task: task)
    }
    
    /**
     Executes the task on the main queue after a set amount of seconds.
     
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A delayed Task.
     */
    public class func delayOnMainQueue(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
        return delayOnQueue(DispatchQueue.main, seconds: seconds, task: task)
    }
    
    /**
     Executes the task on a background queue after a set amount of seconds.
     
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A delayed Task.
     */
    public class func delayOnBackgroundQueue(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        return delayOnQueue(backgroundQueue, seconds: seconds, task: task)
    }
    
    /**
     Executes the task on a queue after a set amount of seconds.
     
     - parameter queue:   A queue
     - parameter seconds: Delay in seconds.
     - parameter task:    Task to execute after delay.
     
     - returns: A delayed Task.
     */
    fileprivate class func delayOnQueue(_ queue: DispatchQueue, seconds: TimeInterval, task: @escaping ()->()) -> Task {
        let task = Task(seconds: seconds, queue: queue, task: task)
        return dispatch(task)
    }
    
    /**
     Dispatch a Task
     
     - parameter task: Task object to dispatch
     
     - returns: This task
     */
	@discardableResult
    fileprivate class func dispatch(_ task: Task) -> Task {
        let delayTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * task.seconds)) / Double(NSEC_PER_SEC)
        task.queue.asyncAfter(deadline: delayTime, execute: {
            if task.canceled == false {
                task.task()
                task._executed = true
                
                // dispatch next task if needed
                if let nextTask = task.nextTask {
                    dispatch(nextTask)
                }
            }
        })
        
        return task
    }
}

/**
 Executes the task on the main queue after a set amount of seconds.
 
 - parameter seconds: Delay in seconds.
 - parameter task:    Task to execute after delay.
 
 - returns: A delayed Task.
 */
@discardableResult
public func delay(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
    return Task.delayOnMainQueue(seconds, task: task)
}

/**
 Executes the task on the main queue after a set amount of seconds.
 
 - parameter seconds: Delay in seconds.
 - parameter task:    Task to execute after delay.
 
 - returns: A delayed Task.
 */
public func delayOnMainQueue(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
    return Task.delayOnQueue(DispatchQueue.main, seconds: seconds, task: task)
}

/**
 Executes the task on a background queue after a set amount of seconds.
 
 - parameter seconds: Delay in seconds.
 - parameter task:    Task to execute after delay.
 
 - returns: A delayed Task.
 */
public func delayOnBackgroundQueue(_ seconds: TimeInterval, task: @escaping ()->()) -> Task {
    let backgroundQueue = DispatchQueue.global(qos: .background)
    return Task.delayOnQueue(backgroundQueue, seconds: seconds, task: task)
}
