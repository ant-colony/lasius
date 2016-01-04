module lasius

import gololang.concurrent.workers.WorkerEnvironment

import templateSensor
import temperature.ability

----
##Sister project of AttA

###How to create a sensor?

You have to

- call templateSensor constructor
- do mixin with "some abilities" (abilities are DynamicObjects that provide method to simulate sensor's data)
- add a `generateData` method (it uses abilities methods and properties to calculate data)
- add a `data` method that returns data

- `generateData()` is run periodically by the sensor (see `delay` property)
- `data()` will be called by the gateway

*Remarks: abilities are not mandatory, you can do all with `generateData()`, but it could be interesting to reuse several abilities for different sensors*

----
function main = |args| {
  let env = WorkerEnvironment.builder(): withCachedThreadPool()

  let temperatureSensor = templateSensor(
      id="001"
    , topic="temperatures"
    , delay=1000_L
    , gateway=null
    , execEnv=env
  )
  : mixin(temperature(
        minTemperature=-5
      , maxTemperature=5
    ))
  : define("generateData", |this| {
      let now = java.time.LocalDateTime.now()
      let t = now: getMinute() + (now: getSecond()+0.0) / 100
      this: temperatureValue(this: getTemperatureLevel(t))
    })
  : define("data", |this| {
      return map[
          ["kind", "TC°"]
        , ["locationName" , "@Home"]
        , ["temperature", map[
              ["value",  this: temperatureValue()]
            , ["unit", this: temperatureUnit()]
          ]]
      ]
    })

  #println(JSON.stringify(temperatureSensor))

  temperatureSensor: start()

  env: spawn(|message| {
    println(message)
    while true {
      println(temperatureSensor: data())
      sleep(2000_L)
    }
  }): send("listening to the sensor")


  # try
  # http://golo-lang.org/documentation/next/index.html#_unions
}

