module templateSensor

import gololang.concurrent.workers.WorkerEnvironment
import functional

----
templateSensor is the minimal structure of a sensor
Of course, you can define your own template
This is the local constructor of templateSensor
----
local function templateSensor = -> DynamicObject()
  : gateway(null)     # ?
  : id(null)          # String
  : execEnv(null)     # ExecutorService
  : topic("sensor")   # String // topic for gateway notification -> should be overridden
  : delay(5000_L) # Number
  : define("notifyGateway", |this| {
      # todo: check if the gateway exists, if the id exists and that topic is a string
      this: gateway(): update(map[
          ["topic", this: topic()]
        , ["from", this: id()]
        , ["content", JSON.stringify(this: data())]
      ])
    })
  : define("update", |this, message| {
      # this is a message from the gateway: "hello i'm the gateway, please give me some data ..."
      # todo check if the message is a map
      # todo check if the message has a key topic

      checkIsEqual(
        item=message: get("topic"),
        value="get_value",
        err="WARNING: templateSensor:update, no topic=='get_value'"
      ): bind(
        success=|item| { this: notifyGateway()}, failure=|errMessage| { println(errMessage) }
      )
    })
  : define("generateData", |this| {
      # has to be overridden
    })
  : define("data", |this| {
      # has to be overridden
    })
  : define("beforeStart", |this| {
      # should to be overridden
    })
  : define("start", |this| {
      # todo check type of execEnv and if not null / here because i can use the env of the gateway
      # todo check that the delay is a long
      this: beforeStart()

      this: execEnv(): spawn(|message| {
        println(message)
        while true { # todo: ability to stop ?
          this: generateData()
          sleep(this: delay())
        }
      }): send("sensor " + this: id() + " is started")

    })

----
Public constructor of templateSensor
----
function templateSensor = |id, topic, delay, gateway, execEnv| {
  let failures = list[]

  let res = templateSensor()
              : id(id)
              : topic(topic)
              : gateway(gateway)
              : execEnv(execEnv)
              # : delay(delay)

  checkIsNotNull(item=delay, err="templateSensor: delay must be not Null"): bind(
    success=|item| {},
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: delay = default delay")
    }
  )

  checkIsLong(item=delay, err="templateSensor: delay must be a Long"): bind(
    success=|item| {
      res: delay(delay)
    },
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: delay = default delay")
    }
  )

  checkIsString(item=id, err="templateSensor: id must be a string"): bind(
    success=|item| {},
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: id = uuid()")
      res: id(uuid())
    }
  )
  checkIsNotNull(item=id, err="templateSensor: id must be not Null"): bind(
    success=|item| {},
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: id = uuid()")
      res: id(uuid())
    }
  )

  checkIsString(item=topic, err="templateSensor: topic must be a string"): bind(
    success=|item| {},
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: topic = topic_unknown")
      res: topic("topic_unknown")
    }
  )
  checkIsNotNull(item=topic, err="templateSensor: topic must be not Null"): bind(
    success=|item| {},
    failure=|errMessage| {
      failures: add(errMessage)
      failures: add("action: topic = topic_unknown")
      res: topic("topic_unknown")
    }
  )

  checkIsEmpty(collection=failures, err="templateSensor: some failures"): bind(
    success=|collection| {},
    failure=|errMessage| {
      println(errMessage)
      println(failures)
    }
  )

  return res
}

function templateSensor = |id, topic, delay| {
  return templateSensor(id=id, topic=topic, delay=delay, gateway=null, execEnv=null)
}
function templateSensor = |id, topic| {
  return templateSensor(id=id, topic=topic, delay=1000_L, gateway=null, execEnv=null)
}