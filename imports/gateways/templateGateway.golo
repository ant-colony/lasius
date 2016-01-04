module templateGateway

import gololang.concurrent.workers.WorkerEnvironment
import functional
import utils

----
templateGateway is the minimal structure of a gateway
This is the local constructor of templateGateway
----
local function templateGateway = -> DynamicObject()
  : id(null)                # String
  : locationName(null)      # String
  : kind(null)              # String
  : sensors(list[])         # list[Sensor] -> how to check this is a sensor
  : execEnv(null)           # ExecutorService
  : lastSensorsData(map[])  # map[String, Object]
  : define("checkExecutorService", |this| {

      checkIsNotNull(item=this: execEnv(), err="--- Using default executorService ---"): bind(
        success=|value| {},
        failure=|err| {
          println(err)
          this: execEnv(getDefaulExecutorService())
        }
      )
  })
  : define("update", |this, message| { # This method is called by the sensor, "I'm notified by a sensor"
      # todo check if the message is a map[String, Object]
      # should have
      #   from
      #   topic
      #   content

      println("You've got a message from " + message: get("from") + " : " + message: get("content") + " from " + message: get("from"))

      let sensorData = JSON.parse(message: get("content"))
      sensorData: put("when", java.util.Date())

      # you can get the data
      this: lastSensorsData(): put(message: get("from"),sensorData)

  })
  : define("notifySensor", |this, sensor| { # The gateway notifies the sensor, *hey! give me a value!*
      # todo check that sensor is a sensor
      sensor: update(map[
        ["topic", "get_value"]
      ])
  })
  : define("notifyAllSensors", |this| {
      this: sensors(): each(|sensor| {
        # don't call notifySensor to avoid the check sensor
        # we already know that the list contains only sensors
        # todo: where ?
        sensor: update(map[
          ["topic", "get_value"]
        ])
      })

  })
  : define("initializeBeforeWork", |this| {
      println("--- initializing ---")

  })
  : define("start", |this, work| { # Run a closure when started *(I've got something to do, this is my work)*
      this: checkExecutorService()

      this: execEnv(): spawn(|message| {
        println("starting sensors ...")
        this: sensors(): each(|sensor| {
          sensor: start()
        })
        println("starting gateway ...")
        println(message)

        this: initializeBeforeWork()
        # when all is ok, do the job
        work()


      }): send(this: kind() + " gateway " + this: id() + " is started and emitting/listening")


  })
  : define("provisioning", |this, work| {
    #TODO
  })
  : define("setSensors", |this, sensorsList| {
      this: sensors(sensorsList)
      this: checkExecutorService()
      sensorsList: each(|sensor| {
        sensor: gateway(this): execEnv(this: execEnv())
      })
      return this
  })
  : define("addSensors", |this, sensorsList| {
      this: sensors(): addAll(sensorsList)
      this: checkExecutorService()
      sensorsList: each(|sensor| {
        sensor: gateway(this): execEnv(this: execEnv())
      })
      return this
  })

----
Public constructor of templateGateway
----
function templateGateway = |id, locationName, kind, execEnv| {
  let failures = list[]

  #todo: all checks

  let res = templateGateway()
    : id(id)
    : locationName(locationName)
    : kind(kind)
    : execEnv(execEnv)

  return res

}

function templateGateway = |id, locationName, kind| {
  return templateGateway(id=id, locationName=locationName, kind=kind, execEnv=null)
}