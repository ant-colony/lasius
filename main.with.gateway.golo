module lasius

import templateSensor
import temperature.ability
import templateGateway

function TempSensor = |id| {

  let temperatureSensor = templateSensor(
      id=id
    , topic="temperatures"
    , delay=1000_L
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

    return temperatureSensor

}


function main = |args| {

  let myGateway = templateGateway(id="g000", locationName="someWhere", kind="Virtual")

  myGateway: setSensors(list[
      TempSensor("t01")
    , TempSensor("t02")
    , TempSensor("t03")
  ])

  myGateway: start({ # this is executed inside a worker

    while true {
      myGateway: notifyAllSensors()
      sleep(2000_L)
      println(myGateway: lastSensorsData())
    }


  })

}

