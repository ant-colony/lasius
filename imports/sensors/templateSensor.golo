module templateSensor

import gololang.concurrent.workers.WorkerEnvironment
import functional

----
You can define your own template
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
        errMessage="WARNING: templateSensor:update, no topic=='get_value'"
      )(
        |item| { this: notifyGateway()}, |errMessage| { println(errMessage) }
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

----
function templateSensor = |id, topic, delay, gateway, execEnv| {
  let failures = list[]

  let res = templateSensor()
              : id(id)
              : topic(topic)
              : gateway(gateway)
              : execEnv(execEnv)
              # : delay(delay)

  checkIsNotNull(item=delay, errMessage="templateSensor: delay must be not Null")(
    |item| {},
    |errMessage| {
      failures: add(errMessage)
      failures: add("action: delay = default delay")
    }
  )

  checkIsLong(item=delay, errMessage="templateSensor: delay must be a Long")(
    |item| {
      res: delay(delay)
    },
    |errMessage| {
      failures: add(errMessage)
      failures: add("action: delay = default delay")
    }
  )

  checkIsString(item=id, errMessage="templateSensor: id must be a string")(
    |item| {},
    |errMessage| {
      failures: add(errMessage)
      failures: add("action: id = uuid()")
      res: id(uuid())
    }
  )
  checkIsNotNull(item=id, errMessage="templateSensor: id must be not Null")(
    |item| {},
    |errMessage| {
      failures: add(errMessage)
      failures: add("action: id = uuid()")
      res: id(uuid())
    }
  )

  checkIsString(item=topic, errMessage="templateSensor: topic must be a string")(
    |item| {},
    |errMessage| {
      failures: add(errMessage)
      failures: add("action: topic = topic_unknown")
      res: topic("topic_unknown")
    }
  )
  checkIsNotNull(item=topic, errMessage="templateSensor: topic must be not Null")(
    |item| {},
    |errMessage| {
      failures: add(errMessage)
      failures: add("action: topic = topic_unknown")
      res: topic("topic_unknown")
    }
  )

  checkIsEmpty(collection=failures, errMessage="templateSensor: some failures")(
    |collection| {},
    |errMessage| {
      println(errMessage)
      println(failures)
    }
  )

  return res
}